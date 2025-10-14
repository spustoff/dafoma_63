//
//  StatisticsView.swift
//  CluckPlan
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var appState: AppState
    @State private var animateContent = false
    @State private var showingResetAlert = false
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Daily Stats Section
                        dailyStatsSection
                        
                        // Weekly Stats Section
                        weeklyStatsSection
                        
                        // All-Time Stats Section
                        allTimeStatsSection
                        
                        // Achievements Section
                        achievementsSection
                        
                        // Settings Section
                        settingsSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appState.resetProgress()
            }
        } message: {
            Text("This will permanently delete all your tasks, statistics, and progress. This action cannot be undone.")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Statistics & Settings")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#2E2E2E"))
                
                Text("Track your productivity journey")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
            }
            
            Spacer()
            
            // Back button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState.currentScreen = .planner
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#FF6B35"))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.top, 10)
        .opacity(animateContent ? 1.0 : 0.0)
        .offset(y: animateContent ? 0 : -20)
        .animation(.easeOut(duration: 0.6), value: animateContent)
    }
    
    private var dailyStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#2E2E2E"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Tasks Done",
                    value: "\(appState.statistics.dailyTasksCompleted)",
                    color: Color(hex: "#4CAF50"),
                    animationDelay: 0.1
                )
                
                StatCard(
                    icon: "clock.fill",
                    title: "Focus Time",
                    value: formatTime(appState.statistics.dailyFocusTime),
                    color: Color(hex: "#2196F3"),
                    animationDelay: 0.2
                )
                
                StatCard(
                    icon: "leaf.fill",
                    title: "Feathers",
                    value: "\(appState.statistics.dailyFeathersEarned)",
                    color: Color(hex: "#FFB800"),
                    animationDelay: 0.3
                )
                
                StatCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(appState.statistics.streakDays) days",
                    color: Color(hex: "#FF6B35"),
                    animationDelay: 0.4
                )
            }
        }
        .opacity(animateContent ? 1.0 : 0.0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
    }
    
    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#2E2E2E"))
            
            VStack(spacing: 12) {
                WeeklyStatRow(
                    icon: "checkmark.circle.fill",
                    title: "Tasks Completed",
                    value: "\(appState.statistics.weeklyTasksCompleted)",
                    color: Color(hex: "#4CAF50")
                )
                
                WeeklyStatRow(
                    icon: "clock.fill",
                    title: "Total Focus Time",
                    value: formatTime(appState.statistics.weeklyFocusTime),
                    color: Color(hex: "#2196F3")
                )
                
                WeeklyStatRow(
                    icon: "leaf.fill",
                    title: "Feathers Earned",
                    value: "\(appState.statistics.weeklyFeathersEarned)",
                    color: Color(hex: "#FFB800")
                )
            }
            .padding(20)
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .opacity(animateContent ? 1.0 : 0.0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
    }
    
    private var allTimeStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Time")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#2E2E2E"))
            
            VStack(spacing: 12) {
                AllTimeStatRow(
                    icon: "target",
                    title: "Total Tasks Completed",
                    value: "\(appState.statistics.tasksCompleted)",
                    color: Color(hex: "#4CAF50")
                )
                
                AllTimeStatRow(
                    icon: "timer",
                    title: "Total Focus Time",
                    value: formatTime(appState.statistics.totalFocusTime),
                    color: Color(hex: "#2196F3")
                )
                
                AllTimeStatRow(
                    icon: "leaf.fill",
                    title: "Total Feathers",
                    value: "\(appState.statistics.feathersEarned)",
                    color: Color(hex: "#FFB800")
                )
                
                AllTimeStatRow(
                    icon: "gamecontroller.fill",
                    title: "Games Played",
                    value: "\(appState.statistics.gamesPlayed)",
                    color: Color(hex: "#9C27B0")
                )
                
                AllTimeStatRow(
                    icon: "star.fill",
                    title: "Best Game Score",
                    value: "\(appState.statistics.bestGameScore)",
                    color: Color(hex: "#FF6B35")
                )
            }
            .padding(20)
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .opacity(animateContent ? 1.0 : 0.0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#2E2E2E"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AchievementBadge(
                    icon: "checkmark.seal.fill",
                    title: "Task Master",
                    description: "Complete 10 tasks",
                    isUnlocked: appState.statistics.tasksCompleted >= 10,
                    color: Color(hex: "#4CAF50")
                )
                
                AchievementBadge(
                    icon: "clock.badge.checkmark.fill",
                    title: "Focus Champion",
                    description: "Focus for 1 hour",
                    isUnlocked: appState.statistics.totalFocusTime >= 3600,
                    color: Color(hex: "#2196F3")
                )
                
                AchievementBadge(
                    icon: "leaf.arrow.circlepath",
                    title: "Feather Collector",
                    description: "Earn 100 feathers",
                    isUnlocked: appState.statistics.feathersEarned >= 100,
                    color: Color(hex: "#FFB800")
                )
                
                AchievementBadge(
                    icon: "flame.circle.fill",
                    title: "Streak Master",
                    description: "7-day streak",
                    isUnlocked: appState.statistics.streakDays >= 7,
                    color: Color(hex: "#FF6B35")
                )
            }
        }
        .opacity(animateContent ? 1.0 : 0.0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#2E2E2E"))
            
            VStack(spacing: 0) {
                // Navigation buttons
                SettingsRow(
                    icon: "calendar",
                    title: "Schedule & Focus",
                    subtitle: "Manage your focus sessions",
                    action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState.currentScreen = .schedule
                        }
                    }
                )
                
                Divider()
                    .padding(.horizontal, 16)
                
                SettingsRow(
                    icon: "gamecontroller.fill",
                    title: "Feather Collector",
                    subtitle: "Take a relaxing break",
                    action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState.currentScreen = .game
                        }
                    }
                )
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Reset progress button
                SettingsRow(
                    icon: "trash.fill",
                    title: "Reset Progress",
                    subtitle: "Clear all data and start fresh",
                    isDestructive: true,
                    action: {
                        showingResetAlert = true
                    }
                )
            }
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .opacity(animateContent ? 1.0 : 0.0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(1.0), value: animateContent)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let animationDelay: Double
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .scaleEffect(animate ? 1.0 : 0.5)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(animationDelay), value: animate)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#2E2E2E"))
                
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .opacity(animate ? 1.0 : 0.0)
            .offset(y: animate ? 0 : 10)
            .animation(.easeOut(duration: 0.6).delay(animationDelay + 0.2), value: animate)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            animate = true
        }
    }
}

struct WeeklyStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#2E2E2E"))
                
                Text(value)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
            }
            
            Spacer()
        }
    }
}

struct AllTimeStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#2E2E2E"))
            
            Spacer()
            
            Text(value)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#2E2E2E"))
        }
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isUnlocked ? color : Color.gray.opacity(0.4))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? Color(hex: "#2E2E2E") : Color.gray.opacity(0.6))
                
                Text(description)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            isUnlocked ? 
            Color.white.opacity(0.8) : 
            Color.gray.opacity(0.1)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isUnlocked ? color.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
        .shadow(
            color: isUnlocked ? Color.black.opacity(0.05) : Color.clear,
            radius: 4, x: 0, y: 2
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isDestructive ? .red : Color(hex: "#FFB800"))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(isDestructive ? .red : Color(hex: "#2E2E2E"))
                    
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    StatisticsView(appState: AppState())
}
