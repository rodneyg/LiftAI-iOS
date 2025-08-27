//
//  Add.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var flow = FlowController()
    @StateObject private var appState = AppState()
    @State private var showSettings = false

    var body: some View {
        NavigationStack(path: $flow.path) {
            LiftAISplashView() // start at splash
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .splash: LiftAISplashView()
                    case .goal: GoalView()
                    case .context: ContextView()
                    case .permissions: PermissionsView()
                    case .capture: CaptureView()
                    case .detect: DetectView()
                    case .plan: PlanView()
                    }
                }
                .toolbar {
                    // hide settings on splash (path is empty on splash)
                    if !flow.path.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        }
                    }
                }
        }
        .tint(.liftAccent) // global accent
        .environmentObject(flow)
        .environmentObject(appState)
        .sheet(isPresented: $showSettings) { SettingsSheet().environmentObject(appState) }
    }
}

