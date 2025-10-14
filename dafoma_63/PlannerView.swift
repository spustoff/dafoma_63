//
//  PlannerView.swift
//  CluckPlan
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct PlannerView: View {
    @ObservedObject var appState: AppState
    @State private var animateProgress = false
    @State private var animateList = false
    
    var completedTasks: [Task] {
        appState.tasks.filter { $0.isCompleted }
    }
    
    var incompleteTasks: [Task] {
        appState.tasks.filter { !$0.isCompleted }
    }
    
    var completionPercentage: Double {
        guard !appState.tasks.isEmpty else { return 0 }
        return Double(completedTasks.count) / Double(appState.tasks.count)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "#FFF6D9"), Color(hex: "#FFE5B4").opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Progress Section
                    progressSection
                    
                    // Tasks List
                    tasksListSection
                    
                    Spacer(minLength: 100) // Space for floating buttons
                }
                
                // Floating Action Buttons
                floatingButtons
            }
        }
        .sheet(isPresented: $appState.showingAddTask) {
            AddTaskView(appState: appState)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateProgress = true
                animateList = true
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Day at a Glance")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E2E2E"))
                    
                    Text(DateFormatter.dayFormatter.string(from: Date()))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Statistics button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState.currentScreen = .statistics
                        }
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#FF6B35"))
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Feathers display
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(Color(hex: "#4CAF50"))
                            .font(.caption)
                        
                        Text("\(appState.statistics.feathersEarned)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: animateProgress ? completionPercentage : 0)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#FFB800"), Color(hex: "#FF6B35")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5).delay(0.3), value: animateProgress)
                
                VStack(spacing: 2) {
                    Text("\(Int(completionPercentage * 100))%")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E2E2E"))
                    
                    Text("Complete")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
                }
                .scaleEffect(animateProgress ? 1.0 : 0.5)
                .opacity(animateProgress ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.8), value: animateProgress)
            }
            
            // Stats Row
            HStack(spacing: 30) {
                StatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(completedTasks.count)",
                    label: "Done",
                    color: Color(hex: "#4CAF50")
                )
                
                StatItem(
                    icon: "clock.fill",
                    value: "\(incompleteTasks.count)",
                    label: "Pending",
                    color: Color(hex: "#FF6B35")
                )
                
                StatItem(
                    icon: "target",
                    value: "\(appState.tasks.count)",
                    label: "Total",
                    color: Color(hex: "#FFB800")
                )
            }
            .opacity(animateProgress ? 1.0 : 0.0)
            .offset(y: animateProgress ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(1.0), value: animateProgress)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    private var tasksListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !appState.tasks.isEmpty {
                HStack {
                    Text("Today's Tasks")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#2E2E2E"))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Incomplete tasks first
                        ForEach(Array(incompleteTasks.enumerated()), id: \.element.id) { index, task in
                            TaskRowView(
                                task: task,
                                onToggle: { appState.toggleTask(task) },
                                onDelete: { appState.deleteTask(task) }
                            )
                            .opacity(animateList ? 1.0 : 0.0)
                            .offset(x: animateList ? 0 : -50)
                            .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: animateList)
                        }
                        
                        // Completed tasks
                        ForEach(Array(completedTasks.enumerated()), id: \.element.id) { index, task in
                            TaskRowView(
                                task: task,
                                onToggle: { appState.toggleTask(task) },
                                onDelete: { appState.deleteTask(task) }
                            )
                            .opacity(animateList ? 0.7 : 0.0)
                            .offset(x: animateList ? 0 : -50)
                            .animation(.easeOut(duration: 0.5).delay(Double(incompleteTasks.count + index) * 0.1), value: animateList)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Space for floating buttons
                }
            } else {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#FFB800").opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No tasks yet")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        Text("Tap the + button to add your first task")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
                .opacity(animateList ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: animateList)
            }
        }
    }
    
    private var floatingButtons: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // Take a Break button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState.currentScreen = .game
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 16, weight: .medium))
                            
                    Text("Play Game")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#4CAF50"), Color(hex: "#45A049")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color(hex: "#4CAF50").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Add Task button
                    Button(action: {
                        appState.showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#FFB800"), Color(hex: "#FF6B35")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: Color(hex: "#FFB800").opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 30)
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#2E2E2E"))
            
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? task.category.color : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(task.category.color)
                    }
                }
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(task.isCompleted ? Color(hex: "#2E2E2E").opacity(0.6) : Color(hex: "#2E2E2E"))
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    // Category badge
                    HStack(spacing: 4) {
                        Image(systemName: task.category.icon)
                            .font(.system(size: 10))
                        
                        Text(task.category.rawValue)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(task.category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(task.category.color.opacity(0.1))
                    .cornerRadius(12)
                    
                    if let scheduledTime = task.scheduledTime {
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            
                            Text(DateFormatter.timeFormatter.string(from: scheduledTime))
                                .font(.system(.caption, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "#2E2E2E").opacity(0.5))
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct AddTaskView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var taskTitle = ""
    @State private var selectedCategory = Task.TaskCategory.personal
    @State private var hasScheduledTime = false
    @State private var scheduledTime = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    // Title input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Title")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        TextField("Enter task title", text: $taskTitle)
                            .font(.system(.body, design: .rounded))
                            .padding(16)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Category selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 16))
                                        
                                        Text(category.rawValue)
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(selectedCategory == category ? .white : category.color)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedCategory == category ?
                                        category.color :
                                        category.color.opacity(0.1)
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Scheduled time
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Schedule for specific time", isOn: $hasScheduledTime)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        if hasScheduledTime {
                            DatePicker("Time", selection: $scheduledTime, displayedComponents: .hourAndMinute)
                                .font(.system(.body, design: .rounded))
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Add button
                Button(action: {
                    appState.addTask(
                        title: taskTitle,
                        category: selectedCategory,
                        scheduledTime: hasScheduledTime ? scheduledTime : nil
                    )
                    dismiss()
                }) {
                    Text("Add Task")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#FFB800"), Color(hex: "#FF6B35")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "#FFB800").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(hex: "#FFF6D9"))
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FF6B35"))
                }
            }
        }
    }
}

// MARK: - Date Formatters
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

#Preview {
    PlannerView(appState: AppState())
}
