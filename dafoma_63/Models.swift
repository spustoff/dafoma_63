//
//  Models.swift
//  CluckPlan
//
//  Created by IGOR on 13/10/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Task Model
struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var category: TaskCategory
    var isCompleted: Bool = false
    var scheduledTime: Date?
    var createdAt: Date = Date()
    var completedAt: Date?
    
    enum TaskCategory: String, CaseIterable, Codable {
        case work = "Work"
        case personal = "Personal"
        case health = "Health"
        case learning = "Learning"
        case other = "Other"
        
        var color: Color {
            switch self {
            case .work: return Color(hex: "#FF6B35")
            case .personal: return Color(hex: "#FFB800")
            case .health: return Color(hex: "#4CAF50")
            case .learning: return Color(hex: "#2196F3")
            case .other: return Color(hex: "#9C27B0")
            }
        }
        
        var icon: String {
            switch self {
            case .work: return "briefcase.fill"
            case .personal: return "person.fill"
            case .health: return "heart.fill"
            case .learning: return "book.fill"
            case .other: return "star.fill"
            }
        }
    }
}

// MARK: - Focus Session Model
struct FocusSession: Identifiable, Codable {
    let id = UUID()
    var title: String
    var duration: TimeInterval // in seconds
    var startTime: Date
    var isActive: Bool = false
    var isCompleted: Bool = false
    var actualDuration: TimeInterval = 0
}

// MARK: - Statistics Model
struct Statistics: Codable {
    var tasksCompleted: Int = 0
    var totalFocusTime: TimeInterval = 0 // in seconds
    var feathersEarned: Int = 0
    var gamesPlayed: Int = 0
    var bestGameScore: Int = 0
    var streakDays: Int = 0
    var lastActiveDate: Date = Date()
    
    // Daily stats
    var dailyTasksCompleted: Int = 0
    var dailyFocusTime: TimeInterval = 0
    var dailyFeathersEarned: Int = 0
    
    // Weekly stats
    var weeklyTasksCompleted: Int = 0
    var weeklyFocusTime: TimeInterval = 0
    var weeklyFeathersEarned: Int = 0
}

// MARK: - Game State Model
struct GameState: Codable {
    var score: Int = 0
    var feathersCollected: Int = 0
    var isGameActive: Bool = false
    var chickenPosition: CGFloat = 0.5 // normalized position (0-1)
    var cars: [Car] = []
    var backgroundTheme: BackgroundTheme = .morning
    
    struct Car: Identifiable, Codable {
        let id = UUID()
        var position: CGFloat // normalized position (0-1)
        var speed: CGFloat
        var lane: Int // 0, 1, 2 for three lanes
    }
    
    enum BackgroundTheme: String, CaseIterable, Codable {
        case morning = "Morning"
        case sunset = "Sunset"
        case night = "Night"
        
        var colors: [Color] {
            switch self {
            case .morning:
                return [Color(hex: "#FFF6D9"), Color(hex: "#FFE5B4")]
            case .sunset:
                return [Color(hex: "#FF6B35"), Color(hex: "#FFB800")]
            case .night:
                return [Color(hex: "#2E2E2E"), Color(hex: "#4A4A4A")]
            }
        }
        
        var cost: Int {
            switch self {
            case .morning: return 0
            case .sunset: return 50
            case .night: return 100
            }
        }
    }
}

// MARK: - App State Model
class AppState: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var statistics: Statistics = Statistics()
    @Published var gameState: GameState = GameState()
    @Published var currentScreen: AppScreen = .onboarding
    @Published var showingAddTask: Bool = false
    @Published var showingAddSession: Bool = false
    
    enum AppScreen {
        case onboarding
        case planner
        case schedule
        case game
        case statistics
    }
    
    init() {
        loadData()
        updateDailyStats()
    }
    
    // MARK: - Task Management
    func addTask(title: String, category: Task.TaskCategory, scheduledTime: Date? = nil) {
        let task = Task(title: title, category: category, scheduledTime: scheduledTime)
        tasks.append(task)
        saveData()
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            
            if tasks[index].isCompleted {
                tasks[index].completedAt = Date()
                statistics.tasksCompleted += 1
                statistics.dailyTasksCompleted += 1
                
                // Award feathers for completing tasks
                let feathersEarned = 5
                statistics.feathersEarned += feathersEarned
                statistics.dailyFeathersEarned += feathersEarned
            } else {
                tasks[index].completedAt = nil
                statistics.tasksCompleted = max(0, statistics.tasksCompleted - 1)
                statistics.dailyTasksCompleted = max(0, statistics.dailyTasksCompleted - 1)
                
                // Remove feathers
                let feathersLost = 5
                statistics.feathersEarned = max(0, statistics.feathersEarned - feathersLost)
                statistics.dailyFeathersEarned = max(0, statistics.dailyFeathersEarned - feathersLost)
            }
            
            saveData()
        }
    }
    
    func deleteTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            if tasks[index].isCompleted {
                statistics.tasksCompleted = max(0, statistics.tasksCompleted - 1)
                statistics.dailyTasksCompleted = max(0, statistics.dailyTasksCompleted - 1)
                
                let feathersLost = 5
                statistics.feathersEarned = max(0, statistics.feathersEarned - feathersLost)
                statistics.dailyFeathersEarned = max(0, statistics.dailyFeathersEarned - feathersLost)
            }
            
            tasks.remove(at: index)
            saveData()
        }
    }
    
    // MARK: - Focus Session Management
    func addFocusSession(title: String, duration: TimeInterval, startTime: Date) {
        let session = FocusSession(title: title, duration: duration, startTime: startTime)
        focusSessions.append(session)
        saveData()
    }
    
    func startFocusSession(_ session: FocusSession) {
        if let index = focusSessions.firstIndex(where: { $0.id == session.id }) {
            focusSessions[index].isActive = true
            saveData()
        }
    }
    
    func completeFocusSession(_ session: FocusSession, actualDuration: TimeInterval) {
        if let index = focusSessions.firstIndex(where: { $0.id == session.id }) {
            focusSessions[index].isActive = false
            focusSessions[index].isCompleted = true
            focusSessions[index].actualDuration = actualDuration
            
            statistics.totalFocusTime += actualDuration
            statistics.dailyFocusTime += actualDuration
            
            // Award feathers for focus sessions
            let feathersEarned = Int(actualDuration / 60) // 1 feather per minute
            statistics.feathersEarned += feathersEarned
            statistics.dailyFeathersEarned += feathersEarned
            
            saveData()
        }
    }
    
    // MARK: - Game Management
    func updateGameScore(_ score: Int) {
        gameState.score = score
        if score > statistics.bestGameScore {
            statistics.bestGameScore = score
        }
        
        // Award feathers for game score
        let feathersEarned = score / 10 // 1 feather per 10 points
        statistics.feathersEarned += feathersEarned
        statistics.dailyFeathersEarned += feathersEarned
        
        statistics.gamesPlayed += 1
        saveData()
    }
    
    func purchaseTheme(_ theme: GameState.BackgroundTheme) -> Bool {
        if statistics.feathersEarned >= theme.cost {
            statistics.feathersEarned -= theme.cost
            gameState.backgroundTheme = theme
            saveData()
            return true
        }
        return false
    }
    
    // MARK: - Statistics Management
    func resetProgress() {
        tasks.removeAll()
        focusSessions.removeAll()
        statistics = Statistics()
        gameState = GameState()
        saveData()
    }
    
    private func updateDailyStats() {
        let calendar = Calendar.current
        let today = Date()
        
        if !calendar.isDate(statistics.lastActiveDate, inSameDayAs: today) {
            // New day, reset daily stats
            statistics.dailyTasksCompleted = 0
            statistics.dailyFocusTime = 0
            statistics.dailyFeathersEarned = 0
            statistics.lastActiveDate = today
            
            // Update streak
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if calendar.isDate(statistics.lastActiveDate, inSameDayAs: yesterday) {
                statistics.streakDays += 1
            } else {
                statistics.streakDays = 1
            }
            
            saveData()
        }
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        let encoder = JSONEncoder()
        
        if let tasksData = try? encoder.encode(tasks) {
            UserDefaults.standard.set(tasksData, forKey: "tasks")
        }
        
        if let sessionsData = try? encoder.encode(focusSessions) {
            UserDefaults.standard.set(sessionsData, forKey: "focusSessions")
        }
        
        if let statsData = try? encoder.encode(statistics) {
            UserDefaults.standard.set(statsData, forKey: "statistics")
        }
        
        if let gameData = try? encoder.encode(gameState) {
            UserDefaults.standard.set(gameData, forKey: "gameState")
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        
        if let tasksData = UserDefaults.standard.data(forKey: "tasks"),
           let loadedTasks = try? decoder.decode([Task].self, from: tasksData) {
            tasks = loadedTasks
        }
        
        if let sessionsData = UserDefaults.standard.data(forKey: "focusSessions"),
           let loadedSessions = try? decoder.decode([FocusSession].self, from: sessionsData) {
            focusSessions = loadedSessions
        }
        
        if let statsData = UserDefaults.standard.data(forKey: "statistics"),
           let loadedStats = try? decoder.decode(Statistics.self, from: statsData) {
            statistics = loadedStats
        }
        
        if let gameData = UserDefaults.standard.data(forKey: "gameState"),
           let loadedGame = try? decoder.decode(GameState.self, from: gameData) {
            gameState = loadedGame
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
