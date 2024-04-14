import UIKit
import EventKitUI
import EventKit

class LastTechViewController: UIViewController, EKEventViewDelegate, EKEventEditViewDelegate {
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        
    }
    
    let store = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.title = "Events"
    }
    
    @objc func didTapAdd() {
        store.requestAccess(to: .event) { [weak self] success, error in
            if success, error == nil {
                DispatchQueue.main.async {
                    guard let store = self?.store else { return }
                    
                    let newEvent = EKEvent(eventStore: store)
                    newEvent.startDate = Date()
                    newEvent.endDate = Date()
                    
                    let vc = EKEventEditViewController()
                    vc.eventStore = store
                    vc.event = newEvent
                    vc.editViewDelegate = self // Set the delegate
                    self?.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            if let event = controller.event {
                // Event saved successfully, you can access the event data here
                print("Event Title: \(event.title ?? "Untitled Event")")
                print("Start Date: \(event.startDate)")
                print("End Date: \(event.endDate)")
                print("Location: \(event.location ?? "No Location")")
                print("Notes: \(event.notes ?? "No Notes")")
                print("All-Day: \(event.isAllDay ? "Yes" : "No")")
                print("Calendar: \(event.calendar.title)")
            }
        case .canceled:
            print("Event creation canceled")
        case .deleted:
            print("Event deleted")
        @unknown default:
            fatalError("Unknown action")
        }
        dismiss(animated: true, completion: nil)
    }
}
