import LotScene
import Raylib

/// Gives each sprite pixel a depth, so sprites cover each other, and the walls and floors drawn
/// in 3D, pixel by pixel (roadmap decision 7, Hyde Park E2).
///
/// Sprites are still drawn flat on the screen, pixel for pixel, as FreeSO's `_2DWorldBatch`
/// draws them; only their depth is worked out in the world. Each sprite's ``ObjectSprite/back``
/// and ``ObjectSprite/front`` are projected with the same matrices the 3D pass uses, and the
/// fragment shader writes, for each pixel, the depth `(1 − d) / 0.4` of the way from back to
/// front, where `d` is the frame's stored depth (FreeSO's `psZSprite` and `depthCalc2`).
/// The projection is orthographic, so depth is linear between the two, and interpolating it
/// in window depth is exact.
final class SpriteDepth {
    private let shader: Shader
    private let depthTextureLocation: Int32
    private let depthLineLocation: Int32
    private var view = Matrix()
    private var projection = Matrix()

    /// Loads the shader; `nil` if the GPU's OpenGL can't compile it, and the client then
    /// draws sprites back to front without depth, as before.
    init?() {
        let shader = LoadShaderFromMemory(Self.vertexShader, Self.fragmentShader)
        guard IsShaderValid(shader) else {
            UnloadShader(shader)
            return nil
        }
        self.shader = shader
        depthTextureLocation = GetShaderLocation(shader, "depthTexture")
        depthLineLocation = GetShaderLocation(shader, "depthLine")
    }

    /// Releases the shader; call before the window closes.
    func unload() {
        UnloadShader(shader)
    }

    /// Takes this frame's 3D camera, as `BeginMode3D` would set it up for an orthographic camera.
    func prepare(camera: Camera3D, screenWidth: Int, screenHeight: Int) {
        let aspect = Double(max(screenWidth, 1)) / Double(max(screenHeight, 1))
        let top = Double(camera.fovy) / 2, right = top * aspect
        projection = MatrixOrtho(-right, right, -top, top, rlGetCullDistanceNear(), rlGetCullDistanceFar())
        view = MatrixLookAt(camera.position, camera.target, camera.up)
    }

    /// A point's window depth, 0 near to 1 far, as the 3D pass writes it.
    func windowDepth(of point: SIMD3<Float>) -> Float {
        var clip = Quaternion(x: point.x, y: point.y, z: point.z, w: 1)
        clip = QuaternionTransform(clip, view)
        clip = QuaternionTransform(clip, projection)
        let ndc = clip.w != 0 ? clip.z / clip.w : clip.z
        return ndc * 0.5 + 0.5
    }

    /// Starts the sprite pass: depth is tested and written from here on.
    func begin() {
        rlDrawRenderBatchActive()
        rlEnableDepthTest()
        rlEnableDepthMask()
    }

    /// Ends the sprite pass.
    func end() {
        rlDrawRenderBatchActive()
        rlDisableDepthTest()
    }

    /// Draws one sprite with its depth. Uniforms change between sprites, so each is drawn and
    /// flushed on its own.
    func draw(_ texture: Texture2D, depth: Texture2D, back: SIMD3<Float>, front: SIMD3<Float>,
              source: Rectangle, destination: Rectangle, tint: Color) {
        var line = SIMD2<Float>(windowDepth(of: back), windowDepth(of: front))
        BeginShaderMode(shader)
        withUnsafePointer(to: &line) { SetShaderValue(shader, depthLineLocation, $0, Int32(ShaderUniformDataType.vec2.rawValue)) }
        SetShaderValueTexture(shader, depthTextureLocation, depth)
        DrawTexturePro(texture, source, destination, .zero, 0, tint)
        EndShaderMode()
    }

    // raylib's default vertex shader for OpenGL 3.3.
    private static let vertexShader = """
        #version 330
        in vec3 vertexPosition;
        in vec2 vertexTexCoord;
        in vec4 vertexColor;
        uniform mat4 mvp;
        out vec2 fragTexCoord;
        out vec4 fragColor;
        void main() {
            fragTexCoord = vertexTexCoord;
            fragColor = vertexColor;
            gl_Position = mvp * vec4(vertexPosition, 1.0);
        }
        """

    // The colour as raylib's default shader draws it; the depth as FreeSO's psZSprite works it out.
    private static let fragmentShader = """
        #version 330
        in vec2 fragTexCoord;
        in vec4 fragColor;
        uniform sampler2D texture0;
        uniform sampler2D depthTexture;
        uniform vec4 colDiffuse;
        uniform vec2 depthLine;
        out vec4 finalColor;
        void main() {
            vec4 color = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
            if (color.a == 0.0) discard;
            float stored = texture(depthTexture, fragTexCoord).r;
            float along = (1.0 - stored) / 0.4;
            gl_FragDepth = depthLine.x + along * (depthLine.y - depthLine.x);
            finalColor = color;
        }
        """
}
