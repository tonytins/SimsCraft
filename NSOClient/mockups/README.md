# Mockups

The owner's interface designs for NewSO, drawn in a Figma-like app. Each comes as the design
(`.figcraft`, a zip of the app's JSON document) and SVG and PNG exports to view without the app.
They're rough sketches of layout and intent, not to scale and not a literal picture of TSO's
interface; the client follows what they lay out, in raylib's built-in font.

| Mockup | What it shows | In the client |
|---|---|---|
| `prototype-interface` | The top bar (lot name, speed, time, money, floor, error count, object count, a help button), the help window it opens, and MOMI, the system-message window the error count opens. It doubles as NewSO's fallback or debug interface. | `NSOClient/Client/Sources/newso/TopBar.swift` (the bar, `HelpWindow`, `MomiWindow`) and `SystemMessages` in LotScene. Money waits for money to exist; MOMI's input stays disabled until online play. |

The SVG export leaves out the design's white notes, which show only on the app's dark canvas.
