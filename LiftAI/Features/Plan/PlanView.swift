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
    @State private var plan: Plan? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plan").font(.title2).bold()
            Text("Context: \(appState.context?.rawValue ?? "unknown")").foregroundStyle(.secondary)

            if let gp = appState.gymProfile {
                Text("Equipment count: \(gp.equipments.count)").font(.subheadline)
                WrapChips(items: gp.equipments.map(\.rawValue))
            }

            Button("Generate Plan") {
                guard let goal = appState.goal, let ctx = appState.context else { return }
                let eq = appState.gymProfile?.equipments ?? []
                plan = PlanEngine.generate(goal: goal, context: ctx, equipments: eq)
            }
            .buttonStyle(.borderedProminent)

            if let plan {
                ForEach(plan.workouts) { w in
                    Text("• \(w.title)").font(.body)
                }
            } else {
                Text("No plan yet. Tap Generate.").font(.footnote).foregroundStyle(.secondary)
            }

            Divider().padding(.vertical, 4)

            HStack {
                Button("Save Test Plan") { saveDummy() }
                Button("Load Test Plan") { loadDummy() }
            }
            Text(loadResult).font(.footnote).foregroundStyle(.secondary)

            Spacer()
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
