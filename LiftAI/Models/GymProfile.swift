//
//  GymProfile.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation

struct GymProfile: Codable, Equatable {
    var equipments: [Equipment]
    var photoIdentifiers: [String] = []
}
