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

                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Generating workouts…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                } else if workouts.isEmpty {
                    Text("No workouts available. Try refresh.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 12) {
                        Button(action: generate) {
                            Label("Refresh plans", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(workouts) { w in PlanCard(workout: w) }
                    }
                }
            }
            .padding()
            .padding(.bottom, 32)
        }
        .navigationTitle("Workout plans")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if workouts.isEmpty { generate() }
        }
    }

    private func generate() {
        error = nil
        isLoading = true
        Task {
            defer { isLoading = false }
            guard let goal = appState.goal, let ctx = appState.context else {
                error = "Missing goal or context"; return
            }
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
                let fallback = PlanEngine.generate(goal: goal, context: ctx, equipments: eq)
                workouts = fallback.workouts
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
}
