//
//  DashboardView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

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

                        // Equipment summary (compact)
                        if !s.equipments.isEmpty {
                            Text("Equipment")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(s.equipments, id: \.self) { e in
                                        Capsule()
                                            .fill(Color(.systemGray6))
                                            .overlay(
                                                Text(friendly(e))
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                            )
                                    }
                                }
                            }
                        }

                        // Actions (not wired yet; navigation will be in step 6/4)
                        HStack {
                            Button {
                                // wired in a later step: navigate to PlanView using saved data
                            } label: {
                                Label("View plan", systemImage: "arrow.right.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(Color.liftAccent)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }

                            Button(role: .destructive) {
                                // allowed to clear storage; navigation reset arrives later
                                appState.clearSavedSession()
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
                    // No session: simple CTA to begin flow (wired later)
                    VStack(spacing: 14) {
                        Text("No saved plan yet")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Create your first plan in a few steps.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            // wired in a later step: go to GoalView
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
    }

    // MARK: - Helpers

    private var subtitle: String {
        if appState.savedSession != nil { return "Welcome back" }
        return "Let’s get started"
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

// Small pill
private struct InfoPill: View {
    let system: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: system)
            Text(text)
                .lineLimit(1)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .foregroundColor(.primary)
    }
}
