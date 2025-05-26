import CoreData

class CoreDataStack {
    static let shared = CoreDataStack() // Singleton for easy access

    // The name of the Core Data model file without the .xcdatamodeld extension.
    private let modelName = "KeesDataModel"

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        // Load persistent stores
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // This is a serious error and should be handled appropriately in a production app.
                // For example, by logging the error, displaying an alert, or terminating the app.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // Helper function to save the context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Again, handle errors appropriately in a production app.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // Optional: Helper for fetching
    // func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
    //     do {
    //         return try viewContext.fetch(request)
    //     } catch {
    //         print("Failed to fetch: \(error)")
    //         return []
    //     }
    // }

    // MARK: - Preview Specific Stack
    #if DEBUG
    static var preview: CoreDataStack = {
        let result = CoreDataStack(inMemory: true)
        let viewContext = result.persistentContainer.viewContext
        // Optional: Add sample data for previews here if desired
        // For example, create a few StoredAPIKey instances for global preview use.
        // let key1 = StoredAPIKey(context: viewContext)
        // key1.id = UUID()
        // key1.name = "Preview Key 1"
        // key1.keyValue = "preview123"
        // key1.creationDate = Date()
        // do {
        //     try viewContext.save()
        // } catch {
        //     let nsError = error as NSError
        //     fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        // }
        return result
    }()

    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: modelName)
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    #endif
}
