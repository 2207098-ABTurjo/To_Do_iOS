import SwiftUI

private enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
    var id: String { rawValue }
}

struct ContentView: View {
    @EnvironmentObject private var store: TaskStore

    @State private var filter: TaskFilter = .all
    @State private var searchText = ""
    @State private var showingEditor = false
    @State private var taskToEdit: TaskItem?
    @State private var taskToDelete: TaskItem?
    @State private var showingDeleteAlert = false

    private var filteredTasks: [TaskItem] {
        store.tasks.filter { task in
            let matchesFilter: Bool
            switch filter {
            case .all: matchesFilter = true
            case .pending: matchesFilter = !task.isCompleted
            case .completed: matchesFilter = task.isCompleted
            }
            let matchesSearch = searchText.isEmpty ||
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.notes.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    private var progress: Double {
        guard !store.tasks.isEmpty else { return 0 }
        return Double(store.completedCount) / Double(store.tasks.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.99).ignoresSafeArea()

                VStack(spacing: 16) {
                    overviewCard
                    searchBar
                    filterBar
                    taskContent
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
            .navigationTitle("DayFlow")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Remove completed tasks", systemImage: "checkmark.circle") {
                            store.removeCompleted()
                        }
                        .disabled(store.completedCount == 0)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    taskToEdit = nil
                    showingEditor = true
                } label: {
                    Label("Add a new task", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(Color.indigo, in: RoundedRectangle(cornerRadius: 17))
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(.ultraThinMaterial)
            }
            .sheet(isPresented: $showingEditor) {
                TaskEditorView(task: taskToEdit) { task in
                    if taskToEdit == nil { store.add(task) }
                    else { store.update(task) }
                }
            }
            .alert("Delete this task?", isPresented: $showingDeleteAlert, presenting: taskToDelete) { task in
                Button("Delete", role: .destructive) { store.delete(task) }
                Button("Cancel", role: .cancel) { }
            } message: { task in
                Text("\"\(task.title)\" will be removed permanently from this device.")
            }
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(Date.now.formatted(date: .complete, time: .omitted))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.78))
                    Text("Make today count.")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }

            ProgressView(value: progress)
                .tint(.white)
                .background(.white.opacity(0.22), in: Capsule())

            HStack {
                Label("\(store.remainingCount) remaining", systemImage: "circle")
                Spacer()
                Label("\(store.completedCount) done", systemImage: "checkmark.circle.fill")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.92))
        }
        .padding(18)
        .background(
            LinearGradient(colors: [Color.indigo, Color(red: 0.36, green: 0.34, blue: 0.78)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 23, style: .continuous)
        )
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search your tasks", text: $searchText)
                .textInputAutocapitalization(.never)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(13)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(TaskFilter.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { filter = item }
                } label: {
                    Text(item.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(filter == item ? .white : .secondary)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 9)
                        .background(filter == item ? Color.indigo : .white,
                                    in: Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var taskContent: some View {
        if filteredTasks.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: searchText.isEmpty ? "checklist" : "magnifyingglass")
                    .font(.system(size: 38))
                    .foregroundStyle(.indigo.opacity(0.7))
                Text(searchText.isEmpty ? "Nothing on this list" : "No matching tasks")
                    .font(.headline)
                Text(searchText.isEmpty ? "Add a task and take the first step." : "Try another search term.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 11) {
                    ForEach(filteredTasks) { task in
                        TaskRow(task: task,
                                onToggle: { store.toggle(task) },
                                onEdit: { taskToEdit = task; showingEditor = true },
                                onDelete: { taskToDelete = task; showingDeleteAlert = true })
                    }
                }
                .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .indigo)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark as pending" : "Mark as completed")

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(task.category.rawValue, systemImage: task.category.symbol)
                    if let dueDate = task.dueDate {
                        Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .foregroundStyle(task.isOverdue ? .red : .secondary)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 2)

            Circle()
                .fill(task.priority.tint)
                .frame(width: 9, height: 9)
                .accessibilityLabel("\(task.priority.rawValue) priority")

            Menu {
                Button(action: onEdit) { Label("Edit task", systemImage: "pencil") }
                Button(role: .destructive, action: onDelete) { Label("Delete task", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 35)
                    .contentShape(Rectangle())
            }
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
    }
}
