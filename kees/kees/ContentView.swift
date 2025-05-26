import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var uiState: UIState // Access the shared UIState
    
    @State private var selectedCategory: String? // For sidebar selection
    
    // Access the AppStorage variable for theme preference
    @AppStorage("appTheme") var appTheme: AppTheme = .system

    // Enum for filter types
    enum FilterType: String, CaseIterable, Identifiable {
        case all = "All Keys"
        case favorites = "Favorites"
        case recentlyUsed = "Recently Used" // Corrected: "Recently Used" as per sidebar labels
        var id: String { self.rawValue }
    }
    @State private var currentFilter: FilterType = .all // State for current filter

    // FetchRequest to get all StoredAPIKey entities, sorted by creationDate descending
    // This remains the primary source of truth from Core Data.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoredAPIKey.creationDate, ascending: false)],
        animation: .default)
    private var apiKeys: FetchedResults<StoredAPIKey>

    // Computed property to filter keys based on the currentFilter state
    private var filteredApiKeys: [StoredAPIKey] {
        switch currentFilter {
        case .all:
            return Array(apiKeys)
        case .favorites:
            return apiKeys.filter { $0.isFavorite }
        case .recentlyUsed:
            // For now, "Recently Used" shows all keys sorted by creation date.
            // Future enhancement could be to filter by a 'lastAccessedDate' or limit to top N.
            return Array(apiKeys)
        }
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedCategory) {
                // Section("General") { // These are now effectively handled by the Picker
                //     Label("All Keys", systemImage: "list.bullet")
                //         .tag("All Keys")
                //     Label("Recently Used", systemImage: "clock.arrow.circlepath")
                //         .tag("Recently Used")
                //     Label("Favorites", systemImage: "heart.fill")
                //         .tag("Favorites")
                // }
                
                Section("Filter Keys") { // Changed section title
                    Picker("Filter", selection: $currentFilter) {
                        ForEach(FilterType.allCases) { filterValue in
                            Text(filterValue.rawValue).tag(filterValue) // Use rawValue for display
                        }
                    }
                    .pickerStyle(.inline) // Or .menu for a dropdown style in sidebar
                    
                    // Placeholder for tag filters can go here later
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
            // Main Content Panel - Displaying the list of API Keys
            // For now, this always shows all keys. Filtering based on selectedCategory can be added later.
            if filteredApiKeys.isEmpty {
                VStack {
                    // Dynamic empty state message based on current filter
                    let emptyMessage = "No API keys found"
                    let filterSpecificMessage: String
                    switch currentFilter {
                    case .all:
                        filterSpecificMessage = emptyMessage + "."
                    case .favorites:
                        filterSpecificMessage = "No favorite API keys found."
                    case .recentlyUsed:
                        filterSpecificMessage = "No recently used API keys found (or feature not fully implemented)."
                    }
                    Text(filterSpecificMessage)
                        .font(.title)
                    Text("Add one using the '+' button or Cmd+N.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(filteredApiKeys) { apiKey in
                        APIKeyRowView(apiKey: apiKey)
                    }
                    .onDelete(perform: deleteAPIKeys) // Enable swipe-to-delete
                }
                // .listStyle(.plain) // Optional: for a different list appearance
            }
            .navigationTitle(currentFilter.rawValue) // Dynamic title based on current filter
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
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
        .onAppear {
            // Schedule notifications when the ContentView appears.
            // This will be called each time the view appears, which might be too frequent for some scenarios,
            // but for this basic implementation, it ensures notifications are re-evaluated.
            // A more advanced implementation might limit this to once per app launch or use background tasks.
            NotificationManager.shared.scheduleExpirationNotifications(using: viewContext, daysBefore: 7)
        }
    }

    private func deleteAPIKeys(offsets: IndexSet) {
        withAnimation { // Animates the row deletion
            // Important: The offsets are for 'filteredApiKeys'.
            // We need to delete the actual objects from the viewContext.
            let keysToDelete = offsets.map { filteredApiKeys[$0] }
            keysToDelete.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // In a shipping application, you might want to present an error message to the user.
                let nsError = error as NSError
                print("Unresolved error deleting API key(s): \(nsError), \(nsError.userInfo)")
                // For example, you could set a state variable to show an alert.
                // self.showingDeleteErrorAlert = true
            }
        }
    }
}

#Preview {
    // Preview with the Core Data context and UIState
    ContentView()
        .environment(\.managedObjectContext, CoreDataStack.preview.container.viewContext) // Use preview context
        .environmentObject(UIState()) // Provide a dummy UIState for preview
}
