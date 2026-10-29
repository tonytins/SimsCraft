# Mockups

The owner's interface designs for NewSO, drawn in a Figma-like app. Each comes as the design
(`.figcraft`, a zip of the app's JSON document) and an SVG export to view without the app.
They're rough sketches of layout and intent, not to scale and not a literal picture of TSO's
interface; the client follows what they lay out, in raylib's built-in font.

| Mockup | What it shows | In the client |
|---|---|---|
| `prototype-interface` | The top bar (lot name, speed, time, money, floor, object count, a help button) and the help window it opens. It doubles as NewSO's fallback or debug interface. | `NSOClient/Client/Sources/newso/TopBar.swift`. Money waits for money to exist; the error count sits between the floor and the object count. |

The SVG export leaves out the design's white notes, which show only on the app's dark canvas.
