import Foundation
import FirebaseFirestore
import SwiftUI

// MARK: - Theme Models
public struct Theme: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let previewImageURL: String?
    public let colors: ThemeColors
    public let isLocked: Bool
    public let unlockRequirement: UnlockRequirement?
    public let isCustom: Bool
    public let customColors: CustomThemeColors?
    
    public init(id: String = UUID().uuidString,
         name: String,
         description: String,
         previewImageURL: String? = nil,
         colors: ThemeColors,
         isLocked: Bool = false,
         unlockRequirement: UnlockRequirement? = nil,
         isCustom: Bool = false,
         customColors: CustomThemeColors? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.previewImageURL = previewImageURL
        self.colors = colors
        self.isLocked = isLocked
        self.unlockRequirement = unlockRequirement
        self.isCustom = isCustom
        self.customColors = customColors
    }
    
    public var primaryColor: Color {
        if let custom = customColors {
            return Color(hex: custom.primary)
        }
        return Color(hex: colors.primary)
    }
    
    public var secondaryColor: Color {
        if let custom = customColors {
            return Color(hex: custom.secondary)
        }
        return Color(hex: colors.secondary)
    }
    
    public var accentColor: Color {
        if let custom = customColors {
            return Color(hex: custom.accent)
        }
        return Color(hex: colors.accent)
    }
    
    public var backgroundColor: Color {
        if let custom = customColors {
            return Color(hex: custom.background)
        }
        return Color(hex: colors.background)
    }
}

extension Theme {
    public static let `default` = Theme(
        id: "default",
        name: "Varsayılan",
        description: "LexiMind'ın varsayılan teması",
        previewImageURL: nil,
        colors: ThemeColors(
            primary: "#58CC02",    // Duolingo green
            secondary: "#1CB0F6",  // Duolingo blue
            accent: "#FF4B4B",     // Duolingo red
            background: "#F7F7F7"  // Duolingo light background
        ),
        isLocked: false,
        unlockRequirement: nil
    )
    
    public static let dark = Theme(
        id: "dark",
        name: "Karanlık",
        description: "Koyu renkli tema",
        previewImageURL: nil,
        colors: ThemeColors(
            primary: "#58CC02",    // Same green
            secondary: "#1CB0F6",  // Same blue
            accent: "#FF4B4B",     // Same red
            background: "#1F1F1F"  // Duolingo dark background
        ),
        isLocked: true,
        unlockRequirement: .premium
    )
}

public struct ThemeColors: Codable {
    public let primary: String
    public let secondary: String
    public let accent: String
    public let background: String
    
    public init(primary: String,
         secondary: String,
         accent: String,
         background: String) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
    }
}

public struct CustomThemeColors: Codable {
    public var primary: String
    public var secondary: String
    public var accent: String
    public var background: String
    
    public init(primary: String,
         secondary: String,
         accent: String,
         background: String) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
    }
}

public enum UnlockRequirement: Codable, Equatable {
    case premium
    case achievement(id: String)
    case level(Int)
    case purchase(gems: Int)
    
    private enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .premium:
            try container.encode("premium", forKey: .type)
        case .achievement(let id):
            try container.encode("achievement", forKey: .type)
            try container.encode(id, forKey: .value)
        case .level(let level):
            try container.encode("level", forKey: .type)
            try container.encode(level, forKey: .value)
        case .purchase(let gems):
            try container.encode("purchase", forKey: .type)
            try container.encode(gems, forKey: .value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "premium":
            self = .premium
        case "achievement":
            let id = try container.decode(String.self, forKey: .value)
            self = .achievement(id: id)
        case "level":
            let level = try container.decode(Int.self, forKey: .value)
            self = .level(level)
        case "purchase":
            let gems = try container.decode(Int.self, forKey: .value)
            self = .purchase(gems: gems)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown unlock requirement type")
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 