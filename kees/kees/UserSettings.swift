import SwiftUI // For AppStorage

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { self.rawValue } // Conformance to Identifiable

    // Optional: A more descriptive name for UI if needed, but rawValue is fine for Picker
    var displayName: String {
        self.rawValue
    }
}

// Global AppStorage variable for theme preference
// This can be accessed from anywhere in the app.
// Note: If you prefer to manage this within a class, you could create an ObservableObject.
// For a simple setting like theme, a global AppStorage is often straightforward.
struct UserSettings {
    @AppStorage("appTheme") static var appTheme: AppTheme = .system
}
