//
//  GameView.swift
//  CluckPlan - Feather Collector Mini Game
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var appState: AppState
    @State private var gameTimer: Timer?
    @State private var featherSpawnTimer: Timer?
    @State private var isGameActive = false
    @State private var score = 0
    @State private var chickenPosition = CGPoint(x: 200, y: 300)
    @State private var feathers: [Feather] = []
    @State private var animateChicken = false
    @State private var showGameOver = false
    @State private var feathersEarned = 0
    @State private var timeRemaining: Int = 30
    
    private let gameWidth: CGFloat = UIScreen.main.bounds.width - 30
    private let gameHeight: CGFloat = 350
    private let chickenSize: CGFloat = 40
    private let featherSize: CGFloat = 25
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with theme
                backgroundView
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Game Area
                    gameAreaView
                    
                    // Controls
                    controlsView
                }
                
                // Game Over Overlay
                if showGameOver {
                    gameOverOverlay
                }
            }
        }
        .onAppear {
            resetGame()
        }
        .onDisappear {
            stopGame()
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: appState.gameState.backgroundTheme.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.0), value: appState.gameState.backgroundTheme)
    }
    
    private var headerView: some View {
        HStack {
            // Back button
            Button(action: {
                stopGame()
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState.currentScreen = .planner
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Back to Planning")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
            }
            
            Spacer()
            
            // Game stats
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 12) {
                    // Timer
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("\(timeRemaining)s")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Score
                    HStack(spacing: 4) {
                        Text("Score: \(score)")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Total feathers
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(Color(hex: "#4CAF50"))
                            .font(.caption)
                        
                        Text("\(appState.statistics.feathersEarned)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var gameAreaView: some View {
        VStack(spacing: 8) {
            // Game title
            Text("🪶 Feather Collector")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Game area with proper coordinate system
            ZStack {
                // Background
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#87CEEB").opacity(0.3), // Sky blue
                                Color(hex: "#98FB98").opacity(0.3)  // Pale green
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: gameWidth, height: gameHeight)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Game objects container with proper coordinate system
                ZStack {
                    // Feathers
                    ForEach(feathers) { feather in
                        featherView(feather: feather)
                    }
                    
                    // Chicken
                    chickenView
                }
                .frame(width: gameWidth, height: gameHeight)
                .clipped()
                
                // Touch area for dragging
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: gameWidth, height: gameHeight)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if isGameActive {
                                    moveChicken(to: value.location)
                                }
                            }
                    )
            }
            .frame(width: gameWidth, height: gameHeight)
        }
        .padding(.horizontal, 15)
    }
    
    private var chickenView: some View {
        Text("🐔")
            .font(.system(size: chickenSize))
            .scaleEffect(animateChicken ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateChicken)
            .position(
                x: chickenPosition.x,
                y: chickenPosition.y
            )
    }
    
    private func featherView(feather: Feather) -> some View {
        Text("🪶")
            .font(.system(size: featherSize))
            .rotationEffect(.degrees(feather.rotation))
            .scaleEffect(feather.scale)
            .position(
                x: feather.position.x,
                y: feather.position.y
            )
            .animation(.easeInOut(duration: 0.3), value: feather.scale)
    }
    
    // Helper function to move chicken
    private func moveChicken(to location: CGPoint) {
        let boundedX = max(chickenSize/2, min(gameWidth - chickenSize/2, location.x))
        let boundedY = max(chickenSize/2, min(gameHeight - chickenSize/2, location.y))
        chickenPosition = CGPoint(x: boundedX, y: boundedY)
    }
    
    private var controlsView: some View {
        VStack(spacing: 10) {
            // Game instructions
            if !isGameActive {
                VStack(spacing: 8) {
                    Text("🎮 HOW TO PLAY")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 6) {
                        Text("🐔 Drag chicken • 🪶 Collect feathers")
                            .font(.system(.callout, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("⏱️ 30 seconds • 🏆 10 points per feather")
                            .font(.system(.callout, design: .rounded))
                            .foregroundColor(Color(hex: "#4CAF50"))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            }
            
            // Start/Stop button
            Button(action: {
                if isGameActive {
                    stopGame()
                } else {
                    startGame()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isGameActive ? "pause.fill" : "play.fill")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text(isGameActive ? "Pause Game" : "Start Game")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: isGameActive ? 
                        [Color(hex: "#FF6B35"), Color(hex: "#E55A2B")] :
                        [Color(hex: "#4CAF50"), Color(hex: "#45A049")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(30)
                .shadow(color: (isGameActive ? Color(hex: "#FF6B35") : Color(hex: "#4CAF50")).opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 40)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Game Over!")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Final Score: \(score)")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if feathersEarned > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(Color(hex: "#4CAF50"))
                            
                            Text("Earned \(feathersEarned) feathers!")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "#4CAF50"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        showGameOver = false
                        resetGame()
                    }) {
                        Text("Play Again")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color(hex: "#4CAF50"))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        showGameOver = false
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState.currentScreen = .planner
                        }
                    }) {
                        Text("Back")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color(hex: "#FF6B35"))
                            .cornerRadius(25)
                    }
                }
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Game Logic
    private func startGame() {
        isGameActive = true
        animateChicken = true
        timeRemaining = 30
        score = 0
        feathers.removeAll()
        
        // Reset chicken position to center of game area
        chickenPosition = CGPoint(x: gameWidth / 2, y: gameHeight / 2)
        
        // Main game timer (60 FPS)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateGame()
        }
        
        // Feather spawn timer with initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.featherSpawnTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                self.spawnFeather()
            }
        }
        
        // Countdown timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.isGameActive {
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.gameOver()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func stopGame() {
        isGameActive = false
        animateChicken = false
        gameTimer?.invalidate()
        featherSpawnTimer?.invalidate()
        gameTimer = nil
        featherSpawnTimer = nil
    }
    
    private func resetGame() {
        stopGame()
        score = 0
        timeRemaining = 30
        chickenPosition = CGPoint(x: gameWidth / 2, y: gameHeight / 2)
        feathers.removeAll()
        showGameOver = false
        feathersEarned = 0
    }
    
    private func updateGame() {
        // Move feathers down
        for i in feathers.indices {
            feathers[i].position.y += feathers[i].fallSpeed
            feathers[i].rotation += feathers[i].rotationSpeed
        }
        
        // Remove off-screen feathers
        feathers.removeAll { feather in
            feather.position.y > gameHeight + featherSize
        }
        
        // Check for feather collection
        checkFeatherCollection()
    }
    
    private func spawnFeather() {
        let randomX = CGFloat.random(in: featherSize...(gameWidth - featherSize))
        let randomRotation = Double.random(in: 0...360)
        let randomFallSpeed = CGFloat.random(in: 2...4)
        let randomRotationSpeed = Double.random(in: -3...3)
        
        let feather = Feather(
            position: CGPoint(x: randomX, y: 0),
            rotation: randomRotation,
            fallSpeed: randomFallSpeed,
            rotationSpeed: randomRotationSpeed,
            scale: 1.0
        )
        
        feathers.append(feather)
    }
    
    private func checkFeatherCollection() {
        for i in feathers.indices.reversed() {
            let feather = feathers[i]
            let distance = sqrt(
                pow(feather.position.x - chickenPosition.x, 2) +
                pow(feather.position.y - chickenPosition.y, 2)
            )
            
            if distance < (chickenSize/2 + featherSize/2 + 5) { // Collection threshold
                // Animate feather collection
                feathers[i].scale = 0.1
                
                // Remove feather and add score
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if i < self.feathers.count {
                        self.feathers.remove(at: i)
                    }
                }
                
                score += 10
            }
        }
    }
    
    private func gameOver() {
        stopGame()
        
        // Calculate feathers earned
        feathersEarned = score / 10
        appState.updateGameScore(score)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showGameOver = true
        }
    }
}

struct Feather: Identifiable {
    let id = UUID()
    var position: CGPoint
    var rotation: Double
    var fallSpeed: CGFloat
    var rotationSpeed: Double
    var scale: CGFloat
}

#Preview {
    GameView(appState: AppState())
}
