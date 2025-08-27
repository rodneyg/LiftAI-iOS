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
}
