//
//  RootView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var flow = FlowController()
    @StateObject private var appState = AppState()
    @State private var showSettings = false

    private enum StartRoute { case splash, dashboard, goal }
    @State private var startRoute: StartRoute = .splash

    var body: some View {
        NavigationStack(path: $flow.path) {
            Group {
                switch startRoute {
                case .splash:
                    SplashView {
                        if SavedSessionStore.shared.exists() {
                            startRoute = .dashboard
                        } else {
                            startRoute = .goal
                        }
                    }
                case .dashboard:
                    DashboardView()
                case .goal:
                    GoalView()
                }
            }
            .navigationDestination(for: Step.self) { step in
                switch step {
                case .goal: GoalView()
                case .context: ContextView()
                case .permissions: PermissionsView()
                case .capture: CaptureView()
                case .detect: DetectView()
                case .plan: PlanView()
                @unknown default:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                }
            }
        }
        .tint(.liftAccent)
        .environmentObject(flow)
        .environmentObject(appState)
        .sheet(isPresented: $showSettings) { SettingsSheet().environmentObject(appState) }
    }
}
