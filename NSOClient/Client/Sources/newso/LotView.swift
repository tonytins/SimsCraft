import Foundation
import Interface
import LotScene
import Raylib
import SimAntics

/// Draws a ``LotScene`` through an orthographic 3D camera (roadmap decision 7), and works out
/// which object is under the pointer.
final class LotView {
    /// Quarter turns of the view, as TSO's four rotations.
    private(set) var rotation = 0
    /// The world height the screen shows; smaller is closer.
    private(set) var span: Float = 40
    /// The floor the player is looking at; floors above it are hidden.
    var level = 1
    /// Whether walls are cut down so the rooms inside show.
    var wallsCut = true
    private var target = SIMD3<Float>(0, 0, 0)

    static let leastSpan: Float = 6
    static let mostSpan: Float = 160

    func center(on point: SIMD3<Float>) {
        target = point
    }

    /// Zooms so a lot of this size fills most of the screen.
    func fit(width: Int, height: Int) {
        span = min(max(Float(max(width, height)) * 0.65, Self.leastSpan), Self.mostSpan)
    }

    func rotate(by quarterTurns: Int) {
        rotation = ((rotation + quarterTurns) % 4 + 4) % 4
    }

    func zoom(by wheel: Float) {
        guard wheel != 0 else { return }
        span = min(max(span * (wheel > 0 ? 0.85 : 1 / 0.85), Self.leastSpan), Self.mostSpan)
    }

    /// Moves the view by a drag of the pointer, in screen pixels.
    func pan(by pixels: Vector2, screenHeight: Int) {
        guard screenHeight > 0 else { return }
        let unitsPerPixel = span / Float(screenHeight)
        let (right, forward) = groundAxes()
        target -= right * pixels.x * unitsPerPixel
        // Screen y moves the view along the ground, stretched by the camera's tilt.
        target += forward * pixels.y * unitsPerPixel * 1.6
    }

    var camera: Camera3D {
        let angle = (Float(rotation) * 90 + 45) * .pi / 180
        let offset = SIMD3<Float>(cos(angle) * 60, 50, sin(angle) * 60)
        let eye = target + offset
        return Camera3D(position: Vector3(x: eye.x, y: eye.y, z: eye.z), target: vector(target),
                        up: Vector3(x: 0, y: 1, z: 0), fovy: span,
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

    func draw(_ scene: LotScene, selected: Int16?, hovered: Int16?) {
        BeginMode3D(camera)
        for box in scene.architecture where box.level <= level {
            draw(box, color: color(of: box), outline: false)
        }
        for box in scene.objects where box.level <= level {
            guard case .object(let id) = box.kind else { continue }
            let color = id == selected ? Theme.accent : id == hovered ? Color(r: 150, g: 200, b: 255, a: 255) : objectColor(id)
            draw(box, color: color, outline: true)
        }
        EndMode3D()
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
    func object(at point: Vector2, in scene: LotScene) -> Int16? {
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
