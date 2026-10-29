import Foundation
import SimAntics
import TSOContent
import TSOFiles

/// Which of TSO's three sprite sizes to draw: FreeSO's `WorldZoom`.
public enum SpriteZoom: UInt32, Sendable, CaseIterable {
    case far = 1, medium = 2, near = 3

    /// Screen pixels per world unit (a tile's side) at this zoom: FreeSO's `OneUnitDistance`,
    /// √(tile width² / 2), for tiles 32, 64, and 128 pixels wide.
    public var pixelsPerUnit: Float {
        switch self {
        case .far: Float(32 * 32 / 2.0).squareRoot()
        case .medium: Float(64 * 64 / 2.0).squareRoot()
        case .near: Float(128 * 128 / 2.0).squareRoot()
        }
    }
}

/// One sprite to draw for an object, placed as FreeSO's `DGRPRenderer` places it.
///
/// TSO's view is an orthographic projection looking down at 30°, so a sprite is drawn in
/// screen space: its top left is ``anchor`` projected to the screen, plus ``pixelOffset`` at
/// the sprite's own zoom.
public struct ObjectSprite: Sendable {
    /// The cached frame to draw.
    public var key: SpriteKey
    public var objectID: Int16
    /// The object's own anchor, without the sprite's offset, for drawing objects back to front.
    public var objectAnchor: SIMD3<Float>
    /// The floor, 1 for the ground.
    public var level: Int
    /// Where in the world the sprite hangs, in tiles (x along the lot's x, y up, z along its
    /// y): the object's position and half a tile (FreeSO's screen offset), plus the sprite's
    /// object offset turned with the object.
    public var anchor: SIMD3<Float>
    /// The sprite's top left relative to the anchor, in the zoom's pixels: the drawing group's
    /// sprite offset, less the frame's height.
    public var pixelOffset: SIMD2<Float>
    public var width: Int
    public var height: Int
    /// Drawn mirrored left to right.
    public var flip: Bool
}

/// A decoded frame's identity: the object resource, the file, and the sprite's place in it.
public struct SpriteKey: Hashable, Sendable {
    public var resource: String
    public var inSpriteFile: Bool
    public var spriteID: UInt32
    public var frame: UInt32
}

/// Decodes and keeps the frames objects draw with, so each is decoded once.
public final class SpriteLibrary {
    private var images: [SpriteKey: SpriteImage] = [:]
    private var failures: [SpriteKey: SpriteError] = [:]

    public init() {}

    /// The decoded frame for a key, decoding it from `file` the first time.
    public func image(for key: SpriteKey, sprite: DGRP.Sprite, in file: IFFFile) -> SpriteImage? {
        if let image = images[key] { return image }
        guard failures[key] == nil else { return nil }
        do {
            guard let image = try file.decodedFrame(for: sprite) else { return nil }
            images[key] = image
            return image
        } catch {
            failures[key] = error
            return nil
        }
    }

    /// A frame decoded earlier.
    public func image(for key: SpriteKey) -> SpriteImage? { images[key] }

    /// Frames that couldn't be decoded, by key, for reporting.
    public var failedFrames: [SpriteKey: SpriteError] { failures }
}

extension LotScene {
    /// The sprites each object on the lot draws for its graphic state and facing, seen from a
    /// world rotation (FreeSO's `WorldRotation`, 0 to 3) at a zoom.
    ///
    /// As FreeSO's `VMGameObject.RefreshGraphic`, the drawing group is the object's base graphic
    /// plus its graphic (object data 0); as `DGRPRenderer`, its image is the one for the facing,
    /// zoom, and rotation, and a dynamic sprite shows only while its flag is set. Sprites
    /// without depth are left out, as FreeSO's renderer leaves them out. Objects are in VM
    /// order, their sprites in drawing group order. They replace what `sprites` held, keeping
    /// its storage, so a frame doesn't allocate a new list.
    public static func objectSprites(of vm: VM, zoom: SpriteZoom, worldRotation: UInt32, library: SpriteLibrary,
                                     into sprites: inout [ObjectSprite]) {
        sprites.removeAll(keepingCapacity: true)
        for entity in vm.entities where !entity.isDead {
            var holder = entity
            var depth = 0
            while let container = holder.container, depth < 8 {
                holder = container
                depth += 1
            }
            guard holder.position != .outOfWorld else { continue }
            let definition = entity.object.definition
            let graphic = UInt16(bitPattern: entity.objectData[Int(ObjectVariable.graphic.rawValue)])
            let resource = entity.object.resource
            let groupID = definition.baseGraphicID &+ graphic
            guard let (group, file) = (try? resource.drawGroup(id: groupID)) ?? nil,
                  let image = group.image(direction: UInt32(entity.direction.rawValue), zoom: zoom.rawValue, worldRotation: worldRotation)
            else { continue }
            let inSpriteFile = ((try? resource.mainFile.chunk(DGRP.self, id: groupID)) ?? nil) == nil

            let level = Int(holder.position.level)
            // Objects in slots sit on top of what holds them, roughly, until slots are placed exactly.
            let height = Float(level - 1) * Self.levelHeight + Self.objectHeight * Float(depth)
            let base = SIMD3(Float(holder.position.x) / 16 + 0.5, height, Float(holder.position.y) / 16 + 0.5)
            let turn = Self.radians(of: entity.direction)
            let dynamicBase = UInt32(definition.dynamicSpriteBaseId)
            let dynamicCount = UInt32(definition.numDynamicSprites)
            for sprite in image.sprites {
                if sprite.spriteID >= dynamicBase, sprite.spriteID < dynamicBase + dynamicCount,
                   !entity.isDynamicSpriteFlagSet(UInt16(sprite.spriteID - dynamicBase)) {
                    continue
                }
                let key = SpriteKey(resource: resource.name, inSpriteFile: inSpriteFile,
                                    spriteID: sprite.spriteID, frame: sprite.frameIndex)
                guard let frame = library.image(for: key, sprite: sprite, in: file), frame.depth != nil else { continue }
                // The object offset is in sixteenths of a tile across and fifths up, turned with the object.
                let offset = sprite.objectOffset * SIMD3(1.0 / 16, 1.0 / 16, 1.0 / 5)
                let turned = SIMD2(offset.x * cos(turn) - offset.y * sin(turn), offset.x * sin(turn) + offset.y * cos(turn))
                sprites.append(ObjectSprite(
                    key: key, objectID: entity.objectID, objectAnchor: base, level: level,
                    anchor: base + SIMD3(turned.x, offset.z, turned.y),
                    pixelOffset: SIMD2(Float(sprite.spriteOffset.x), Float(sprite.spriteOffset.y) - Float(frame.height)),
                    width: frame.width, height: frame.height, flip: sprite.flags.contains(.flip)
                ))
            }
        }
    }

    /// FreeSO's `DGRPRenderer.RadianDirection`: the four main facings; the diagonals don't turn.
    static func radians(of direction: Direction) -> Float {
        switch direction {
        case .east: .pi / 2
        case .south: .pi
        case .west: .pi * 1.5
        default: 0
        }
    }
}
