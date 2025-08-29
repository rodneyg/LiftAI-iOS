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
    @State private var justSaved = false
    @State private var showSettingsSheet = false

    private var planService: PlanService { OpenAIServiceHTTP() }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(.systemGray6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Workout plans")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        if let g = appState.goal {
                            GoalChip(goal: g)
                        }
                    }
                    Spacer()
                    // Go Home
                    Button(action: { flow.goHome() }) {
                        Image(systemName: "house.fill")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.liftAccent)
                    }
                    .accessibilityLabel("Go Home")

                    // Secondary refresh with loading feedback
                    Button(action: generate) {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.liftAccent)
                            }
                        }
                        .frame(width: 36, height: 36)
                        .background(Color(.systemBackground).opacity(0.9))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                    }
                    .disabled(isLoading)
                    .foregroundColor(.primary)
                    
                    Button(role: .destructive) {
                        appState.clearSavedSession()
                        flow.goTo(.goal)
                    } label: {
                        Image(systemName: "trash")
                            .font(.body.weight(.semibold))
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Start over")
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Content
                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Generating workouts…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 220)
                } else if let error {
                    VStack(spacing: 10) {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .textSelection(.enabled)
                            .padding(.horizontal, 24)
                        if error.localizedCaseInsensitiveContains("Missing API key") {
                            Button {
                                showSettingsSheet = true
                            } label: {
                                Text("Set API key in Settings")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(Color.liftAccent)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                } else if workouts.isEmpty {
                    VStack(spacing: 12) {
                        Text("No workouts available.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                        Button(action: generate) {
                            Text("Try again")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color.liftAccent)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 24)
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(workouts) { w in
                                PlanCard(workout: w, goal: appState.goal)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.top, 12)
        }
        .tint(.liftAccent)
        .navigationBarHidden(true)
        .onAppear {
            if workouts.isEmpty, let cached = appState.cachedWorkouts, !cached.isEmpty {
                workouts = cached
            } else if workouts.isEmpty {
                generate()
            }
        }
        .overlay(alignment: .top) {
            if justSaved {
                Text("Saved to Dashboard")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheet().environmentObject(appState)
        }
    }

    // MARK: - Logic

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
                appState.saveCurrentSession(workouts: workouts)
                showSavedBanner()
                return
            }
            do {
                workouts = try await planService.generateWorkouts(goal: goal, context: ctx, equipments: eq)
                if workouts.isEmpty {
                    let plan = PlanEngine.generate(goal: goal, context: ctx, equipments: eq)
                    workouts = plan.workouts
                }
                appState.saveCurrentSession(workouts: workouts)
                showSavedBanner()
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                let fallback = PlanEngine.generate(goal: goal, context: ctx, equipments: eq)
                workouts = fallback.workouts
                appState.saveCurrentSession(workouts: workouts)
                showSavedBanner()
            }
        }
    }

    private func showSavedBanner() {
        withAnimation(.easeInOut(duration: 0.2)) { justSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.2)) { justSaved = false }
        }
    }
}

// MARK: - Goal chip

private struct GoalChip: View {
    let goal: Goal
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon(goal))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(accent(goal))
            Text(label(goal))
                .font(.footnote.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color(.systemBackground).opacity(0.95))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func label(_ goal: Goal) -> String {
        switch goal {
        case .strength: return "Build strength"
        case .hypertrophy: return "Build muscle"
        case .fatLoss: return "Lose fat"
        case .endurance: return "Improve endurance"
        case .mobility: return "Improve mobility"
        }
    }
    private func icon(_ goal: Goal) -> String {
        switch goal {
        case .strength: return "bolt.fill"
        case .hypertrophy: return "figure.strengthtraining.traditional"
        case .fatLoss: return "flame.fill"
        case .endurance: return "figure.run"
        case .mobility: return "figure.cooldown"
        }
    }
    private func accent(_ goal: Goal) -> Color {
        switch goal {
        case .fatLoss: return .liftAccent
        default: return .liftGold
        }
    }
}
