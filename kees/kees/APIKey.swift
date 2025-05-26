import Foundation

struct APIKey: Identifiable {
    let id: UUID
    var name: String
    var keyValue: String
    let creationDate: Date
    var descriptionText: String?
    var usageLocation: String?
    var tags: [String]?
    var expirationDate: Date? // New optional property

    // Initializer to provide default values for id and creationDate
    init(id: UUID = UUID(), 
         name: String, 
         keyValue: String, 
         creationDate: Date = Date(), 
         descriptionText: String? = nil, 
         usageLocation: String? = nil, 
         tags: [String]? = nil,
         expirationDate: Date? = nil) { // Added to initializer
        self.id = id
        self.name = name
        self.keyValue = keyValue
        self.creationDate = creationDate
        self.descriptionText = descriptionText
        self.usageLocation = usageLocation
        self.tags = tags
        self.expirationDate = expirationDate // Initialize new property
    }
}
