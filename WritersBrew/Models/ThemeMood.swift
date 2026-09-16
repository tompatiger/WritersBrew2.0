import SwiftUI
import AppKit

/// Curated writing moods that subtly adjust ambient tint, editor contrast, and typography feel.
public enum ThemeMood: String, CaseIterable, Identifiable, Codable {
    case system = "System"
    case deepFocus = "Deep Focus"
    case creativeWarmth = "Creative Warmth"
    case nightOil = "Night Oil"
    case paperInk = "Paper & Ink"
    
    public var id: String { rawValue }
    
    public var subtitle: String {
        switch self {
        case .system:
            return "Adapts seamlessly to macOS light & dark modes"
        case .deepFocus:
            return "Midnight indigo, zero visual clutter for intense flow"
        case .creativeWarmth:
            return "Warm golden amber, soft parchment glow"
        case .nightOil:
            return "Rich charcoal sepia, gentle for late-night sessions"
        case .paperInk:
            return "Timeless monochrome, stark and elegant"
        }
    }
    
    public var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .deepFocus: return "moon.stars.fill"
        case .creativeWarmth: return "flame.fill"
        case .nightOil: return "lamp.desk.fill"
        case .paperInk: return "doc.text.fill"
        }
    }
    
    public var forcedColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .deepFocus, .creativeWarmth, .nightOil, .paperInk:
            return .dark
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .system:
            return Color.accentColor
        case .deepFocus:
            return Color(red: 0.42, green: 0.62, blue: 1.00)
        case .creativeWarmth:
            return Color(red: 0.94, green: 0.65, blue: 0.28)
        case .nightOil:
            return Color(red: 0.88, green: 0.70, blue: 0.44)
        case .paperInk:
            return Color(red: 0.90, green: 0.90, blue: 0.90)
        }
    }
    
    public var textColor: Color {
        switch self {
        case .system:
            return Color.primary
        case .deepFocus:
            return Color(red: 0.92, green: 0.94, blue: 0.98)
        case .creativeWarmth:
            return Color(red: 0.96, green: 0.92, blue: 0.84)
        case .nightOil:
            return Color(red: 0.90, green: 0.86, blue: 0.80)
        case .paperInk:
            return Color(red: 0.98, green: 0.98, blue: 0.98)
        }
    }
    
    public var secondaryTextColor: Color {
        switch self {
        case .system:
            return Color.secondary
        case .deepFocus:
            return Color(red: 0.62, green: 0.68, blue: 0.80)
        case .creativeWarmth:
            return Color(red: 0.76, green: 0.70, blue: 0.60)
        case .nightOil:
            return Color(red: 0.68, green: 0.64, blue: 0.58)
        case .paperInk:
            return Color(red: 0.65, green: 0.65, blue: 0.65)
        }
    }
    
    public var canvasBackground: Color {
        switch self {
        case .system:
            return Color(nsColor: .windowBackgroundColor)
        case .deepFocus:
            return Color(red: 0.05, green: 0.06, blue: 0.11)
        case .creativeWarmth:
            return Color(red: 0.13, green: 0.11, blue: 0.09)
        case .nightOil:
            return Color(red: 0.09, green: 0.09, blue: 0.09)
        case .paperInk:
            return Color(red: 0.04, green: 0.04, blue: 0.04)
        }
    }
    
    public var editorBackgroundColor: Color {
        switch self {
        case .system:
            return Color(nsColor: .textBackgroundColor).opacity(0.7)
        case .deepFocus:
            return Color(red: 0.07, green: 0.08, blue: 0.14)
        case .creativeWarmth:
            return Color(red: 0.16, green: 0.14, blue: 0.11)
        case .nightOil:
            return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .paperInk:
            return Color(red: 0.07, green: 0.07, blue: 0.07)
        }
    }
    
    public var nsTextColor: NSColor {
        switch self {
        case .system:
            return .labelColor
        case .deepFocus:
            return NSColor(calibratedRed: 0.92, green: 0.94, blue: 0.98, alpha: 1.0)
        case .creativeWarmth:
            return NSColor(calibratedRed: 0.96, green: 0.92, blue: 0.84, alpha: 1.0)
        case .nightOil:
            return NSColor(calibratedRed: 0.90, green: 0.86, blue: 0.80, alpha: 1.0)
        case .paperInk:
            return NSColor(calibratedRed: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        }
    }
    
    public var nsSecondaryTextColor: NSColor {
        switch self {
        case .system:
            return .secondaryLabelColor
        case .deepFocus:
            return NSColor(calibratedRed: 0.62, green: 0.68, blue: 0.80, alpha: 1.0)
        case .creativeWarmth:
            return NSColor(calibratedRed: 0.76, green: 0.70, blue: 0.60, alpha: 1.0)
        case .nightOil:
            return NSColor(calibratedRed: 0.68, green: 0.64, blue: 0.58, alpha: 1.0)
        case .paperInk:
            return NSColor(calibratedRed: 0.65, green: 0.65, blue: 0.65, alpha: 1.0)
        }
    }
    
    public var nsInsertionPointColor: NSColor {
        switch self {
        case .system:
            return .controlAccentColor
        case .deepFocus:
            return NSColor(calibratedRed: 0.42, green: 0.62, blue: 1.00, alpha: 1.0)
        case .creativeWarmth:
            return NSColor(calibratedRed: 0.94, green: 0.65, blue: 0.28, alpha: 1.0)
        case .nightOil:
            return NSColor(calibratedRed: 0.88, green: 0.70, blue: 0.44, alpha: 1.0)
        case .paperInk:
            return NSColor.white
        }
    }
    
    public var preferredDesign: Font.Design {
        switch self {
        case .system, .deepFocus: return .default
        case .creativeWarmth, .paperInk: return .serif
        case .nightOil: return .serif
        }
    }
}
