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
    @Namespace private var anim

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Hero text
                VStack(spacing: 8) {
                    Text("What’s your focus?")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .transition(.move(edge: .top).combined(with: .opacity))

                    Text("Select a goal to shape your workouts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Goal cards
                VStack(spacing: 16) {
                    ForEach(Goal.allCases, id: \.self) { g in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selection = g
                            }
                        } label: {
                            HStack {
                                Text(label(for: g))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selection == g {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.liftAccent)
                                        .matchedGeometryEffect(id: "checkmark", in: anim)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.systemBackground).opacity(0.9))
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                            .scaleEffect(selection == g ? 1.03 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                    }
                }

                Spacer()

                // Continue button
                Button {
                    appState.goal = selection
                    flow.goTo(.context)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selection == nil ? Color.gray.opacity(0.4) : Color.liftAccent)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                        .shadow(color: selection == nil ? .clear : .liftAccent.opacity(0.4),
                                radius: 10, x: 0, y: 5)
                        .animation(.easeInOut, value: selection != nil)
                }
                .disabled(selection == nil)
                .padding(.bottom, 24)
            }
            .padding(.top, 40)
        }
        // Only show back button if this view was pushed
        .navigationBarBackButtonHidden(false)
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
