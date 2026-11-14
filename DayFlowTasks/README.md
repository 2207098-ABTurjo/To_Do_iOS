# DayFlow Tasks — iOS To-Do App

DayFlow Tasks is a SwiftUI task manager created as an independent implementation of a familiar to-do-list assignment. It keeps the central task-management idea but uses a different app identity, interface, data model, and storage approach.

## Features

- Create, edit, complete, and delete tasks
- Search by task title or notes
- Filter tasks by All, Pending, and Completed
- Assign a category (Study, Work, Personal, Health, Other)
- Set Low, Normal, or High priority
- Add an optional due date and see overdue tasks
- View a completion progress summary
- Remove all completed tasks
- Save tasks locally with `UserDefaults` and `Codable`
- No Firebase account, API key, or third-party package is required

## Project structure

```text
DayFlowTasks/
├── DayFlowTasks.xcodeproj/
├── DayFlowTasks/
│   ├── Assets.xcassets/
│   ├── DayFlowApp.swift
│   ├── ContentView.swift
│   ├── TaskEditorView.swift
│   ├── TaskItem.swift
│   └── TaskStore.swift
├── README.md
└── .gitignore
```

## Open and run

### On a Mac (required for an iOS build)

1. Install Xcode 15 or later.
2. Open `DayFlowTasks.xcodeproj` in Xcode.
3. Select the `DayFlowTasks` scheme and an iPhone simulator.
4. If Xcode asks, choose your own Team under **Signing & Capabilities**. The project uses a placeholder bundle identifier; change it to a unique value if needed.
5. Press **Run**.

### On Windows with VS Code

You can open the folder in VS Code to read and edit the Swift files and manage Git. Windows cannot run Xcode, the iOS Simulator, or build an iOS app natively. For the final compile and simulator check, use a Mac with Xcode (for example, a university lab Mac or a trusted Mac access service).

## GitHub

Open a terminal in the extracted `DayFlowTasks` folder and run:

```bash
git init
git add .
git commit -m "Initial DayFlow Tasks iOS app"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
git push -u origin main
```

Replace the remote URL with a repository you created under your own GitHub account. If the repository already has a README or other commits, pull/reconcile those first rather than force-pushing.

## Data storage note

Tasks are stored on the device using `UserDefaults`. They remain available after closing and reopening the app on that device, but they do not sync between devices and are not linked to user accounts. This is intentional: the project is self-contained and does not reuse another person's Firebase configuration.

## Verification status

The Swift files are syntax-parsed with the Swift compiler in the preparation environment. A full iOS build, simulator run, and device test cannot be performed here because Apple's iOS SDK and Xcode are only available on macOS. Please complete that final check on a Mac before submitting.
