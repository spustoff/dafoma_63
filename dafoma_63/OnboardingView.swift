//
//  OnboardingView.swift
//  CluckPlan
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appState: AppState
    @State private var currentPage = 0
    @State private var animateBackground = false
    @State private var animateContent = false
    
    private let pages = [
        OnboardingPage(
            title: "Turn chaos into flow",
            subtitle: "Transform your daily tasks into a beautiful, organized experience",
            imageName: "sun.max.fill",
            color: Color(hex: "#FFB800")
        ),
        OnboardingPage(
            title: "Plan with purpose",
            subtitle: "Schedule your day, track your progress, and celebrate every achievement",
            imageName: "calendar",
            color: Color(hex: "#FF6B35")
        ),
        OnboardingPage(
            title: "Take mindful breaks",
            subtitle: "Enjoy a relaxing feather collection game between productive sessions",
            imageName: "gamecontroller.fill",
            color: Color(hex: "#4CAF50")
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated Background
                AnimatedBackground()
                
                VStack(spacing: 0) {
                    // Content Area
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(
                                page: pages[index],
                                isActive: currentPage == index
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                    
                    // Bottom Section
                    VStack(spacing: 20) {
                        // Page Indicators
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color(hex: "#FFB800") : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Action Button
                        Button(action: {
                            if currentPage < pages.count - 1 {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage += 1
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    appState.currentScreen = .planner
                                }
                            }
                        }) {
                            HStack {
                                Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                if currentPage < pages.count - 1 {
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
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
                        .padding(.horizontal, 32)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: animateContent)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            animateBackground = true
            animateContent = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var animateIcon = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.color.opacity(0.2), page.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateIcon)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(page.color)
                    .scaleEffect(animateIcon ? 1.0 : 0.3)
                    .rotationEffect(.degrees(animateIcon ? 0 : -180))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.4), value: animateIcon)
            }
            
            // Text Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#2E2E2E"))
                    .multilineTextAlignment(.center)
                    .offset(y: animateText ? 0 : 30)
                    .opacity(animateText ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: animateText)
                
                Text(page.subtitle)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color(hex: "#2E2E2E").opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 32)
                    .offset(y: animateText ? 0 : 20)
                    .opacity(animateText ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.8), value: animateText)
            }
            
            Spacer()
        }
        .onChange(of: isActive) { active in
            if active {
                animateIcon = true
                animateText = true
            } else {
                animateIcon = false
                animateText = false
            }
        }
        .onAppear {
            if isActive {
                animateIcon = true
                animateText = true
            }
        }
    }
}

struct AnimatedBackground: View {
    @State private var animateGradient = false
    @State private var animateParticles = false
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#FFF6D9"),
                    Color(hex: "#FFE5B4").opacity(0.8)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: animateGradient)
            
            // Floating particles
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FFB800").opacity(0.1),
                                Color(hex: "#FF6B35").opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animateParticles ? 1.2 : 0.8)
                    .opacity(animateParticles ? 0.6 : 0.2)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: animateParticles
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
            animateParticles = true
        }
    }
}

#Preview {
    OnboardingView(appState: AppState())
}
