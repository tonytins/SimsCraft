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

    /// How far floors and the ground are moved from where they are, in tiles, so sprites standing
    /// on them aren't cut off: TSO's depth art puts the bottom of some sprites, such as a stand
    /// drawn over the next tile, a little behind the floor it's drawn on.
    ///
    /// Ports update-46's `TerrainComponent.Draw`, which draws its 3D floors and terrain a quarter
    /// world unit farther from the viewer (`View * CreateTranslation(0, 0, -0.25)`), and lower by
    /// 3, 5, or 7 × 20/522 world units at near, medium, and far, more at a smaller `scale`.
    /// FreeSO's walls are sprites and aren't moved, so NewSO's walls aren't either.
    ///
    /// - Parameter towardViewer: The unit direction from the view's target to the camera.
    public func floorBias(scale: Float, towardViewer: SIMD3<Float>) -> SIMD3<Float> {
        let steps: Float = switch self {
        case .near: 3
        case .medium: 5
        case .far: 7
        }
        let lower = steps * (20 / 522) / (scale < 1 ? scale : 1)
        return (-0.25 * towardViewer - SIMD3(0, lower, 0)) / Self.worldUnitsPerTile
    }

    /// FreeSO's `WorldSpace.WorldUnitsPerTile`.
    static let worldUnitsPerTile: Float = 3
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
    /// Where the sprite's depth starts and ends in the world (roadmap decision 7). The frame's
    /// stored depth places each pixel on the line from ``back`` toward ``front``: a pixel of
    /// depth `d` sits `(1 − d) / 0.4` of the way along it, as FreeSO's `2DWorldBatch` effect
    /// (`vsZSprite`, `depthCalc2`) places it, so overlapping sprites, and walls and floors drawn
    /// in 3D, cover each other pixel by pixel. See ``LotScene/depthLine(corner:worldRotation:)``.
    public var back: SIMD3<Float>
    public var front: SIMD3<Float>
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
                                     hiddenByBlueprint: [Int16: UInt32] = [:], into sprites: inout [ObjectSprite]) {
        sprites.removeAll(keepingCapacity: true)
        for entity in vm.entities where !entity.isDead {
            var holder = entity
            var depth = 0
            while let container = holder.container, depth < 8 {
                holder = container
                depth += 1
            }
            guard holder.position != .outOfWorld, !Self.isHidden(entity, hiddenByBlueprint: hiddenByBlueprint) else { continue }
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
                let anchor = base + SIMD3(turned.x, offset.z, turned.y)
                // FreeSO's world position is the tile's corner, not the centre the anchor adds.
                let (back, front) = Self.depthLine(corner: anchor - SIMD3(0.5, 0, 0.5), worldRotation: worldRotation)
                sprites.append(ObjectSprite(
                    key: key, objectID: entity.objectID, objectAnchor: base, level: level, anchor: anchor,
                    pixelOffset: SIMD2(Float(sprite.spriteOffset.x), Float(sprite.spriteOffset.y) - Float(frame.height)),
                    width: frame.width, height: frame.height, flip: sprite.flags.contains(.flip), back: back, front: front
                ))
            }
        }
    }

    /// Whether an object is hidden, so it isn't drawn or picked: its code has hidden it (object
    /// data 34), as portals and other controllers do and as FreeSO's `VMEntity.SetValue` reads it;
    /// or the lot's blueprint marks it `hidden="1"`, as TSO's job lots mark their portals
    /// (``LotSession/hiddenByBlueprint``, an object ID with its GUID).
    public static func isHidden(_ entity: Entity, hiddenByBlueprint: [Int16: UInt32] = [:]) -> Bool {
        entity.objectData[Int(ObjectVariable.hidden.rawValue)] != 0
            || hiddenByBlueprint[entity.objectID] == entity.object.guid
    }

    /// The line a sprite's depth runs along, for a sprite whose world position (FreeSO's
    /// `AbsoluteWorldPosition`: the object's tile corner plus its object offset) is `corner`.
    ///
    /// Ports `_2DWorldBatch.BackOffForRot` and `FrontDirForRot`, in tiles rather than FreeSO's 3
    /// world units to a tile: the back is the tile's corner farthest from the viewer, and the
    /// front a tile diagonally toward the viewer from there.
    public static func depthLine(corner: SIMD3<Float>, worldRotation: UInt32) -> (back: SIMD3<Float>, front: SIMD3<Float>) {
        let (toBack, toFront): (SIMD3<Float>, SIMD3<Float>) = switch worldRotation % 4 {
        case 1: (SIMD3(0, 0, 1), SIMD3(1, 0, -1))      // TopRight
        case 2: (SIMD3(1, 0, 1), SIMD3(-1, 0, -1))     // BottomRight
        case 3: (SIMD3(1, 0, 0), SIMD3(-1, 0, 1))      // BottomLeft
        default: (SIMD3(0, 0, 0), SIMD3(1, 0, 1))      // TopLeft
        }
        let back = corner + toBack
        return (back, back + toFront)
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
