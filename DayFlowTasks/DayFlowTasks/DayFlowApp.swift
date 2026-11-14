import SwiftUI

@main
struct DayFlowApp: App {
    @StateObject private var taskStore = TaskStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskStore)
                .preferredColorScheme(.light)
        }
    }
}
