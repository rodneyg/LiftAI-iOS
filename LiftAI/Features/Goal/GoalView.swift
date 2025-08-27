//
//  GoalView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct GoalView: View {
    @EnvironmentObject var flow: FlowController
    @EnvironmentObject var appState: AppState
    @State private var selection: Goal? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose your goal").font(.title2).bold()

            ForEach(Goal.allCases, id: \.self) { g in
                Button {
                    selection = g
                } label: {
                    HStack {
                        Text(label(for: g)).font(.body)
                        Spacer()
                        if selection == g { Image(systemName: "checkmark.circle.fill") }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).stroke(selection == g ? Color.accentColor : Color.secondary, lineWidth: 1))
                }
            }

            Button("Next: Context") {
                appState.goal = selection
                flow.goTo(.context)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selection == nil)

        }
        .padding()
        .navigationTitle("Goal")
    }

    private func label(for goal: Goal) -> String {
        switch goal {
        case .strength: return "Build strength"
        case .hypertrophy: return "Build muscle"
        case .fatLoss: return "Lose fat"
        case .endurance: return "Improve endurance"
        case .mobility: return "Improve mobility"
        }
    }
}
