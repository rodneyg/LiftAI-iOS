//
//  PlanView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct PlanView: View {
    @EnvironmentObject var flow: FlowController
    @EnvironmentObject var appState: AppState
    @State private var loadResult: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("Plan").font(.title2).bold()
            Text("Context: \(appState.context?.rawValue ?? "unknown")")
                .foregroundStyle(.secondary)

            HStack {
                Button("Save Test Plan") { saveDummy() }
                Button("Load Test Plan") { loadDummy() }
            }
            Text(loadResult).font(.footnote).foregroundStyle(.secondary)

            Button("Restart") { flow.reset() }
        }
        .padding()
        .navigationTitle("Plan")
    }

    private func saveDummy() {
        let w = Workout(title: "Full Body A",
                        blocks: [[Movement(name: "Squat", equipment: .squatRack, primary: "quads", tempo: nil)]],
                        estMinutes: 45)
        let plan = Plan(goal: .strength, workouts: [w])
        do {
            try Persistence.save(plan, as: "plan.json")
            loadResult = "Saved plan.json"
        } catch {
            loadResult = "Save failed: \(error.localizedDescription)"
        }
    }

    private func loadDummy() {
        do {
            let plan: Plan = try Persistence.load(Plan.self, from: "plan.json")
            loadResult = "Loaded: \(plan.goal.rawValue), \(plan.workouts.first?.title ?? "n/a")"
        } catch {
            loadResult = "Load failed: \(error.localizedDescription)"
        }
    }
}
