// These run without a window. Measuring text needs the font a window loads, so the checks
// here stay with what doesn't draw: the camera's math and what the text boxes accept.

import NSOInterface
import Raylib
import Testing

@Test func cameraRoundTripsBetweenScreenAndWorld() {
    let camera = NSOInterface.Camera(2)
    camera.setScreenSize(800, 600)
    camera.centerOn(Vector2(x: 100, y: 50))
    let screen = Vector2(x: 123, y: 456)
    let back = camera.worldToScreen(camera.screenToWorld(screen))
    #expect(abs(back.x - screen.x) < 0.001 && abs(back.y - screen.y) < 0.001)
    #expect(camera.worldToScreen(Vector2(x: 100, y: 50)) == Vector2(x: 400, y: 300))
}

@Test func cameraZoomStaysInItsRange() {
    let camera = NSOInterface.Camera(100)
    #expect(camera.zoom == NSOInterface.Camera.maxZoom)
    camera.setZoom(0)
    #expect(camera.zoom == NSOInterface.Camera.minZoom)
}

@Test func cameraZoomKeepsThePointUnderThePointerStill() {
    let camera = NSOInterface.Camera()
    camera.setScreenSize(800, 600)
    let pointer = Vector2(x: 200, y: 100)
    let before = camera.screenToWorld(pointer)
    camera.zoomAt(pointer, 1)
    let after = camera.screenToWorld(pointer)
    #expect(abs(before.x - after.x) < 0.001 && abs(before.y - after.y) < 0.001)
}

@Test func cameraCentersAWorldSmallerThanTheScreen() {
    let camera = NSOInterface.Camera()
    camera.setScreenSize(800, 600)
    camera.clampTo(200, 100)
    #expect(camera.target == Vector2(x: 100, y: 50))
}

@Test func textFieldTakesOnlyWhatItAccepts() {
    let digits = TextField("a1b2c3", 4, { $0.isNumber })
    #expect(digits.text == "123")
    let short = TextField("abcdef", 3, { _ in true })
    #expect(short.text == "abc")
    // Raylib's default font draws printable ASCII only.
    let ascii = TextField("héllo~\u{7F}", 10, { _ in true })
    #expect(ascii.text == "hllo~")
}

@Test func textAreaKeepsItsLimit() {
    let area = TextArea("one two three", 7, 20, 200)
    #expect(area.text == "one two")
}

@Test func windowContentSitsBelowTheTitleBar() {
    let content = WindowFrame.content(Rectangle(x: 10, y: 20, width: 300, height: 200))
    #expect(content == Rectangle(x: 10, y: 20 + Float(WindowFrame.titleHeight), width: 300, height: 200 - Float(WindowFrame.titleHeight)))
    let tiny = WindowFrame.content(Rectangle(x: 0, y: 0, width: 50, height: 10))
    #expect(tiny.height == 0)
}

@Test func windowTitlesCanBeRenamed() {
    let frame = WindowFrame("Lot")
    frame.title = "Neighborhood"
    #expect(frame.title == "Neighborhood")
    #expect(!frame.isEditingTitle)
}
