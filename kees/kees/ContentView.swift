import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var uiState: UIState // Access the shared UIState
    
    @State private var selectedCategory: String? // For sidebar selection
    
    // Access the AppStorage variable for theme preference
    @AppStorage("appTheme") var appTheme: AppTheme = .system

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedCategory) {
                Section("General") {
                    Label("All Keys", systemImage: "list.bullet")
                        .tag("All Keys")
                    Label("Recently Used", systemImage: "clock.arrow.circlepath")
                        .tag("Recently Used")
                    Label("Favorites", systemImage: "heart.fill")
                        .tag("Favorites")
                }
                
                Section("Filters") {
                     Text("Tag Filters Placeholder")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Section("Settings") {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                }
            }
            .navigationTitle("Kees")
            .listStyle(SidebarListStyle())
        } detail: {
            // Main Content Panel
            VStack {
                if let category = selectedCategory {
                    Text("Displaying: \(category)")
                        .font(.title)
                } else {
                    Text("Select a category or filter to see API Keys")
                        .font(.title)
                        .foregroundColor(.secondary)
                    // Placeholder for API Key list/grid will go here
                }
            }
            .navigationTitle(selectedCategory ?? "Overview")
            .toolbar {
                ToolbarItem(placement: .primaryAction) { // Primary action for macOS often on the right
                    Button {
                        uiState.showingAddKeySheet = true
                    } label: {
                        Label("Add API Key", systemImage: "plus.circle.fill")
                    }
                    .help("Add New API Key (Cmd+N)")
                }
            }
        }
        .sheet(isPresented: $uiState.showingAddKeySheet) {
            APIKeyEntryView()
                .environment(\.managedObjectContext, self.viewContext)
                // Pass other environment objects if APIKeyEntryView needs them, e.g., uiState
                // .environmentObject(uiState) // Only if APIKeyEntryView needs to dismiss itself or modify shared state
        }
    }
}

#Preview {
    // Preview with the Core Data context and UIState
    ContentView()
        .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
        .environmentObject(UIState()) // Provide a dummy UIState for preview
}
