import Foundation
import NSOInterface
import LotScene
import Raylib
import SimAntics

/// Draws a ``LotScene`` the way TSO projects it (roadmap decision 7): an orthographic 3D camera
/// looking down at 30° on a diagonal, which is exactly TSO's 2:1 view, so the lot's boxes and
/// the objects' sprites line up. Works out which object is under the pointer, too.
final class LotView {
    /// The zoom steps: TSO's three sprite sizes, then two farther views of the far sprites, scaled
    /// down, for seeing a whole lot.
    static let zoomSteps: [(zoom: SpriteZoom, scale: Float)] = [
        (.near, 1), (.medium, 1), (.far, 1), (.far, 0.5), (.far, 0.25),
    ]

    /// Quarter turns of the view.
    private(set) var rotation = 0
    /// The index into ``zoomSteps``.
    private(set) var zoomStep = 1
    /// The floor the player is looking at; floors above it are hidden.
    var level = 1
    /// Whether walls are cut down so the rooms inside show.
    var wallsCut = true
    private var target = SIMD3<Float>(0, 0, 0)

    /// The sprite size drawn at.
    var spriteZoom: SpriteZoom { Self.zoomSteps[zoomStep].zoom }
    /// How much the sprites are scaled from their own size.
    var spriteScale: Float { Self.zoomSteps[zoomStep].scale }
    /// Screen pixels per world unit.
    var pixelsPerUnit: Float { spriteZoom.pixelsPerUnit * spriteScale }
    /// FreeSO's `WorldRotation` for this view: turning the view one way turns the world the other.
    var worldRotation: UInt32 { UInt32((4 - rotation) % 4) }

    func center(on point: SIMD3<Float>) {
        target = point
    }

    func rotate(by quarterTurns: Int) {
        rotation = ((rotation + quarterTurns) % 4 + 4) % 4
    }

    func setZoomStep(_ step: Int) {
        zoomStep = min(max(step, 0), Self.zoomSteps.count - 1)
    }

    /// Steps the zoom in (positive) or out (negative), one step a wheel notch.
    func zoom(by wheel: Float) {
        guard wheel != 0 else { return }
        zoomStep = min(max(zoomStep + (wheel > 0 ? -1 : 1), 0), Self.zoomSteps.count - 1)
    }

    /// Picks the closest zoom at which a lot of this size fits on a screen this tall.
    func fit(width: Int, height: Int, screenHeight: Int) {
        // A lot's diagonal runs across the screen; its depth takes about half its length in height.
        let needed = Float(max(width, height)) * 0.75
        zoomStep = Self.zoomSteps.firstIndex { Float(screenHeight) / ($0.zoom.pixelsPerUnit * $0.scale) >= needed }
            ?? Self.zoomSteps.count - 1
    }

    /// Moves the view by a drag of the pointer, in screen pixels.
    func pan(by pixels: Vector2) {
        let unitsPerPixel = 1 / pixelsPerUnit
        let (right, forward) = groundAxes()
        target -= right * pixels.x * unitsPerPixel
        // A pixel down the screen is two along the ground, at 30° down.
        target += forward * pixels.y * unitsPerPixel * 2
    }

    /// The camera for a screen this tall.
    func camera(screenHeight: Int) -> Camera3D {
        let angle = (Float(rotation) * 90 + 45) * .pi / 180
        let distance: Float = 200
        // 30° down, as TSO's tiles are twice as wide as they're tall.
        let offset = SIMD3<Float>(cos(angle) * distance, distance * tan(.pi / 6), sin(angle) * distance)
        let eye = target + offset
        return Camera3D(position: vector(eye), target: vector(target), up: Vector3(x: 0, y: 1, z: 0),
                        fovy: Float(max(screenHeight, 1)) / pixelsPerUnit,
                        projection: Int32(truncatingIfNeeded: CameraProjection.orthographic.rawValue))
    }

    /// The camera's right, and the ground direction away from the viewer, both level.
    private func groundAxes() -> (SIMD3<Float>, SIMD3<Float>) {
        let angle = (Float(rotation) * 90 + 45) * .pi / 180
        let toward = SIMD3<Float>(-cos(angle), 0, -sin(angle))
        let right = SIMD3<Float>(-toward.z, 0, toward.x)
        return (right, toward)
    }

    // MARK: Drawing

    /// The lot's floors and walls, and the boxes of objects without sprites. Floors and the ground
    /// are drawn a little back and down (``SpriteZoom/floorBias(scale:towardViewer:)``), as FreeSO
    /// draws them, so the sprites standing on them aren't cut off.
    func draw(_ scene: LotScene, camera: Camera3D, objectsWithSprites: Set<Int16>, selected: Int16?, hovered: Int16?) {
        let eye = SIMD3(camera.position.x, camera.position.y, camera.position.z)
        let offset = eye - target
        let towardViewer = offset / (offset * offset).sum().squareRoot()
        let bias = spriteZoom.floorBias(scale: spriteScale, towardViewer: towardViewer)
        BeginMode3D(camera)
        for var box in scene.architecture where box.level <= level {
            switch box.kind {
            case .ground, .floor, .water: box.center += bias
            case .wall, .fence, .object: break
            }
            draw(box, color: color(of: box), outline: false)
        }
        for box in scene.objects where box.level <= level {
            guard case .object(let id) = box.kind, !objectsWithSprites.contains(id) else { continue }
            let color = id == selected ? Theme.accent : id == hovered ? Color(r: 150, g: 200, b: 255, a: 255) : objectColor(id)
            draw(box, color: color, outline: true)
        }
        EndMode3D()
    }

    /// The objects' sprites, flat on the screen, objects farthest from the viewer first. Each
    /// sprite's top left is its anchor's place on screen plus its pixel offset, scaled for zoom.
    /// With `depth`, each pixel also gets its depth (``SpriteDepth``), so what's nearer covers
    /// what's farther pixel by pixel; the back-to-front order then only blends soft edges.
    func drawSprites(_ sprites: [ObjectSprite], camera: Camera3D, textures: SpriteTextures, depth: SpriteDepth?,
                     order: inout [Int], selected: Int16?, hovered: Int16?) {
        let angle = (Float(rotation) * 90 + 45) * .pi / 180
        let towardViewer = SIMD3<Float>(cos(angle), 0, sin(angle))
        order.removeAll(keepingCapacity: true)
        order.append(contentsOf: sprites.indices)
        // Back to front by each object's anchor; an object's sprites keep their drawing group order.
        order.sort { a, b in
            let depthA = (sprites[a].objectAnchor * towardViewer).sum() + sprites[a].objectAnchor.y
            let depthB = (sprites[b].objectAnchor * towardViewer).sum() + sprites[b].objectAnchor.y
            return depthA != depthB ? depthA < depthB : a < b
        }
        let scale = spriteScale
        depth?.prepare(camera: camera, screenWidth: Int(GetScreenWidth()), screenHeight: Int(GetScreenHeight()))
        depth?.begin()
        defer { depth?.end() }
        for index in order {
            let sprite = sprites[index]
            guard sprite.level <= level, let texture = textures.texture(for: sprite.key) else { continue }
            let anchor = GetWorldToScreen(vector(sprite.anchor), camera)
            let width = Float(sprite.width), height = Float(sprite.height)
            let source = Rectangle(x: 0, y: 0, width: sprite.flip ? -width : width, height: height)
            let destination = Rectangle(x: anchor.x + sprite.pixelOffset.x * scale, y: anchor.y + sprite.pixelOffset.y * scale,
                                        width: width * scale, height: height * scale)
            let tint = sprite.objectID == selected ? Color(r: 255, g: 220, b: 140, a: 255)
                : sprite.objectID == hovered ? Color(r: 200, g: 225, b: 255, a: 255) : Color.white
            if let depth, let depthTexture = textures.depthTexture(for: sprite.key) {
                depth.draw(texture, depth: depthTexture, back: sprite.back, front: sprite.front,
                           source: source, destination: destination, tint: tint)
            } else {
                DrawTexturePro(texture, source, destination, .zero, 0, tint)
            }
        }
    }

    private func draw(_ box: LotScene.Box, color: Color, outline: Bool) {
        var size = box.size
        var center = box.center
        if wallsCut, box.kind == .wall, box.level == level {
            let cut: Float = 0.35
            center.y -= (size.y - cut) / 2
            size.y = cut
        }
        if box.yaw != 0 {
            rlPushMatrix()
            rlTranslatef(center.x, center.y, center.z)
            rlRotatef(box.yaw, 0, 1, 0)
            DrawCube(.zero, size.x, size.y, size.z, color)
            rlPopMatrix()
            return
        }
        DrawCube(vector(center), size.x, size.y, size.z, color)
        if outline {
            DrawCubeWires(vector(center), size.x, size.y, size.z, Color(r: 20, g: 24, b: 30, a: 255))
        }
    }

    private func color(of box: LotScene.Box) -> Color {
        switch box.kind {
        case .ground: Color(r: 74, g: 112, b: 62, a: 255)
        case .water: Color(r: 60, g: 130, b: 200, a: 255)
        case .wall: Color(r: 214, g: 206, b: 190, a: 255)
        case .fence: Color(r: 150, g: 120, b: 90, a: 255)
        case .floor(let room, let isOutside):
            isOutside ? Color(r: 160, g: 150, b: 130, a: 255) : roomColor(room)
        case .object: Color.gray
        }
    }

    // Rooms and objects get steady colors from their numbers, so they're told apart at a glance.
    private func roomColor(_ room: UInt16) -> Color {
        let palette: [Color] = [
            Color(r: 196, g: 170, b: 140, a: 255), Color(r: 170, g: 186, b: 160, a: 255),
            Color(r: 182, g: 168, b: 196, a: 255), Color(r: 200, g: 184, b: 150, a: 255),
            Color(r: 160, g: 180, b: 196, a: 255), Color(r: 204, g: 164, b: 160, a: 255),
        ]
        return palette[Int(room) % palette.count]
    }

    private func objectColor(_ id: Int16) -> Color {
        let palette: [Color] = [
            Color(r: 224, g: 120, b: 90, a: 255), Color(r: 90, g: 160, b: 210, a: 255),
            Color(r: 230, g: 190, b: 80, a: 255), Color(r: 130, g: 190, b: 120, a: 255),
            Color(r: 190, g: 120, b: 200, a: 255), Color(r: 80, g: 190, b: 180, a: 255),
        ]
        return palette[Int(UInt16(bitPattern: id)) % palette.count]
    }

    // MARK: Picking

    /// The object under a point on the screen, the nearest when boxes overlap.
    func object(at point: Vector2, in scene: LotScene, camera: Camera3D) -> Int16? {
        let ray = GetScreenToWorldRay(point, camera)
        var nearest: (id: Int16, distance: Float)?
        for box in scene.objects where box.level <= level {
            guard case .object(let id) = box.kind else { continue }
            let half = box.size / 2
            let bounds = BoundingBox(min: vector(box.center - half), max: vector(box.center + half))
            let hit = GetRayCollisionBox(ray, bounds)
            if hit.hit, hit.distance < nearest?.distance ?? .infinity {
                nearest = (id, hit.distance)
            }
        }
        return nearest?.id
    }

    private func vector(_ value: SIMD3<Float>) -> Vector3 {
        Vector3(x: value.x, y: value.y, z: value.z)
    }
}

/// The GPU textures of decoded sprite frames, made the first time each is drawn and kept until
/// the window closes.
final class SpriteTextures {
    private let library: SpriteLibrary
    private var textures: [SpriteKey: Texture2D] = [:]
    private var missing: Set<SpriteKey> = []
    private var depthTextures: [SpriteKey: Texture2D] = [:]
    private var missingDepth: Set<SpriteKey> = []

    init(library: SpriteLibrary) {
        self.library = library
    }

    func texture(for key: SpriteKey) -> Texture2D? {
        if let texture = textures[key] { return texture }
        guard !missing.contains(key), let image = library.image(for: key), image.width > 0, image.height > 0,
              var rgba = image.rgba else {
            missing.insert(key)
            return nil
        }
        let texture = rgba.withUnsafeMutableBytes { bytes in
            LoadTextureFromImage(Image(data: bytes.baseAddress, width: Int32(clamping: image.width), height: Int32(clamping: image.height),
                                       mipmaps: 1, format: Int32(truncatingIfNeeded: PixelFormat.uncompressedR8g8b8a8.rawValue)))
        }
        guard IsTextureValid(texture) else {
            missing.insert(key)
            return nil
        }
        // Pixel art stays sharp, at TSO's own sizes and scaled down.
        SetTextureFilter(texture, .point)
        textures[key] = texture
        return texture
    }

    /// A frame's stored depth as a one-channel texture: each pixel's byte, 0 nearest.
    func depthTexture(for key: SpriteKey) -> Texture2D? {
        if let texture = depthTextures[key] { return texture }
        guard !missingDepth.contains(key), let image = library.image(for: key), image.width > 0, image.height > 0,
              var depth = image.depth, depth.count == image.width * image.height else {
            missingDepth.insert(key)
            return nil
        }
        let texture = depth.withUnsafeMutableBytes { bytes in
            LoadTextureFromImage(Image(data: bytes.baseAddress, width: Int32(clamping: image.width), height: Int32(clamping: image.height),
                                       mipmaps: 1, format: Int32(truncatingIfNeeded: PixelFormat.uncompressedGrayscale.rawValue)))
        }
        guard IsTextureValid(texture) else {
            missingDepth.insert(key)
            return nil
        }
        // Depth must never blend between pixels.
        SetTextureFilter(texture, .point)
        depthTextures[key] = texture
        return texture
    }

    /// Releases every texture; call before the window closes.
    func unloadAll() {
        for texture in textures.values { UnloadTexture(texture) }
        for texture in depthTextures.values { UnloadTexture(texture) }
        textures.removeAll()
        depthTextures.removeAll()
    }
}
