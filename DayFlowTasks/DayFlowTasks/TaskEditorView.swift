import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let existingTask: TaskItem?
    let onSave: (TaskItem) -> Void

    @State private var title: String
    @State private var notes: String
    @State private var category: TaskCategory
    @State private var priority: TaskPriority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date

    init(task: TaskItem? = nil, onSave: @escaping (TaskItem) -> Void) {
        existingTask = task
        self.onSave = onSave
        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _category = State(initialValue: task?.category ?? .study)
        _priority = State(initialValue: task?.priority ?? .normal)
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _dueDate = State(initialValue: task?.dueDate ?? Date())
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task details") {
                    TextField("What do you need to do?", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Organisation") {
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases) { item in
                            Label(item.rawValue, systemImage: item.symbol).tag(item)
                        }
                    }
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                }

                Section("Deadline") {
                    Toggle("Set a due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(existingTask == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTask() }
                        .disabled(trimmedTitle.isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveTask() {
        let task = TaskItem(
            id: existingTask?.id ?? UUID(),
            title: trimmedTitle,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            isCompleted: existingTask?.isCompleted ?? false,
            createdAt: existingTask?.createdAt ?? Date()
        )
        onSave(task)
        dismiss()
    }
}
