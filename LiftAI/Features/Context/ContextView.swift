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
    @Namespace private var anim

    var body: some View {
        ZStack {
            // Brand background
            LinearGradient(
                colors: [Color.black, Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                // Hero
                VStack(spacing: 14) {
                    Text("Where do you train?")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .transition(.move(edge: .top).combined(with: .opacity))

                    if let g = appState.goal {
                        goalChip(for: g)
                            .transition(.opacity.combined(with: .scale))
                    }
                }

                // Options
                VStack(spacing: 16) {
                    optionCard(title: "Gym", icon: "building.2.crop.circle", value: .gym)
                    optionCard(title: "Home", icon: "house.circle", value: .home)
                }

                Spacer()

                // Continue
                Button {
                    guard let sel = selection else { return }
                    appState.context = sel
                    if sel == .gym { flow.goTo(.permissions) } else { flow.goTo(.plan) }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selection == nil ? Color.gray.opacity(0.4) : Color.liftAccent)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                        .shadow(color: selection == nil ? .clear : .liftAccent.opacity(0.35),
                                radius: 10, x: 0, y: 5)
                        .animation(.easeInOut, value: selection != nil)
                }
                .disabled(selection == nil)
                .padding(.bottom, 24)
            }
            .padding(.top, 40)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Components

    @ViewBuilder
    private func optionCard(title: String, icon: String, value: TrainingContext) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selection = value
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.primary)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if selection == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.liftAccent)
                        .matchedGeometryEffect(id: "ctx-check", in: anim)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(selection == value ? 1.03 : 1.0)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
    }

    // Premium goal chip (icon over label)
    @ViewBuilder
    private func goalChip(for goal: Goal) -> some View {
        VStack(spacing: 6) {
            Image(systemName: goalIcon(goal))
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.liftAccent)
                .shadow(color: .liftAccent.opacity(0.5), radius: 6, x: 0, y: 0)
            Text(friendlyGoal(goal))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 6)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            Capsule(style: .continuous)
                .fill(Color(.systemBackground).opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }

    private func friendlyGoal(_ goal: Goal) -> String {
        switch goal {
        case .strength: return "Build strength"
        case .hypertrophy: return "Build muscle"
        case .fatLoss: return "Lose fat"
        case .endurance: return "Improve endurance"
        case .mobility: return "Improve mobility"
        }
    }

    private func goalIcon(_ goal: Goal) -> String {
        switch goal {
        case .strength: return "bolt.fill"
        case .hypertrophy: return "figure.strengthtraining.traditional"
        case .fatLoss: return "flame.fill"
        case .endurance: return "figure.run"
        case .mobility: return "figure.cooldown"
        }
    }
}
