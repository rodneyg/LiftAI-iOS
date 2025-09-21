//
//  MicroAction.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import Foundation

/// Represents a quick, context-aware micro-action that satisfies the consistency floor
struct MicroAction: Codable, Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let type: FloorType
    let targetValue: Int // minutes or reps
    let equipment: Equipment?
    let goal: Goal
    let difficulty: ActionDifficulty
    
    enum ActionDifficulty: String, Codable, CaseIterable {
        case easy, moderate, challenging
    }
}

/// Factory for generating context-appropriate micro-actions
struct MicroActionGenerator {
    
    static func suggestedAction(
        for floor: ConsistencyFloor,
        capabilities: ContextCapabilities
    ) -> MicroAction {
        
        let actions = availableActions(for: floor.goal, capabilities: capabilities, type: floor.type)
        
        // Pick the first suitable action that meets the floor requirements
        if let suitable = actions.first(where: { $0.targetValue <= floor.value }) {
            return suitable
        }
        
        // Fallback to bodyweight/walking options
        return fallbackAction(for: floor)
    }
    
    private static func availableActions(
        for goal: Goal,
        capabilities: ContextCapabilities,
        type: FloorType
    ) -> [MicroAction] {
        
        var actions: [MicroAction] = []
        
        // Goal-specific actions
        switch goal {
        case .strength:
            if capabilities.hasSpace {
                actions.append(contentsOf: strengthBodyweightActions(type: type))
            }
            if capabilities.hasEquipment {
                actions.append(contentsOf: strengthEquipmentActions(type: type, equipment: capabilities.availableEquipment))
            }
            
        case .hypertrophy:
            if capabilities.hasSpace {
                actions.append(contentsOf: hypertrophyBodyweightActions(type: type))
            }
            if capabilities.hasEquipment {
                actions.append(contentsOf: hypertrophyEquipmentActions(type: type, equipment: capabilities.availableEquipment))
            }
            
        case .fatLoss, .endurance:
            if capabilities.canWalkOutside {
                actions.append(contentsOf: cardioOutdoorActions(type: type))
            }
            if capabilities.hasSpace {
                actions.append(contentsOf: cardioBodyweightActions(type: type))
            }
            if capabilities.hasEquipment {
                actions.append(contentsOf: cardioEquipmentActions(type: type, equipment: capabilities.availableEquipment))
            }
            
        case .mobility:
            actions.append(contentsOf: mobilityActions(type: type))
        }
        
        return actions
    }
    
    private static func fallbackAction(for floor: ConsistencyFloor) -> MicroAction {
        switch floor.goal {
        case .strength, .hypertrophy:
            return MicroAction(
                name: "Push-ups",
                description: "Classic bodyweight push-ups",
                type: floor.type,
                targetValue: floor.type == .time ? 2 : 5,
                equipment: nil,
                goal: floor.goal,
                difficulty: .easy
            )
        case .fatLoss, .endurance:
            return MicroAction(
                name: "Walk",
                description: "Easy walk or march in place",
                type: floor.type,
                targetValue: floor.type == .time ? 3 : 100,
                equipment: nil,
                goal: floor.goal,
                difficulty: .easy
            )
        case .mobility:
            return MicroAction(
                name: "Stretch",
                description: "Gentle full-body stretching",
                type: floor.type,
                targetValue: floor.type == .time ? 3 : 5,
                equipment: nil,
                goal: floor.goal,
                difficulty: .easy
            )
        }
    }
    
    // MARK: - Goal-specific action builders
    
    private static func strengthBodyweightActions(type: FloorType) -> [MicroAction] {
        [
            MicroAction(
                name: "Push-ups",
                description: "Standard push-ups",
                type: type,
                targetValue: type == .time ? 2 : 5,
                equipment: nil,
                goal: .strength,
                difficulty: .easy
            ),
            MicroAction(
                name: "Bodyweight Squats",
                description: "Air squats",
                type: type,
                targetValue: type == .time ? 2 : 10,
                equipment: nil,
                goal: .strength,
                difficulty: .easy
            )
        ]
    }
    
    private static func strengthEquipmentActions(type: FloorType, equipment: [Equipment]) -> [MicroAction] {
        var actions: [MicroAction] = []
        
        if equipment.contains(.dumbbells) {
            actions.append(MicroAction(
                name: "Dumbbell Press",
                description: "Light dumbbell chest press",
                type: type,
                targetValue: type == .time ? 3 : 8,
                equipment: .dumbbells,
                goal: .strength,
                difficulty: .moderate
            ))
        }
        
        if equipment.contains(.pullupBar) {
            actions.append(MicroAction(
                name: "Assisted Pull-ups",
                description: "Band-assisted or negative pull-ups",
                type: type,
                targetValue: type == .time ? 2 : 3,
                equipment: .pullupBar,
                goal: .strength,
                difficulty: .moderate
            ))
        }
        
        return actions
    }
    
    private static func hypertrophyBodyweightActions(type: FloorType) -> [MicroAction] {
        [
            MicroAction(
                name: "Wall Sits",
                description: "Isometric wall sit hold",
                type: type,
                targetValue: type == .time ? 1 : 1,
                equipment: nil,
                goal: .hypertrophy,
                difficulty: .moderate
            ),
            MicroAction(
                name: "Glute Bridges",
                description: "Hip bridge holds",
                type: type,
                targetValue: type == .time ? 2 : 15,
                equipment: nil,
                goal: .hypertrophy,
                difficulty: .easy
            )
        ]
    }
    
    private static func hypertrophyEquipmentActions(type: FloorType, equipment: [Equipment]) -> [MicroAction] {
        var actions: [MicroAction] = []
        
        if equipment.contains(.dumbbells) {
            actions.append(MicroAction(
                name: "Dumbbell Curls",
                description: "Light bicep curls",
                type: type,
                targetValue: type == .time ? 2 : 12,
                equipment: .dumbbells,
                goal: .hypertrophy,
                difficulty: .easy
            ))
        }
        
        return actions
    }
    
    private static func cardioOutdoorActions(type: FloorType) -> [MicroAction] {
        [
            MicroAction(
                name: "Walk",
                description: "Gentle outdoor walk",
                type: type,
                targetValue: type == .time ? 5 : 200,
                equipment: nil,
                goal: .endurance,
                difficulty: .easy
            )
        ]
    }
    
    private static func cardioBodyweightActions(type: FloorType) -> [MicroAction] {
        [
            MicroAction(
                name: "Marching",
                description: "March in place",
                type: type,
                targetValue: type == .time ? 3 : 50,
                equipment: nil,
                goal: .endurance,
                difficulty: .easy
            ),
            MicroAction(
                name: "Jumping Jacks",
                description: "Light jumping jacks",
                type: type,
                targetValue: type == .time ? 2 : 20,
                equipment: nil,
                goal: .endurance,
                difficulty: .moderate
            )
        ]
    }
    
    private static func cardioEquipmentActions(type: FloorType, equipment: [Equipment]) -> [MicroAction] {
        var actions: [MicroAction] = []
        
        if equipment.contains(.treadmill) {
            actions.append(MicroAction(
                name: "Treadmill Walk",
                description: "Easy treadmill walk",
                type: type,
                targetValue: type == .time ? 5 : 300,
                equipment: .treadmill,
                goal: .endurance,
                difficulty: .easy
            ))
        }
        
        if equipment.contains(.bike) {
            actions.append(MicroAction(
                name: "Stationary Bike",
                description: "Light cycling",
                type: type,
                targetValue: type == .time ? 5 : 1,
                equipment: .bike,
                goal: .endurance,
                difficulty: .easy
            ))
        }
        
        return actions
    }
    
    private static func mobilityActions(type: FloorType) -> [MicroAction] {
        [
            MicroAction(
                name: "Neck Rolls",
                description: "Gentle neck mobility",
                type: type,
                targetValue: type == .time ? 1 : 5,
                equipment: nil,
                goal: .mobility,
                difficulty: .easy
            ),
            MicroAction(
                name: "Shoulder Circles",
                description: "Arm circles and shoulder rolls",
                type: type,
                targetValue: type == .time ? 2 : 10,
                equipment: nil,
                goal: .mobility,
                difficulty: .easy
            ),
            MicroAction(
                name: "Hip Circles",
                description: "Hip mobility circles",
                type: type,
                targetValue: type == .time ? 2 : 8,
                equipment: nil,
                goal: .mobility,
                difficulty: .easy
            )
        ]
    }
}