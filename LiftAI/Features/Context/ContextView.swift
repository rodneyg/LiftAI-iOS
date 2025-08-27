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
    @State private var selection: TrainingContext? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Goal: \(goalText)").foregroundStyle(.secondary)

            Button { selection = .gym } label: {
                rowLabel("Gym", selected: selection == .gym, icon: "building.2.crop.circle")
            }
            Button { selection = .home } label: {
                rowLabel("Home", selected: selection == .home, icon: "house.circle")
            }

            HStack(spacing: 12) {
                Spacer()
                Button("Continue") { continueFlow() }
                    .buttonStyle(.borderedProminent)
                    .disabled(selection == nil)
            }
        }
        .padding()
        .navigationTitle("Where are you training?")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func continueFlow() {
        guard let sel = selection else { return }
        appState.context = sel
        if sel == .gym { flow.goTo(.permissions) } else { flow.goTo(.plan) }
    }

    private func rowLabel(_ title: String, selected: Bool, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            if selected { Image(systemName: "checkmark.circle.fill") }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(selected ? Color.accentColor : .secondary, lineWidth: 1))
    }

    private var goalText: String {
        guard let g = appState.goal else { return "Not set" }
        switch g {
        case .strength: return "Build strength"
        case .hypertrophy: return "Build muscle"
        case .fatLoss: return "Lose fat"
        case .endurance: return "Improve endurance"
        case .mobility: return "Improve mobility"
        }
    }
}
