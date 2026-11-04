import Raylib

/// NewSO's interface colors, which the windows and controls from CityLimits draw with.
///
/// CityLimits' `Theme` (CityLimits.Interface/Rendering/Theme.cs) also holds its map's tile
/// colors; this one has only the interface's, which start out the same as CityLimits'.
public enum Theme {
    /// The highlight: a selected item, a focused field, a title the pointer is over.
    public static let accent = Color(r: 240, g: 190, b: 90, a: 255)
    /// The background of text fields and bars.
    public static let bar = Color(r: 0, g: 0, b: 0, a: 255)
    /// A window's close button.
    public static let closeButton = Color(r: 236, g: 95, b: 86, a: 255)
    /// The x drawn on the close button while the pointer is over it.
    public static let closeMark = Color(r: 90, g: 20, b: 16, a: 255)
    /// The shade laid over the screen behind a pop-up.
    public static let dim = Color(r: 0, g: 0, b: 0, a: 140)
    /// Text saying what's wrong, such as a title that can't be used.
    public static let error = Color(r: 232, g: 106, b: 96, a: 255)
    /// A window's body.
    public static let panel = Color(r: 22, g: 26, b: 32, a: 225)
    /// The edges of windows, fields, and buttons.
    public static let panelBorder = Color(r: 72, g: 80, b: 92, a: 255)
    /// Ordinary text.
    public static let text = Color(r: 228, g: 232, b: 238, a: 255)
    /// Text that matters less, or can't be used right now.
    public static let textDim = Color(r: 150, g: 158, b: 170, a: 255)
    /// A window's title bar.
    public static let titleBar = Color(r: 38, g: 43, b: 52, a: 245)
    /// The selected item of a window's toolbar.
    public static let toolbarSelected = Color(r: 58, g: 66, b: 80, a: 255)
}
