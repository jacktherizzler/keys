import SwiftUI
import CoreData // For StoredAPIKey

struct APIKeyRowView: View {
    @ObservedObject var apiKey: StoredAPIKey
    @State private var showFullKey: Bool = false

    private var displayedKeyValue: String {
        guard let keyValue = apiKey.keyValue else { return "No Key" }
        if showFullKey {
            return keyValue
        } else {
            // Simple masking: first 4, then "••••", then last 4 if length allows
            if keyValue.count > 8 {
                return "\(keyValue.prefix(4))••••\(keyValue.suffix(4))"
            } else if keyValue.count > 0 {
                return "\(keyValue.prefix(1))••••" // very short key
            }
            return "••••••••" // Default mask if very short or empty
        }
    }

    private var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: apiKey.creationDate ?? Date())
    }
    
    private var tagsArray: [String] {
        return (apiKey.tags as? [String]) ?? []
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading) {
                Text(apiKey.name ?? "Untitled Key")
                    .font(.headline)
                HStack {
                    Text(displayedKeyValue)
                        .font(.system(.body, design: .monospaced)) // Monospaced for keys
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Button(showFullKey ? "Hide" : "Show") {
                        showFullKey.toggle()
                    }
                    .buttonStyle(BorderlessButtonStyle()) // Use BorderlessButtonStyle for subtle buttons in lists

                    Button {
                        copyKeyValue()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Copy API Key") // Tooltip
                }
            }

            Spacer() // Pushes content to the left and right edges if needed

            VStack(alignment: .trailing) {
                Text("Created: \(formattedCreationDate)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if !tagsArray.isEmpty {
                    HStack {
                        ForEach(tagsArray, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                    }
                } else {
                    Text("No Tags")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 5) // Add some vertical padding for each row
    }

    private func copyKeyValue() {
        guard let keyValue = apiKey.keyValue else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(keyValue, forType: .string)
        // Optionally, provide feedback to the user (e.g., show a temporary "Copied!" message)
    }
}

// Preview requires a mock StoredAPIKey instance and a Core Data context.
struct APIKeyRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock Core Data context for the preview
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        // Create a sample StoredAPIKey for preview
        let sampleKey = StoredAPIKey(context: context)
        sampleKey.id = UUID()
        sampleKey.name = "My Test API Key"
        sampleKey.keyValue = "abcdef123456ghijkl7890uvwxyz"
        sampleKey.creationDate = Date()
        sampleKey.descriptionText = "This is a sample key for preview."
        sampleKey.tags = ["test", "preview", "sample"] as NSArray // Stored as NSArray

        let emptyKey = StoredAPIKey(context: context)
        emptyKey.id = UUID()
        emptyKey.name = "Another Key"
        emptyKey.keyValue = "short"
        emptyKey.creationDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        
        return Group {
            APIKeyRowView(apiKey: sampleKey)
                .padding()
                .previewLayout(.sizeThatFits)

            APIKeyRowView(apiKey: emptyKey)
                .padding()
                .previewLayout(.sizeThatFits)
            
            // Example of the key shown
            APIKeyRowView(apiKey: sampleKey, showFullKey: true)
                .padding()
                .previewLayout(.sizeThatFits)

        }
        .environment(\.managedObjectContext, context) // Inject context for preview
    }
}
