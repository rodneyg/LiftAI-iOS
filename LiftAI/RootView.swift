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
            GoalView()
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .goal: GoalView()
                    case .context: ContextView()
                    case .permissions: PermissionsView()
                    case .capture: CaptureView()
                    case .detect: DetectView()
                    case .plan: PlanView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showSettings = true } label: { Image(systemName: "gearshape") }
                    }
                }
        }
        .environmentObject(flow)
        .environmentObject(appState)
        .sheet(isPresented: $showSettings) { SettingsSheet().environmentObject(appState) }
    }
}
