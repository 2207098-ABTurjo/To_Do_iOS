import Foundation
import SwiftUI

enum TaskPriority: String, CaseIterable, Codable, Identifiable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"

    var id: String { rawValue }

    var tint: Color {
        switch self {
        case .low: return .green
        case .normal: return .orange
        case .high: return .red
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable, Identifiable {
    case study = "Study"
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case other = "Other"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .study: return "book.closed.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var notes: String
    var category: TaskCategory
    var priority: TaskPriority
    var dueDate: Date?
    var isCompleted: Bool = false
    var createdAt: Date = Date()

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: Date())
    }
}
