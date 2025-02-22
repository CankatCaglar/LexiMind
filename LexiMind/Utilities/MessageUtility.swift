import SwiftUI
import SwiftMessages

// MARK: - Message Type
public enum MessageType {
    case success
    case error
    case warning
    case info
    
    public var icon: UIImage {
        switch self {
        case .success:
            return UIImage(systemName: "checkmark.circle.fill")!
        case .error:
            return UIImage(systemName: "xmark.circle.fill")!
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle.fill")!
        case .info:
            return UIImage(systemName: "info.circle.fill")!
        }
    }
    
    public var backgroundColor: UIColor {
        switch self {
        case .success:
            return .systemGreen
        case .error:
            return .systemRed
        case .warning:
            return .systemYellow
        case .info:
            return .systemBlue
        }
    }
    
    public var textColor: UIColor {
        switch self {
        case .warning:
            return .black
        default:
            return .white
        }
    }
}

// MARK: - Message Utility
@MainActor
public class MessageUtility {
    public static func showMessage(
        title: String,
        message: String,
        theme: Theme,
        type: MessageType = .info
    ) {
        Task { @MainActor in
            let view = MessageView.viewFromNib(layout: .cardView)
            
            // Configure theme colors
            view.configureTheme(
                backgroundColor: UIColor(theme.backgroundColor),
                foregroundColor: UIColor(theme.primaryColor),
                iconImage: type.icon,
                iconText: nil
            )
            
            // Configure content
            view.configureContent(
                title: title,
                body: message,
                iconImage: type.icon,
                iconText: nil,
                buttonImage: nil,
                buttonTitle: nil,
                buttonTapHandler: nil
            )
            
            view.button?.isHidden = true
            
            // Show the message
            SwiftMessages.show(view: view)
        }
    }
    
    public static func showSuccess(
        title: String = "Başarılı",
        message: String,
        theme: Theme
    ) {
        showMessage(title: title, message: message, theme: theme, type: .success)
    }
    
    public static func showError(
        title: String = "Hata",
        message: String,
        theme: Theme
    ) {
        showMessage(title: title, message: message, theme: theme, type: .error)
    }
    
    public static func showWarning(
        title: String = "Uyarı",
        message: String,
        theme: Theme
    ) {
        showMessage(title: title, message: message, theme: theme, type: .warning)
    }
    
    public static func showInfo(
        title: String = "Bilgi",
        message: String,
        theme: Theme
    ) {
        showMessage(title: title, message: message, theme: theme, type: .info)
    }
}

// MARK: - SwiftUI View Extension
public extension View {
    func showMessage(
        title: String,
        message: String,
        theme: Theme,
        type: MessageType = .info
    ) {
        MessageUtility.showMessage(
            title: title,
            message: message,
            theme: theme,
            type: type
        )
    }
    
    func showSuccess(
        title: String = "Başarılı",
        message: String,
        theme: Theme
    ) {
        MessageUtility.showSuccess(
            title: title,
            message: message,
            theme: theme
        )
    }
    
    func showError(
        title: String = "Hata",
        message: String,
        theme: Theme
    ) {
        MessageUtility.showError(
            title: title,
            message: message,
            theme: theme
        )
    }
    
    func showWarning(
        title: String = "Uyarı",
        message: String,
        theme: Theme
    ) {
        MessageUtility.showWarning(
            title: title,
            message: message,
            theme: theme
        )
    }
    
    func showInfo(
        title: String = "Bilgi",
        message: String,
        theme: Theme
    ) {
        MessageUtility.showInfo(
            title: title,
            message: message,
            theme: theme
        )
    }
} 