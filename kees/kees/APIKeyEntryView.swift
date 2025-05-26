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

    // Optional property for an existing key being edited (nil for new keys)
    var apiKeyToEdit: APIKey? // Using the non-CoreData APIKey struct for now

    // Environment variable to dismiss the view (e.g., when presented as a sheet)
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
                }
            }
            .navigationTitle(apiKeyToEdit == nil ? "Add API Key" : "Edit API Key")
            .onAppear {
                // If editing an existing key, pre-fill the form fields
                if let key = apiKeyToEdit {
                    name = key.name
                    keyValue = key.keyValue
                    creationDate = key.creationDate
                    descriptionText = key.descriptionText ?? ""
                    usageLocation = key.usageLocation ?? ""
                    tagsInput = (key.tags ?? []).joined(separator: ", ")
                    if let expDate = key.expirationDate {
                        hasExpirationDate = true
                        expirationDateInput = expDate
                    } else {
                        hasExpirationDate = false
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save action to be implemented later
                        print("Save button tapped")
                        print("Name: \(name), Key: \(keyValue), Date: \(creationDate)")
                        print("Description: \(descriptionText), Location: \(usageLocation), Tags: \(tagsInput)")
                        if hasExpirationDate {
                            print("Expiration Date: \(expirationDateInput)")
                        } else {
                            print("No Expiration Date")
                        }
                        // dismiss()
                    }
                }
            }
        }
    }
}

struct APIKeyEntryView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for adding a new key
        APIKeyEntryView()
            .previewDisplayName("Add New Key")

        // Preview for editing an existing key with expiration
        APIKeyEntryView(apiKeyToEdit: APIKey(name: "Test Key with Expiry", 
                                             keyValue: "12345abcdef", 
                                             descriptionText: "A test API key.", 
                                             usageLocation: "Test Project", 
                                             tags: ["test", "example"],
                                             expirationDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())))
            .previewDisplayName("Edit Key with Expiry")
        
        // Preview for editing an existing key without expiration
        APIKeyEntryView(apiKeyToEdit: APIKey(name: "Test Key No Expiry",
                                             keyValue: "67890uvwxyz",
                                             descriptionText: "Another test key."))
            .previewDisplayName("Edit Key No Expiry")
    }
}
