import SwiftUI

struct APIKeyEntryView: View {
    // State variables for form inputs
    @State private var name: String = ""
    @State private var keyValue: String = ""
    @State private var descriptionText: String = ""
    @State private var usageLocation: String = ""
    @State private var tagsInput: String = "" // Comma-separated tags
    @State private var creationDate: Date = Date()
    
    // State for expiration date
    @State private var hasExpirationDate: Bool = false
    @State private var expirationDateInput: Date = Date() // Default to today, shown if hasExpirationDate is true
    @State private var isFavoriteState: Bool = false // State for favorite toggle

    // Optional property for an existing key being edited (nil for new keys)
    var apiKeyToEdit: StoredAPIKey? // Changed to StoredAPIKey

    // Environment variables
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Key Details")) {
                    TextField("Name", text: $name)
                    TextField("API Key Value", text: $keyValue)
                    DatePicker("Creation Date", selection: $creationDate, displayedComponents: .date)
                }

                Section(header: Text("Optional Information")) {
                    TextField("Description", text: $descriptionText)
                    TextField("Usage Location/Project", text: $usageLocation)
                    TextField("Tags (comma-separated)", text: $tagsInput)
                        .disableAutocorrection(true)
                    
                    Toggle("Set Expiration Date", isOn: $hasExpirationDate.animation())
                    if hasExpirationDate {
                        DatePicker("Expiration Date", selection: $expirationDateInput, in: Date()..., displayedComponents: .date)
                    }
                    Toggle("Favorite", isOn: $isFavoriteState) // Added Favorite toggle
                }
            }
            .navigationTitle(apiKeyToEdit == nil ? "Add API Key" : "Edit API Key")
            .onAppear {
                if let key = apiKeyToEdit {
                    name = key.name ?? ""
                    keyValue = key.keyValue ?? ""
                    creationDate = key.creationDate ?? Date() // Use actual creation date
                    descriptionText = key.descriptionText ?? ""
                    usageLocation = key.usageLocation ?? ""
                    isFavoriteState = key.isFavorite // Set favorite state
                    // Convert NSArray (from Core Data) to [String] then to comma-separated String
                    if let tagsArray = key.tags as? [String] {
                        tagsInput = tagsArray.joined(separator: ", ")
                    } else {
                        tagsInput = ""
                    }
                    
                    if let expDate = key.expirationDate {
                        hasExpirationDate = true
                        expirationDateInput = expDate
                    } else {
                        hasExpirationDate = false
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveKey()
                    }
                }
            }
        }
    }

    private func saveKey() {
        let keyToSave: StoredAPIKey
        if let existingKey = apiKeyToEdit {
            keyToSave = existingKey
        } else {
            keyToSave = StoredAPIKey(context: viewContext)
            keyToSave.id = UUID() // Set ID for new keys
            // creationDate is already managed by @State, will be assigned below
        }

        keyToSave.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        keyToSave.keyValue = keyValue.trimmingCharacters(in: .whitespacesAndNewlines)
        keyToSave.creationDate = creationDate // Ensure this @State var is used
        keyToSave.descriptionText = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        keyToSave.usageLocation = usageLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : usageLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let processedTags = tagsInput.split(separator: ",")
                                     .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                     .filter { !$0.isEmpty }
        keyToSave.tags = processedTags.isEmpty ? nil : (processedTags as NSArray)

        if hasExpirationDate {
            keyToSave.expirationDate = expirationDateInput
        } else {
            keyToSave.expirationDate = nil
        }
        
        keyToSave.isFavorite = isFavoriteState // Save favorite state

        do {
            try viewContext.save()
            dismiss()
        } catch {
            // Handle the Core Data save error (e.g., show an alert to the user)
            print("Failed to save API key: \(error.localizedDescription)")
            // Optionally, present an alert to the user here
        }
    }
}

#if DEBUG
struct APIKeyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = CoreDataStack.preview.container.viewContext

        // Sample StoredAPIKey for editing preview (Favorite)
        let sampleKeyToEditFav = StoredAPIKey(context: previewContext)
        sampleKeyToEditFav.id = UUID()
        sampleKeyToEditFav.name = "Test Key to Edit (Favorite)"
        sampleKeyToEditFav.keyValue = "editThisKeyFav123"
        sampleKeyToEditFav.creationDate = Date()
        sampleKeyToEditFav.tags = ["editing", "sample", "fav"] as NSArray
        sampleKeyToEditFav.expirationDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        sampleKeyToEditFav.isFavorite = true
        
        // Sample StoredAPIKey for editing preview (Not Favorite)
        let sampleKeyToEditNotFav = StoredAPIKey(context: previewContext)
        sampleKeyToEditNotFav.id = UUID()
        sampleKeyToEditNotFav.name = "Test Key to Edit (Not Fav)"
        sampleKeyToEditNotFav.keyValue = "editThisKeyNotFav456"
        sampleKeyToEditNotFav.creationDate = Date()
        sampleKeyToEditNotFav.isFavorite = false


        return Group {
            // Preview for adding a new key
            APIKeyEntryView()
                .environment(\.managedObjectContext, previewContext)
                .previewDisplayName("Add New Key")

            // Preview for editing an existing favorite key
            APIKeyEntryView(apiKeyToEdit: sampleKeyToEditFav)
                .environment(\.managedObjectContext, previewContext)
                .previewDisplayName("Edit Favorite Key")
                
            // Preview for editing an existing non-favorite key
            APIKeyEntryView(apiKeyToEdit: sampleKeyToEditNotFav)
                .environment(\.managedObjectContext, previewContext)
                .previewDisplayName("Edit Non-Favorite Key")
        }
    }
}
#endif
