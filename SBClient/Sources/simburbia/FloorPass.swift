import LotScene
import Raylib
import TSOFiles

/// Draws the lot's floors as textured tiles in the 3D pass, as update-46's `_3DFloorGeometry` and
/// `GrassShader` draw them: each floor's sprite is a texture that repeats across the lot, so a
/// tile's diamond takes its part of it (``LotScene/textureCoordinates(x:y:texture:worldRotation:zoom:)``).
///
/// As in FreeSO, floors are opaque and texels under half alpha are discarded; floor patterns
/// are filtered smoothly (with mipmaps), pools and water by nearest texel; a water tile has a
/// plain tile drawn under it, the ground's color here since grass isn't drawn yet.
final class FloorPass {
    private let images: FloorImages
    private var textures: [Key: Texture2D] = [:]
    private var missing: Set<Key> = []
    /// Discards texels under half alpha; `nil` if it didn't compile, and floors blend instead.
    private let shader: Shader?

    private struct Key: Hashable {
        var texture: FloorTexture
        var zoom: SpriteZoom
    }

    /// How far a water tile is drawn above its floor: FreeSO's 0.05 world units.
    private static let waterRaise: Float = 0.05 / 3
    static let groundColor = Color(r: 74, g: 112, b: 62, a: 255)

    init(images: FloorImages) {
        self.images = images
        let shader = LoadShaderFromMemory(nil, Self.fragmentShader)
        if IsShaderValid(shader) {
            self.shader = shader
        } else {
            UnloadShader(shader)
            self.shader = nil
        }
    }

    /// Draws the floors of the levels up to `level`, moved by `bias`. Call inside `BeginMode3D`.
    func draw(_ groups: [(texture: FloorTexture, tiles: [FloorTile])], level: Int, zoom: SpriteZoom,
              worldRotation: UInt32, bias: SIMD3<Float>) {
        rlDrawRenderBatchActive()
        rlDisableBackfaceCulling()
        if let shader { BeginShaderMode(shader) }
        for (texture, tiles) in groups {
            let drawn: FloorTexture = switch texture {
            case .pattern: texture
            case .water(let shape): .water(shape: LotScene.shape(shape, worldRotation: worldRotation))
            case .pool(let shape): .pool(shape: LotScene.shape(shape, worldRotation: worldRotation))
            }
            guard let gpu = self.texture(for: drawn, zoom: zoom) else { continue }
            if texture.isRaised { quads(tiles, level: level, raise: 0, bias: bias, texture: nil, zoom: zoom, worldRotation: worldRotation) }
            quads(tiles, level: level, raise: texture.isRaised ? Self.waterRaise : 0, bias: bias,
                  texture: (gpu, texture), zoom: zoom, worldRotation: worldRotation)
        }
        if shader != nil { EndShaderMode() }
        rlDrawRenderBatchActive()
        rlEnableBackfaceCulling()
    }

    /// One quad per tile, its corners at the tile's corners on its level, with each corner's
    /// texture coordinates; with no texture, plain in the ground's color.
    private func quads(_ tiles: [FloorTile], level: Int, raise: Float, bias: SIMD3<Float>,
                       texture: (gpu: Texture2D, kind: FloorTexture)?, zoom: SpriteZoom, worldRotation: UInt32) {
        rlSetTexture(texture?.gpu.id ?? rlGetTextureIdDefault())
        rlBegin(RL_QUADS)
        let color = texture == nil ? Self.groundColor : Color.white
        rlColor4ub(color.r, color.g, color.b, color.a)
        for tile in tiles where tile.level <= level {
            let height = Float(tile.level - 1) * LotScene.levelHeight + raise + bias.y
            let x = Float(tile.x), y = Float(tile.y)
            for (cornerX, cornerY) in [(x, y), (x, y + 1), (x + 1, y + 1), (x + 1, y)] {
                if let texture {
                    let uv = LotScene.textureCoordinates(x: cornerX, y: cornerY, texture: texture.kind,
                                                         worldRotation: worldRotation, zoom: zoom)
                    rlTexCoord2f(uv.x, uv.y)
                }
                rlVertex3f(cornerX + bias.x, height, cornerY + bias.z)
            }
        }
        rlEnd()
        rlSetTexture(0)
    }

    private func texture(for texture: FloorTexture, zoom: SpriteZoom) -> Texture2D? {
        let key = Key(texture: texture, zoom: zoom)
        if let found = textures[key] { return found }
        guard !missing.contains(key), let image = images.image(for: texture, zoom: zoom),
              image.width > 0, image.height > 0, var rgba = image.rgba else {
            missing.insert(key)
            return nil
        }
        var gpu = rgba.withUnsafeMutableBytes { bytes in
            LoadTextureFromImage(Image(data: bytes.baseAddress, width: Int32(clamping: image.width), height: Int32(clamping: image.height),
                                       mipmaps: 1, format: Int32(truncatingIfNeeded: PixelFormat.uncompressedR8g8b8a8.rawValue)))
        }
        guard IsTextureValid(gpu) else {
            missing.insert(key)
            return nil
        }
        SetTextureWrap(gpu, .repeat)
        if case .pattern = texture {
            GenTextureMipmaps(&gpu)
            SetTextureFilter(gpu, .trilinear)
        } else {
            SetTextureFilter(gpu, .point)
        }
        textures[key] = gpu
        return gpu
    }

    /// Releases every texture and the shader; call before the window closes.
    func unloadAll() {
        for texture in textures.values { UnloadTexture(texture) }
        textures.removeAll()
        if let shader { UnloadShader(shader) }
    }

    // raylib's default fragment shader, discarding as FreeSO's GrassShader does.
    private static let fragmentShader = """
        #version 330
        in vec2 fragTexCoord;
        in vec4 fragColor;
        uniform sampler2D texture0;
        uniform vec4 colDiffuse;
        out vec4 finalColor;
        void main() {
            vec4 color = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
            if (color.a < 0.5) discard;
            finalColor = vec4(color.rgb, 1.0);
        }
        """
}
