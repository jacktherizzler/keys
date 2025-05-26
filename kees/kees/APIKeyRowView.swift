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
                HStack {
                    Text(apiKey.name ?? "Untitled Key")
                        .font(.headline)
                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: apiKey.isFavorite ? "star.fill" : "star")
                            .foregroundColor(apiKey.isFavorite ? .yellow : .gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help(apiKey.isFavorite ? "Remove from favorites" : "Add to favorites")
                }
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
    }
    
    private func toggleFavorite() {
        apiKey.isFavorite.toggle()
        do {
            try apiKey.managedObjectContext?.save()
        } catch {
            // Handle save error, e.g., log it or show an alert
            print("Failed to save favorite status: \(error.localizedDescription)")
        }
    }
}

// Preview requires a mock StoredAPIKey instance and a Core Data context.
#if DEBUG
struct APIKeyRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Use the preview-specific Core Data context
        let context = CoreDataStack.preview.container.viewContext
        
        // Create a sample StoredAPIKey for preview
        let sampleKey1 = StoredAPIKey(context: context)
        sampleKey1.id = UUID()
        sampleKey1.name = "My Test API Key (Favorite)"
        sampleKey1.keyValue = "abcdef123456ghijkl7890uvwxyz"
        sampleKey1.creationDate = Date()
        sampleKey1.descriptionText = "This is a sample key for preview with a relatively long name and key value to test truncation and layout."
        sampleKey1.tags = ["test", "preview", "sample", "long-tag-name-example"] as NSArray
        sampleKey1.expirationDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())
        sampleKey1.isFavorite = true

        let sampleKey2 = StoredAPIKey(context: context)
        sampleKey2.id = UUID()
        sampleKey2.name = "Short Key (Not Favorite)"
        sampleKey2.keyValue = "short"
        sampleKey2.creationDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        sampleKey2.isFavorite = false
        // No description, tags, or expiration for this one to test optional handling
        
        return Group {
            APIKeyRowView(apiKey: sampleKey1)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Favorite Key Example")

            APIKeyRowView(apiKey: sampleKey2)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Not Favorite Key Example")
            
            // Example of the key shown
            APIKeyRowView(apiKey: sampleKey1, showFullKey: true)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Favorite Key Shown")
        }
        .environment(\.managedObjectContext, context) // Inject preview context
    }
}
#endif
