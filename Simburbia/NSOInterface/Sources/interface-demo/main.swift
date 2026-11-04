// A window with the interface's controls, to look at them and try them by hand.
//
// Usage: interface-demo [--screenshot <file.png>]
//
// With --screenshot it draws a few frames in a hidden window, saves the last one, and quits,
// so a change can be checked without anyone at the screen.

import Foundation
import NSOInterface
import Raylib

var screenshot: String?
var arguments = CommandLine.arguments.dropFirst()
while let argument = arguments.popFirst() {
    guard argument == "--screenshot", let path = arguments.popFirst() else {
        FileHandle.standardError.write(Data("usage: interface-demo [--screenshot <file.png>]\n".utf8))
        exit(2)
    }
    screenshot = path
}

SetTraceLogLevel(.warning)
SetConfigFlags(screenshot == nil ? [.windowResizable, .vsyncHint] : [.windowHidden])
InitWindow(960, 600, "NewSO interface")
SetTargetFPS(60)

let frame = WindowFrame("Lot Settings")
frame.titleEditable = true
frame.toolbar = ["General", "Roommates"]
frame.selectedTool = 0
let name = TextField("Sunrise Crater", 32, { _ in true })
let description = TextArea("A quiet lot by the sea, with room for four roommates.", 200, 16, 380)
// ConfirmPanel keeps no open state: it's updated and drawn only while it asks something.
enum Question { case close, apply }
let confirm = ConfirmPanel()
var asking: Question?
let notice = NoticePanel()
let buttons = ["Cancel", "Apply"]
var focusOnName = true

var frames = 0
var running = true
while running && !WindowShouldClose() {
    let bounds = frame.place(Vector2(x: 420, y: 300), Vector2(x: 60, y: 60))
    let content = WindowFrame.content(bounds)
    let nameBox = Rectangle(x: content.x + 10, y: content.y + 34, width: content.width - 20, height: Float(name.boxHeight))
    let descriptionBox = Rectangle(x: content.x + 10, y: nameBox.y + nameBox.height + 30, width: content.width - 20, height: Float(description.heightFor(4)))
    let corner = Vector2(x: content.x + content.width - 10, y: content.y + content.height - 10)
    let mouse = GetMousePosition()

    if let question = asking {
        switch confirm.update() {
        case .yes:
            asking = nil
            if question == .close {
                running = false
            } else {
                notice.show("Saved", "\(name.text) is saved.")
            }
        case .no:
            asking = nil
        default:
            break
        }
    } else if !notice.isOpen {
        _ = frame.followPointer(bounds)
        switch frame.update(bounds) {
        case .close:
            confirm.ask("Close", "Close the lot settings without saving?", "Close", "Keep")
            asking = .close
        case .toolbar: frame.selectedTool = frame.clickedTool
        default: break
        }
        if IsMouseButtonPressed(.left) {
            if CheckCollisionPointRec(mouse, nameBox) { focusOnName = true }
            if CheckCollisionPointRec(mouse, descriptionBox) { focusOnName = false }
            if ButtonRow.buttonAt(mouse, corner, buttons) == 1 {
                confirm.ask("Apply", "Save the changes to \(name.text)?", "Save", "Back")
                asking = .apply
            }
        }
        _ = focusOnName ? name.update() : description.update()
    }
    _ = notice.update()

    BeginDrawing()
    ClearBackground(Color(r: 54, g: 84, b: 120, a: 255))
    frame.draw(bounds)
    DrawText("Name", Int(content.x) + 10, Int(content.y) + 12, 16, Theme.textDim)
    name.draw(nameBox, focusOnName)
    DrawText("Description", Int(content.x) + 10, Int(nameBox.y + nameBox.height) + 8, 16, Theme.textDim)
    description.draw(descriptionBox, !focusOnName)
    ButtonRow.draw(corner, buttons, mouse)
    if asking != nil { confirm.draw() }
    notice.draw()
    EndDrawing()

    frames += 1
    if let screenshot, frames == 3 {
        // TakeScreenshot only writes into the working directory; this takes any path.
        let image = LoadImageFromScreen()
        let saved = ExportImage(image, screenshot)
        UnloadImage(image)
        CloseWindow()
        exit(saved ? 0 : 1)
    }
}
CloseWindow()
