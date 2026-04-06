import UIKit

@MainActor
final class HapticsClient {
    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
