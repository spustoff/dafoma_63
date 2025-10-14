//
//  CluckPlanApp.swift
//  CluckPlan
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

@main
struct CluckPlanApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.light) // Force light mode for consistent design
        }
    }
}
