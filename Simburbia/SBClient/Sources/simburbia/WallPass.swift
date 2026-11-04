import LotScene
import Raylib
import TSOFiles

/// Draws the walls' sprites (``LotScene/wallSprites(of:level:zoom:worldRotation:wallsDown:)``) with
/// their depth, as update-46's `WallComponent` and `_2DWorldBatch` draw them: flat on the screen,
/// pixel for pixel, each pixel at a depth from a generated gradient, so walls, objects, and
/// floors cover each other where they should. A wall's pattern shows where its style's mask does.
final class WallPass {
    private let images: WallImages
    private var textures: [WallImage: Texture2D] = [:]
    private var missing: Set<WallImage> = []
    private var depthTextures: [Int: Texture2D] = [:]

    init(images: WallImages) {
        self.images = images
    }

    /// Draws the sprites of the levels up to `level`. Call between the 3D pass and the objects'
    /// sprites; needs the depth shader, without which walls stay boxes.
    func draw(_ sprites: [WallSprite], camera: Camera3D, depth: SpriteDepth, scale: Float, level: Int) {
        depth.prepare(camera: camera, screenWidth: Int(GetScreenWidth()), screenHeight: Int(GetScreenHeight()))
        depth.begin()
        defer { depth.end() }
        for sprite in sprites where sprite.level <= level {
            guard let texture = texture(for: sprite.image), let depthTexture = depthTexture(sprite.depthBuffer) else { continue }
            let anchor = GetWorldToScreen(Vector3(x: sprite.anchor.x, y: sprite.anchor.y, z: sprite.anchor.z), camera)
            let width = Float(texture.width), height = Float(texture.height)
            let source = Rectangle(x: sprite.source.x * width, y: sprite.source.y * height,
                                   width: sprite.source.z * width, height: sprite.source.w * height)
            let destination = Rectangle(x: anchor.x + sprite.destination.x * scale, y: anchor.y + sprite.destination.y * scale,
                                        width: sprite.destination.z * scale, height: sprite.destination.w * scale)
            if let maskImage = sprite.mask, let mask = self.texture(for: maskImage) {
                depth.drawWall(texture, mask: mask, depth: depthTexture, back: sprite.back, front: sprite.front,
                               source: source, destination: destination)
            } else {
                // No mask: the image's own alpha, as FreeSO's `mask ?? sprite`.
                depth.draw(texture, depth: depthTexture, back: sprite.back, front: sprite.front,
                           source: source, destination: destination, tint: .white)
            }
        }
    }

    private func texture(for image: WallImage) -> Texture2D? {
        if let found = textures[image] { return found }
        guard !missing.contains(image), let decoded = images.image(for: image), decoded.width > 0, decoded.height > 0,
              var rgba = decoded.rgba else {
            missing.insert(image)
            return nil
        }
        let texture = rgba.withUnsafeMutableBytes { bytes in
            LoadTextureFromImage(Image(data: bytes.baseAddress, width: Int32(clamping: decoded.width), height: Int32(clamping: decoded.height),
                                       mipmaps: 1, format: Int32(truncatingIfNeeded: PixelFormat.uncompressedR8g8b8a8.rawValue)))
        }
        guard IsTextureValid(texture) else {
            missing.insert(image)
            return nil
        }
        SetTextureFilter(texture, .point)
        textures[image] = texture
        return texture
    }

    private func depthTexture(_ index: Int) -> Texture2D? {
        if let found = depthTextures[index] { return found }
        guard var buffer = LotScene.wallDepthBuffer(index) else { return nil }
        let texture = buffer.depth.withUnsafeMutableBytes { bytes in
            LoadTextureFromImage(Image(data: bytes.baseAddress, width: Int32(buffer.width), height: Int32(buffer.height),
                                       mipmaps: 1, format: Int32(truncatingIfNeeded: PixelFormat.uncompressedGrayscale.rawValue)))
        }
        guard IsTextureValid(texture) else { return nil }
        SetTextureFilter(texture, .point)
        depthTextures[index] = texture
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
