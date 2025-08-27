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

    @State private var isLoading = false
    @State private var error: String? = nil
    @State private var workouts: [Workout] = []
    private var planService: PlanService { OpenAIServiceHTTP() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let g = appState.goal {
                    Text("Goal: \(friendly(g))").foregroundStyle(.secondary)
                }
                if let gp = appState.gymProfile, !gp.equipments.isEmpty {
                    Text("Detected equipment").font(.subheadline).bold()
                    WrapChips(items: gp.equipments.map { friendly($0) })
                }

                HStack(spacing: 12) {
                    Button(action: generate) {
                        if isLoading { ProgressView().padding(.horizontal, 8) }
                        else { Label("Build my plan", systemImage: "bolt.fill") }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)

                    if !workouts.isEmpty {
                        Button(action: generate) { Label("Refresh", systemImage: "arrow.clockwise") }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                    }
                }

                if let error { Text(error).font(.footnote).foregroundStyle(.red).textSelection(.enabled) }
                if workouts.isEmpty && !isLoading {
                    Text("No plan yet. Tap “Build my plan”.").font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(workouts) { w in
                        PlanCard(workout: w)
                    }
                }
            }
            .padding()
            .padding(.bottom, 32)   // ensures scroll safe zone
        }
        .navigationTitle("Your plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func generate() {
        error = nil
        isLoading = true
        Task {
            defer { isLoading = false }
            guard let goal = appState.goal, let ctx = appState.context else { error = "Missing goal or context"; return }
            let eq = appState.gymProfile?.equipments ?? []
            if appState.offlineOnly {
                let plan = PlanEngine.generate(goal: goal, context: ctx, equipments: eq)
                workouts = plan.workouts
                return
            }
            do {
                workouts = try await planService.generateWorkouts(goal: goal, context: ctx, equipments: eq)
                if workouts.isEmpty {
                    let plan = PlanEngine.generate(goal: goal, context: ctx, equipments: eq)
                    workouts = plan.workouts
                }
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                let plan = PlanEngine.generate(goal: goal, context: ctx, equipments: eq)
                workouts = plan.workouts
            }
        }
    }

    private func friendly(_ goal: Goal) -> String {
        switch goal {
        case .strength: return "Build strength"
        case .hypertrophy: return "Build muscle"
        case .fatLoss: return "Lose fat"
        case .endurance: return "Improve endurance"
        case .mobility: return "Improve mobility"
        }
    }
    private func friendly(_ e: Equipment) -> String {
        switch e {
        case .benchFlat: return "Flat bench"
        case .benchIncline: return "Incline bench"
        case .latPulldown: return "Lat pulldown"
        case .pullupBar: return "Pull-up bar"
        default: return e.rawValue
        }
    }
}
