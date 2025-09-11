// Extensions utility placeholder 
import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }
}

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let syncFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    static let displayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - String Extensions
extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "^[\\+]?[1-9][\\d]{0,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    func truncated(to length: Int) -> String {
        if self.count > length {
            return String(self.prefix(length)) + "..."
        }
        return self
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(Constants.UI.cardCornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func buttonStyle(backgroundColor: Color) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.UI.defaultPadding)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.buttonCornerRadius)
    }
    
    func largeTouchTarget() -> some View {
        self
            .frame(minHeight: Constants.UI.largeTouchTarget)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let appBlue = Constants.UI.Colors.primaryBlue
    static let appGreen = Constants.UI.Colors.successGreen
    static let appOrange = Constants.UI.Colors.warningOrange
    static let appRed = Constants.UI.Colors.errorRed
    static let appGray = Constants.UI.Colors.secondaryGray
}

// MARK: - PassengerStatus Extensions
extension PassengerStatus {
    var displayName: String {
        switch self {
        case .pending:
            return "Pending Pickup"
        case .pickedUp:
            return "On Bus"
        case .droppedOff:
            return "Dropped Off"
        }
    }
    
    var color: Color {
        switch self {
        case .pending:
            return .appOrange
        case .pickedUp:
            return .appBlue
        case .droppedOff:
            return .appGreen
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock"
        case .pickedUp:
            return "figure.walk"
        case .droppedOff:
            return "checkmark.circle.fill"
        }
    }
}

// MARK: - Array Extensions
extension Array where Element == Passenger {
    func limitedTo(_ maxCount: Int) -> [Passenger] {
        return Array(self.prefix(maxCount))
    }
    
    func sortedByScheduledTime() -> [Passenger] {
        return self.sorted { passenger1, passenger2 in
            // Since backend doesn't provide scheduled times, sort by name instead
            return passenger1.name < passenger2.name
        }
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    func setOptional<T: Codable>(_ value: T?, forKey key: String) {
        if let value = value {
            if let encoded = try? JSONEncoder().encode(value) {
                set(encoded, forKey: key)
            }
        } else {
            removeObject(forKey: key)
        }
    }
    
    func getOptional<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var displayName: String {
        return infoDictionary?["CFBundleDisplayName"] as? String ?? "EVV Transport"
    }
}
