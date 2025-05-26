import UserNotifications
import CoreData // For NSManagedObjectContext and StoredAPIKey

class NotificationManager {
    static let shared = NotificationManager() // Singleton for easy access

    private init() {} // Private initializer for singleton

    func scheduleExpirationNotifications(using context: NSManagedObjectContext, daysBefore: Int = 7) {
        let center = UNUserNotificationCenter.current()

        // Check notification settings to ensure we can schedule
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notification authorization not granted. Cannot schedule notifications.")
                // Optionally, guide user to settings if desired
                return
            }

            let fetchRequest: NSFetchRequest<StoredAPIKey> = StoredAPIKey.fetchRequest()
            // Filter for keys that have an expiration date set and are not yet expired
            let now = Date()
            fetchRequest.predicate = NSPredicate(format: "expirationDate != nil AND expirationDate >= %@", now as NSDate)

            do {
                let keysWithFutureExpiration = try context.fetch(fetchRequest)
                
                for apiKey in keysWithFutureExpiration {
                    guard let expirationDate = apiKey.expirationDate, let keyId = apiKey.id?.uuidString, let keyName = apiKey.name else {
                        continue // Skip if essential data is missing
                    }

                    let notificationIdentifier = keyId + "_expiration"
                    
                    // Remove any pending notification for this key first to avoid duplicates or outdated alerts
                    center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

                    // Calculate the trigger date: `daysBefore` the expirationDate, at 9 AM.
                    guard let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: expirationDate) else {
                        continue
                    }
                    
                    // Only schedule if the trigger date is in the future
                    if triggerDate <= now {
                        // If the trigger date is past (e.g., key expires very soon or daysBefore is large),
                        // you might want to handle it differently (e.g., notify immediately or adjust logic).
                        // For now, we'll just skip scheduling if the reminder point is already passed.
                        // Or, if it's already within the 'daysBefore' window but not past, it will be scheduled.
                        // The initial fetch already filters for expirationDate >= now.
                        // This check ensures the *notification trigger point* is in the future.
                        
                        // A more precise check: if the key expires today or in the future, but the trigger date is in the past,
                        // it means we are past the ideal 'daysBefore' reminder point.
                        // We could schedule it for 'now + a few seconds' if expirationDate is very soon.
                        // For simplicity, if triggerDate is in the past, we just log and skip.
                        if expirationDate > now && triggerDate <= now {
                             print("Key '\(keyName)' (ID: \(keyId)) reminder point is in the past. Skipping notification scheduling or consider immediate alert.")
                             continue
                        } else if triggerDate <= now { // Double check to skip if trigger date is in the past
                            continue
                        }
                    }

                    var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
                    dateComponents.hour = 9 // At 9 AM
                    dateComponents.minute = 0

                    let content = UNMutableNotificationContent()
                    content.title = "API Key Expiring Soon!"
                    content.subtitle = "Key: \(keyName)"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    content.body = "Your API key '\(keyName)' is set to expire on \(dateFormatter.string(from: expirationDate))."
                    content.sound = .default

                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

                    center.add(request) { error in
                        if let error = error {
                            print("Error scheduling notification for key \(keyName) (ID: \(keyId)): \(error.localizedDescription)")
                        } else {
                            print("Successfully scheduled notification for key \(keyName) (ID: \(keyId)) to trigger at \(dateComponents).")
                        }
                    }
                }
            } catch {
                print("Failed to fetch API keys for notification scheduling: \(error.localizedDescription)")
            }
        }
    }
}
