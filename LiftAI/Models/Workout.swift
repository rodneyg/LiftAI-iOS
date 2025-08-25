//
//  Workout.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation

struct Movement: Codable, Equatable {
    var name: String
    var equipment: Equipment?
    var primary: String
    var tempo: String?
}

struct Workout: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var blocks: [[Movement]] // supersets as inner arrays
    var estMinutes: Int
}
