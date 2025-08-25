//
//  ContextView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct ContextView: View {
    @EnvironmentObject var flow: FlowController
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Text("Context").font(.title2).bold()
            Text("Goal: \(goalText)").foregroundStyle(.secondary)
            Button("Next: Permissions") { flow.advance(from: .context) }
        }
        .padding()
        .navigationTitle("Context")
    }

    private var goalText: String {
        guard let g = appState.goal else { return "Not set" }
        switch g {
        case .strength: return "Strength"
        case .hypertrophy: return "Hypertrophy"
        case .fatLoss: return "Fat Loss"
        case .endurance: return "Endurance"
        case .mobility: return "Mobility"
        }
    }
}
