import EventKit

class Reminders {
    let eventStore: EKEventStore = EKEventStore()
    var hasAccess: Bool = true
    let defaultList: EKCalendar?

    init() {
        defaultList = eventStore.defaultCalendarForNewReminders()
    }

    func initialize() -> String? {
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {(granted, error) in
            if let error = error { print(error) }
            self.hasAccess = granted ? true : false
        })
        return nil
    }

    func getDefaultList() -> String? {
        if let defaultList = defaultList { return List(list: defaultList).toJson() }
        return nil
    }

    func getAllLists() -> String? {
        let lists = eventStore.calendars(for: .reminder)
        let jsonData = try? JSONEncoder().encode(lists.map { List(list: $0) })
        return String(data: jsonData ?? Data(), encoding: .utf8)
    }

    func getReminders(_ id: String?, _ completion: @escaping(String?) -> ()) {
        var calendar: [EKCalendar]? = nil
        if let id = id { calendar = [eventStore.calendar(withIdentifier: id) ?? EKCalendar()] }
        let predicate: NSPredicate? = eventStore.predicateForReminders(in: calendar)
        if let predicate = predicate {
            eventStore.fetchReminders(matching: predicate) { (_ reminders: [Any]?) -> Void in
            let rems = reminders as? [EKReminder] ?? [EKReminder]()
            let result = rems.map { Reminder(reminder: $0) }
            let json = try? JSONEncoder().encode(result)
            completion(String(data: json ?? Data(), encoding: .utf8))
            }
        }
    }

    func saveReminder(_ json: [String: Any], _ completion: @escaping(String?) -> ()) {
        let reminder: EKReminder

        guard json["list"] != nil,
            let calendarID: String = json["list"] as? String,
            let list: EKCalendar = eventStore.calendar(withIdentifier: calendarID) else {
                return completion("Invalid calendarID")
        }

        if let reminderID = json["id"] as? String {
            reminder = eventStore.calendarItem(withIdentifier: reminderID) as! EKReminder
        } else {
            reminder = EKReminder(eventStore: eventStore)
        }
        
        reminder.calendar = list
        reminder.title = json["title"] as? String
        reminder.priority = json["priority"] as? Int ?? 0
        reminder.isCompleted = json["isCompleted"] as? Bool ?? false
        reminder.notes = json["notes"] as? String
        if let date = json["dueDate"] as? [String: Int] {
            reminder.dueDateComponents = DateComponents(year: date["year"], month: date["month"], day: date["day"], hour: nil, minute: nil, second: nil )
        } else {
            reminder.dueDateComponents = nil
        }

        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            completion(error.localizedDescription)
        }
        completion(reminder.calendarItemIdentifier)
    }

    func deleteReminder(_ id: String, _ completion: @escaping(String?) -> ()) {
        guard let reminder = eventStore.calendarItem(withIdentifier: id) as? EKReminder else {
            completion("Cannot find reminder with ID: \(id)")
            return
        }

        do {
            try eventStore.remove(reminder, commit: true)
        } catch {
            completion(error.localizedDescription)
        }
        completion(nil)
    }
}

struct Reminder : Codable {
    let list: List
    let id: String
    let title: String
    let dueDate: DateComponents?
    let completionDate: DateComponents?
    let priority: Int
    let isCompleted: Bool
    let notes: String?

    init(reminder : EKReminder) {
        self.list = List(list: reminder.calendar)
        self.id = reminder.calendarItemIdentifier
        self.title = reminder.title
        self.dueDate = reminder.dueDateComponents
        self.completionDate = reminder.completionDate == nil ? nil : Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.completionDate!)
        self.priority = reminder.priority
        self.isCompleted = reminder.isCompleted
        self.notes = reminder.notes
    }

    func toJson() -> String? {
        let jsonData = try? JSONEncoder().encode(self)
        return String(data: jsonData ?? Data(), encoding: .utf8)
    }
}

struct List : Codable {
    let title: String
    let id: String

    init(list : EKCalendar) {
        self.title = list.title
        self.id = list.calendarIdentifier
    }

    func toJson() -> String? {
        let jsonData = try? JSONEncoder().encode(self)
        return String(data: jsonData ?? Data(), encoding: .utf8)
    }
}
