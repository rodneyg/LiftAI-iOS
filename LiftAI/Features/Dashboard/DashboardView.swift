//
//  DashboardView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var flow: FlowController

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(.systemGray6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("LiftAI")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

                if let s = appState.savedSession {
                    // Saved session card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Last session")
                                .font(.headline)
                            Spacer()
                            Text(dateString(s.savedAt))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Quick facts row
                        HStack(spacing: 10) {
                            InfoPill(system: "target", text: goalLabel(s.goal))
                            InfoPill(system: "clock", text: "\(totalMinutes(s.workouts)) min")
                            InfoPill(system: "list.bullet.rectangle", text: "\(s.workouts.count) workouts")
                        }

                        // Equipment summary (compact) — FIXED CHIPS
                        if !s.equipments.isEmpty {
                            Text("Equipment")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(s.equipments, id: \.self) { e in
                                        EquipmentChip(text: friendly(e))
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }

                        // Actions
                        HStack {
                            Button {
                                // hydrate state and go straight to Plan
                                appState.goal = s.goal
                                appState.context = s.context
                                appState.gymProfile = GymProfile(equipments: s.equipments)
                                appState.cachedWorkouts = s.workouts
                                flow.goTo(.plan)
                            } label: {
                                Label("View plan", systemImage: "arrow.right.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(Color.liftAccent)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }

                            Button(role: .destructive) {
                                appState.clearSavedSession()
                                flow.goTo(.goal)
                            } label: {
                                Label("Start over", systemImage: "arrow.counterclockwise")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground).opacity(0.98))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                } else {
                    // No session: CTA to begin flow
                    VStack(spacing: 14) {
                        Text("No saved plan yet")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Create your first plan in a few steps.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            flow.goTo(.goal)
                        } label: {
                            Text("Begin")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 18).padding(.vertical, 12)
                                .background(Color.liftAccent)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground).opacity(0.98))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                }
            }
            .padding(.top, 24)
        }
        .navigationBarHidden(true)
        .tint(.liftAccent)
    }

    // MARK: - Helpers

    private var subtitle: String {
        appState.savedSession != nil ? "Welcome back" : "Let’s get started"
    }

    private func dateString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: d)
    }

    private func totalMinutes(_ workouts: [Workout]) -> Int {
        workouts.reduce(0) { $0 + $1.estMinutes }
    }

    private func goalLabel(_ g: Goal) -> String {
        switch g {
        case .strength: return "Strength"
        case .hypertrophy: return "Muscle"
        case .fatLoss: return "Fat loss"
        case .endurance: return "Endurance"
        case .mobility: return "Mobility"
        }
    }

    private func friendly(_ e: Equipment) -> String {
        switch e {
        case .benchFlat: return "Flat bench"
        case .benchIncline: return "Incline bench"
        case .latPulldown: return "Lat pulldown"
        case .pullupBar: return "Pull-up bar"
        case .squatRack: return "Squat rack"
        case .cableMachine: return "Cable machine"
        case .legPress: return "Leg press"
        case .smithMachine: return "Smith machine"
        case .barbell: return "Barbell"
        case .dumbbells: return "Dumbbells"
        case .treadmill: return "Treadmill"
        case .bike: return "Exercise bike"
        case .rower: return "Rowing machine"
        default: return e.rawValue
        }
    }
}

// Fixed chip view to avoid skinny vertical capsules
private struct EquipmentChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color(.systemGray6))
            )
            .fixedSize(horizontal: true, vertical: false)
    }
}

// Small pill
private struct InfoPill: View {
    let system: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: system)
            Text(text).lineLimit(1)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .foregroundColor(.primary)
    }
}
