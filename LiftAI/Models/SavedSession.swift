//
//  SavedSession.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import Foundation

struct SavedSession: Codable, Equatable {
    let savedAt: Date
    let goal: Goal
    let context: TrainingContext
    let equipments: [Equipment]
    let workouts: [Workout]
    let consistencyFloor: ConsistencyFloor?
    
    // Backward compatibility initializer
    init(savedAt: Date, goal: Goal, context: TrainingContext, equipments: [Equipment], workouts: [Workout], consistencyFloor: ConsistencyFloor? = nil) {
        self.savedAt = savedAt
        self.goal = goal
        self.context = context
        self.equipments = equipments
        self.workouts = workouts
        self.consistencyFloor = consistencyFloor
    }
}
