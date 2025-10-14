//
//  ScheduleView.swift
//  CluckPlan
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct ScheduleView: View {
    @ObservedObject var appState: AppState
    @State private var animateContent = false
    @State private var activeFocusSession: FocusSession?
    @State private var focusTimer: Timer?
    @State private var timeRemaining: TimeInterval = 0
    @State private var sessionStartTime: Date?
    
    var todaysSessions: [FocusSession] {
        let calendar = Calendar.current
        return appState.focusSessions.filter { session in
            calendar.isDateInToday(session.startTime)
        }.sorted { $0.startTime < $1.startTime }
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
                    
                    // Active Session Display
                    if let activeSession = activeFocusSession {
                        activeSessionView(activeSession)
                    }
                    
                    // Sessions List
                    sessionsListSection
                    
                    Spacer(minLength: 100) // Space for floating button
                }
                
                // Floating Add Session Button
                floatingAddButton
            }
        }
        .sheet(isPresented: $appState.showingAddSession) {
            AddSessionView(appState: appState)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
            checkForActiveSessions()
        }
        .onDisappear {
            stopFocusTimer()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Focus Schedule")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#2E2E2E"))
                
                Text("Plan your productive sessions")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
            }
            
            Spacer()
            
            // Back to planner button
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
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .opacity(animateContent ? 1.0 : 0.0)
        .offset(y: animateContent ? 0 : -20)
        .animation(.easeOut(duration: 0.6), value: animateContent)
    }
    
    private func activeSessionView(_ session: FocusSession) -> some View {
        VStack(spacing: 16) {
            // Timer Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: 1 - (timeRemaining / session.duration))
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#4CAF50"), Color(hex: "#45A049")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: timeRemaining)
                
                VStack(spacing: 8) {
                    Text(formatTime(timeRemaining))
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E2E2E"))
                    
                    Text(session.title)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            
            // Control Buttons
            HStack(spacing: 20) {
                Button(action: {
                    pauseFocusSession()
                }) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color(hex: "#FF6B35"))
                        .cornerRadius(25)
                        .shadow(color: Color(hex: "#FF6B35").opacity(0.3), radius: 6, x: 0, y: 3)
                }
                
                Button(action: {
                    completeFocusSession()
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color(hex: "#4CAF50"))
                        .cornerRadius(25)
                        .shadow(color: Color(hex: "#4CAF50").opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var sessionsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !todaysSessions.isEmpty {
                HStack {
                    Text("Today's Sessions")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#2E2E2E"))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(todaysSessions.enumerated()), id: \.element.id) { index, session in
                            SessionRowView(
                                session: session,
                                onStart: { startFocusSession(session) },
                                onDelete: { deleteSession(session) }
                            )
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(x: animateContent ? 0 : -50)
                            .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1 + 0.5), value: animateContent)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Space for floating button
                }
            } else {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "timer")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#FFB800").opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No sessions scheduled")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        Text("Add a focus session to get started")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
                .opacity(animateContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: animateContent)
            }
        }
    }
    
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    appState.showingAddSession = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#4CAF50"), Color(hex: "#45A049")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "#4CAF50").opacity(0.4), radius: 12, x: 0, y: 6)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Focus Session Management
    private func startFocusSession(_ session: FocusSession) {
        activeFocusSession = session
        timeRemaining = session.duration
        sessionStartTime = Date()
        appState.startFocusSession(session)
        
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeFocusSession()
            }
        }
    }
    
    private func pauseFocusSession() {
        stopFocusTimer()
        activeFocusSession = nil
    }
    
    private func completeFocusSession() {
        guard let session = activeFocusSession,
              let startTime = sessionStartTime else { return }
        
        let actualDuration = Date().timeIntervalSince(startTime)
        appState.completeFocusSession(session, actualDuration: actualDuration)
        
        stopFocusTimer()
        activeFocusSession = nil
        sessionStartTime = nil
    }
    
    private func stopFocusTimer() {
        focusTimer?.invalidate()
        focusTimer = nil
    }
    
    private func checkForActiveSessions() {
        if let activeSession = appState.focusSessions.first(where: { $0.isActive }) {
            activeFocusSession = activeSession
            timeRemaining = activeSession.duration
            sessionStartTime = Date()
            
            focusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    completeFocusSession()
                }
            }
        }
    }
    
    private func deleteSession(_ session: FocusSession) {
        if let index = appState.focusSessions.firstIndex(where: { $0.id == session.id }) {
            appState.focusSessions.remove(at: index)
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SessionRowView: View {
    let session: FocusSession
    let onStart: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(spacing: 4) {
                Text(DateFormatter.timeFormatter.string(from: session.startTime))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#2E2E2E"))
                
                Text(formatDuration(session.duration))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.6))
            }
            .frame(width: 60)
            
            // Session content
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#2E2E2E"))
                
                HStack(spacing: 8) {
                    if session.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#4CAF50"))
                            
                            Text("Completed")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color(hex: "#4CAF50"))
                        }
                    } else if session.isActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: "#FF6B35"))
                                .frame(width: 8, height: 8)
                            
                            Text("Active")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color(hex: "#FF6B35"))
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#FFB800"))
                            
                            Text("Scheduled")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color(hex: "#FFB800"))
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                if !session.isCompleted && !session.isActive {
                    Button(action: onStart) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "#4CAF50"))
                            .cornerRadius(16)
                    }
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

struct AddSessionView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var sessionTitle = ""
    @State private var duration: Double = 25 // minutes
    @State private var startTime = Date()
    
    private let durationOptions: [Double] = [15, 25, 30, 45, 60, 90]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    // Title input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Title")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        TextField("Enter session title", text: $sessionTitle)
                            .font(.system(.body, design: .rounded))
                            .padding(16)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Duration selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(durationOptions, id: \.self) { option in
                                Button(action: {
                                    duration = option
                                }) {
                                    Text("\(Int(option))m")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(duration == option ? .white : Color(hex: "#4CAF50"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            duration == option ?
                                            Color(hex: "#4CAF50") :
                                            Color(hex: "#4CAF50").opacity(0.1)
                                        )
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Start time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Time")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#2E2E2E"))
                        
                        DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                            .font(.system(.body, design: .rounded))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Add button
                Button(action: {
                    appState.addFocusSession(
                        title: sessionTitle,
                        duration: duration * 60, // convert to seconds
                        startTime: startTime
                    )
                    dismiss()
                }) {
                    Text("Add Session")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#4CAF50"), Color(hex: "#45A049")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(hex: "#4CAF50").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(sessionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(sessionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(hex: "#FFF6D9"))
            .navigationTitle("New Session")
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

#Preview {
    ScheduleView(appState: AppState())
}
