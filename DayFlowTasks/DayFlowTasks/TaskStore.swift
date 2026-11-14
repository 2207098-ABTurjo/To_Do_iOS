import Foundation
import Combine

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    private let storageKey = "dayflow.tasks.v1"

    init() {
        loadTasks()
    }

    var completedCount: Int { tasks.filter(\.isCompleted).count }
    var remainingCount: Int { tasks.count - completedCount }

    func add(_ task: TaskItem) {
        tasks.insert(task, at: 0)
        saveTasks()
    }

    func update(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        tasks.sort { $0.createdAt > $1.createdAt }
        saveTasks()
    }

    func toggle(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        saveTasks()
    }

    func delete(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    func removeCompleted() {
        tasks.removeAll(\.isCompleted)
        saveTasks()
    }

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let savedTasks = try? JSONDecoder().decode([TaskItem].self, from: data) else {
            tasks = []
            return
        }
        tasks = savedTasks.sorted { $0.createdAt > $1.createdAt }
    }

    private func saveTasks() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
