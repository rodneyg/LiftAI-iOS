//
//  DetectView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct DetectView: View {
    @EnvironmentObject var flow: FlowController
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = DetectViewModel()
    @State private var didStart = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(.systemGray6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Hero
                VStack(spacing: 6) {
                    Text("Your gym")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    if vm.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Looking at your photos…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else if let err = vm.error {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    } else if !vm.equipments.isEmpty {
                        Text(friendlySubtitle(vm.equipments.count))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Results grid
                if !vm.equipments.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 16)], spacing: 16) {
                            ForEach(vm.equipments, id: \.self) { eq in
                                equipmentCard(eq)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                } else if !vm.isLoading && vm.error == nil {
                    Text("We couldn’t spot any equipment. Try clearer photos.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                Spacer()

                // Continue
                let canContinue = !vm.isLoading && !vm.equipments.isEmpty
                Button {
                    appState.gymProfile = GymProfile(equipments: vm.equipments)
                    flow.advance(from: .detect)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canContinue ? Color.liftAccent : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                        .shadow(color: canContinue ? .liftAccent.opacity(0.35) : .clear,
                                radius: 10, x: 0, y: 5)
                        .animation(.easeInOut, value: canContinue)
                }
                .disabled(!canContinue)
                .padding(.bottom, 24)
            }
            .padding(.top, 40)
        }
        .navigationBarHidden(true)
        .onAppear {
            guard !didStart else { return }
            didStart = true
            Task { await vm.runDetection(with: appState.capturedImages) }
        }
    }

    // MARK: - Components

    private func equipmentCard(_ eq: Equipment) -> some View {
        VStack(spacing: 8) {
            Image(systemName: eq.iconName)
                .font(.largeTitle)
                .foregroundColor(.liftAccent)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Color(.systemBackground).opacity(0.9)))
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)

            Text(eq.friendlyName)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
        )
    }

    private func friendlySubtitle(_ n: Int) -> String {
        switch n {
        case 1:  return "Found 1 piece of equipment"
        default: return "Found \(n) pieces of equipment"
        }
    }
}

// MARK: - Presentation helpers

extension Equipment {
    var friendlyName: String {
        switch self {
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
        default:
            return rawValue
                .replacingOccurrences(of: "([a-z])([A-Z])",
                                      with: "$1 $2",
                                      options: .regularExpression)
                .capitalized
        }
    }

    var iconName: String {
        switch self {
        case .dumbbells: return "dumbbell"
        case .barbell: return "dumbbell"
        case .squatRack, .smithMachine: return "figure.strengthtraining.traditional"
        case .benchFlat, .benchIncline: return "rectangle.fill"
        case .treadmill: return "figure.run"
        case .bike: return "bicycle"
        case .rower: return "figure.rower"
        case .pullupBar: return "figure.strengthtraining.functional" // fallback icon for pull-up
        case .cableMachine, .latPulldown: return "square.grid.2x2"
        case .legPress: return "rectangle.compress.vertical"
        default: return "square.grid.2x2"
        }
    }
}
