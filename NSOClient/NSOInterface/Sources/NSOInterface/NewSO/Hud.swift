import Raylib

/// The screen's heads-up display, as far as the windows from CityLimits need to know it.
///
/// CityLimits keeps windows above its bottom bar; NewSO has no bar yet, so a window may use
/// the whole height of the screen.
public enum Hud {
    /// The top of the bar along the bottom of the screen, which windows stay above.
    public static func barTop() -> Int {
        Int(GetScreenHeight())
    }
}
