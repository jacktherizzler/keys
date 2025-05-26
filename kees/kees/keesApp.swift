import SwiftUI
import CoreData
import UserNotifications // Import UserNotifications

@main
struct keesApp: App {
    // Access the AppStorage variable for theme preference
    @AppStorage("appTheme") var appTheme: AppTheme = .system // Default to system

    // Initialize the Core Data stack
    let coreDataStack = CoreDataStack.shared

    // Initialize UIState for managing global UI states like sheet presentation
    @StateObject var uiState = UIState()

    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the managed object context into the environment
                .environment(\.managedObjectContext, coreDataStack.viewContext)
                // Inject the UIState object into the environment
                .environmentObject(uiState)
                // Apply the selected theme
                .preferredColorScheme(appTheme == .light ? .light : (appTheme == .dark ? .dark : nil))
        }
        // Add commands to the application's main menu
        .commands {
            CommandGroup(replacing: .newItem) { // Replaces the standard "File > New" item
                Button("Add New API Key") {
                    uiState.showingAddKeySheet = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied with error: \(error.localizedDescription)")
            } else {
                print("Notification permission denied (no error specified).")
            }
        }
    }
}
