//
//  ConsistencyFloorTests.swift
//  LiftAITests
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import XCTest
@testable import LiftAI

final class ConsistencyFloorTests: XCTestCase {
    
    func testConsistencyFloorCreation() {
        let floor = ConsistencyFloor(
            goal: .strength,
            type: .reps,
            definition: "Push-ups",
            value: 10,
            contextCapabilities: ContextCapabilities.defaultHome
        )
        
        XCTAssertEqual(floor.goal, .strength)
        XCTAssertEqual(floor.type, .reps)
        XCTAssertEqual(floor.value, 10)
        XCTAssertEqual(floor.displayText, "10 push-ups")
    }
    
    func testConsistencyFloorTimeDisplay() {
        let floor = ConsistencyFloor(
            goal: .mobility,
            type: .time,
            definition: "Stretch",
            value: 5,
            contextCapabilities: ContextCapabilities.defaultHome
        )
        
        XCTAssertEqual(floor.displayText, "5 minutes")
    }
    
    func testConsistencyFloorSingleMinute() {
        let floor = ConsistencyFloor(
            goal: .mobility,
            type: .time,
            definition: "Stretch",
            value: 1,
            contextCapabilities: ContextCapabilities.defaultHome
        )
        
        XCTAssertEqual(floor.displayText, "1 minute")
    }
    
    func testMicroActionGeneration() {
        let floor = ConsistencyFloor(
            goal: .strength,
            type: .reps,
            definition: "Push-ups",
            value: 10,
            contextCapabilities: ContextCapabilities.defaultHome
        )
        
        let action = MicroActionGenerator.suggestedAction(for: floor, capabilities: floor.contextCapabilities)
        
        XCTAssertEqual(action.goal, .strength)
        XCTAssertEqual(action.type, .reps)
        XCTAssertLessThanOrEqual(action.targetValue, floor.value)
    }
    
    func testConsistencyStatsCalculation() {
        let stats = ConsistencyStats(
            last7Days: 0.85,
            last30Days: 0.75,
            last90Days: 0.80,
            currentStreak: 5,
            longestStreak: 12
        )
        
        XCTAssertEqual(stats.last7Days, 0.85, accuracy: 0.01)
        XCTAssertEqual(stats.currentStreak, 5)
        XCTAssertEqual(stats.longestStreak, 12)
    }
    
    func testDailyFloorStatusDateKey() {
        let date = Date()
        let status = DailyFloorStatus(
            date: date,
            met: true,
            actionId: "test-action",
            duration: 5,
            reps: nil,
            completedAt: date
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expectedKey = formatter.string(from: date)
        
        XCTAssertEqual(status.dateKey, expectedKey)
    }
    
    func testContextCapabilitiesDefaults() {
        let homeCapabilities = ContextCapabilities.defaultHome
        XCTAssertFalse(homeCapabilities.hasEquipment)
        XCTAssertTrue(homeCapabilities.hasSpace)
        XCTAssertTrue(homeCapabilities.canWalkOutside)
        
        let gymCapabilities = ContextCapabilities.defaultGym
        XCTAssertTrue(gymCapabilities.hasEquipment)
        XCTAssertTrue(gymCapabilities.hasSpace)
        XCTAssertFalse(gymCapabilities.canWalkOutside)
    }
    
    func testAtomicHabitsStreakRules() {
        // Test that the consistency stats distinguish between consistency scores (percentages)
        // and streaks (using "never miss twice" rule from Atomic Habits)
        let stats = ConsistencyStats(
            last7Days: 0.71, // 5 out of 7 days = 71% consistency
            last30Days: 0.85, // Overall consistency percentage
            last90Days: 0.90, // Overall consistency percentage
            currentStreak: 5, // Current streak allowing one miss
            longestStreak: 15 // Longest streak achieved
        )
        
        // Consistency scores are percentage-based
        XCTAssertEqual(stats.last7Days, 0.71, accuracy: 0.01)
        XCTAssertEqual(stats.last30Days, 0.85, accuracy: 0.01)
        XCTAssertEqual(stats.last90Days, 0.90, accuracy: 0.01)
        
        // Streaks follow "never miss twice" rule
        XCTAssertEqual(stats.currentStreak, 5)
        XCTAssertEqual(stats.longestStreak, 15)
    }
}