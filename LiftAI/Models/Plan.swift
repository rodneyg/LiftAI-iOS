//
//  Plan.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation

struct Plan: Codable, Equatable {
    var goal: Goal
    var workouts: [Workout]
}
