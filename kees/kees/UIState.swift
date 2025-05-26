import Combine // For ObservableObject
import SwiftUI // For @Published if needed, though Combine is enough for @Published

class UIState: ObservableObject {
    @Published var showingAddKeySheet = false
}
