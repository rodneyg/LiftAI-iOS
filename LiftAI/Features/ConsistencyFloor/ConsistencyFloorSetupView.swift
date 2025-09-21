//
//  ConsistencyFloorSetupView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import SwiftUI

struct ConsistencyFloorSetupView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var flow: FlowController
    
    @State private var selectedType: FloorType = .reps
    @State private var timeValue: Int = 5
    @State private var repsValue: Int = 10
    @State private var selectedAction: String = "Push-ups"
    @State private var showingConfirmation = false
    
    // Pre-defined action templates
    private let timeActions = ["Walk", "Stretch", "Mobility drill"]
    private let repsActions = ["Push-ups", "Squats", "Jumping jacks", "Planks"]
    
    var body: some View {
        ZStack {
            // Brand background
            LinearGradient(
                colors: [Color.black, Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Set your Consistency Floor")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("A simple daily action you can always complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Goal context
                if let goal = appState.goal {
                    goalChip(for: goal)
                }
                
                // Floor type selection
                VStack(spacing: 16) {
                    Text("Choose your floor type")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        ForEach(FloorType.allCases, id: \.self) { type in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedType = type
                                    // Set default action for type
                                    selectedAction = type == .time ? timeActions[0] : repsActions[0]
                                }
                            } label: {
                                HStack {
                                    Image(systemName: type == .time ? "clock" : "number")
                                    Text(type == .time ? "Time-based" : "Rep-based")
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(selectedType == type ? Color.liftAccent : Color(.systemGray6))
                                .foregroundColor(selectedType == type ? .white : .primary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Action selection
                VStack(spacing: 16) {
                    Text("Pick your action")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    let actions = selectedType == .time ? timeActions : repsActions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(actions, id: \.self) { action in
                                Button {
                                    selectedAction = action
                                } label: {
                                    Text(action)
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(selectedAction == action ? Color.liftAccent : Color(.systemGray6))
                                        .foregroundColor(selectedAction == action ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Value selection
                VStack(spacing: 16) {
                    if selectedType == .time {
                        Text("How many minutes?")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            ForEach([1, 3, 5, 10], id: \.self) { minutes in
                                Button {
                                    timeValue = minutes
                                } label: {
                                    Text("\(minutes) min")
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(timeValue == minutes ? Color.liftAccent : Color(.systemGray6))
                                        .foregroundColor(timeValue == minutes ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    } else {
                        Text("How many reps?")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            ForEach([5, 10, 15, 20], id: \.self) { reps in
                                Button {
                                    repsValue = reps
                                } label: {
                                    Text("\(reps)")
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(repsValue == reps ? Color.liftAccent : Color(.systemGray6))
                                        .foregroundColor(repsValue == reps ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Confirmation
                VStack(spacing: 12) {
                    Text("Your floor:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(floorDescription)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.liftAccent.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Button {
                        saveFloorAndContinue()
                    } label: {
                        Text("Set my floor")
                            .font(.headline.weight(.semibold))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color.liftAccent)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Skip") {
                    // Continue without setting floor
                    flow.goHome()
                }
                .foregroundColor(.liftAccent)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var floorDescription: String {
        if selectedType == .time {
            return "\(timeValue) minute\(timeValue == 1 ? "" : "s") of \(selectedAction.lowercased())"
        } else {
            return "\(repsValue) \(selectedAction.lowercased())"
        }
    }
    
    private func goalChip(for goal: Goal) -> some View {
        HStack(spacing: 6) {
            Image(systemName: goalIcon(goal))
                .font(.caption.weight(.semibold))
                .foregroundColor(.liftAccent)
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
    
    private func saveFloorAndContinue() {
        guard let goal = appState.goal, let context = appState.context else { return }
        
        // Determine capabilities based on context and equipment
        let capabilities: ContextCapabilities
        if context == .gym {
            let equipment = appState.gymProfile?.equipments ?? []
            capabilities = ContextCapabilities(
                hasEquipment: !equipment.isEmpty,
                availableEquipment: equipment,
                hasSpace: true,
                canWalkOutside: false
            )
        } else {
            capabilities = ContextCapabilities.defaultHome
        }
        
        let floor = ConsistencyFloor(
            goal: goal,
            type: selectedType,
            definition: selectedAction,
            value: selectedType == .time ? timeValue : repsValue,
            contextCapabilities: capabilities
        )
        
        appState.saveConsistencyFloor(floor)
        
        // Navigate back to dashboard after setting up floor
        flow.goHome()
    }
}