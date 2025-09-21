//
//  ConsistencyFloor.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import Foundation

/// Represents the type of consistency floor - either time-based or rep-based
enum FloorType: String, Codable, CaseIterable {
    case time, reps
}

/// A user-defined minimum viable daily action
struct ConsistencyFloor: Codable, Equatable {
    let goal: Goal
    let type: FloorType
    let definition: String // e.g., "5 minutes", "10 push-ups"
    let value: Int // 5 (minutes) or 10 (reps)
    let contextCapabilities: ContextCapabilities
    
    /// Quick access to friendly display string
    var displayText: String {
        switch type {
        case .time:
            return "\(value) minute\(value == 1 ? "" : "s")"
        case .reps:
            return "\(value) \(definition.lowercased())"
        }
    }
}

/// Defines what equipment/space is available for micro-actions
struct ContextCapabilities: Codable, Equatable {
    let hasEquipment: Bool
    let availableEquipment: [Equipment]
    let hasSpace: Bool // for bodyweight exercises
    let canWalkOutside: Bool
    
    static let defaultHome = ContextCapabilities(
        hasEquipment: false,
        availableEquipment: [],
        hasSpace: true,
        canWalkOutside: true
    )
    
    static let defaultGym = ContextCapabilities(
        hasEquipment: true,
        availableEquipment: Equipment.allCases,
        hasSpace: true,
        canWalkOutside: false
    )
}

/// Tracks daily completion status
struct DailyFloorStatus: Codable, Equatable {
    let date: Date
    let met: Bool
    let actionId: String? // what action was performed
    let duration: Int? // minutes for time-based
    let reps: Int? // count for rep-based
    let completedAt: Date?
    
    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

/// Rolling statistics for consistency tracking
struct ConsistencyStats: Codable, Equatable {
    let last7Days: Double // percentage 0.0-1.0
    let last30Days: Double
    let last90Days: Double
    let currentStreak: Int // consecutive days
    let longestStreak: Int
    
    static let empty = ConsistencyStats(
        last7Days: 0.0,
        last30Days: 0.0,
        last90Days: 0.0,
        currentStreak: 0,
        longestStreak: 0
    )
}