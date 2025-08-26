//
//  PlanEngineTests.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import XCTest
@testable import LiftAI

final class PlanEngineTests: XCTestCase {

    func test_strength_richGym_has3Workouts_andMainLiftPresent() {
        let gp: [Equipment] = [.squatRack, .benchFlat, .barbell, .dumbbells, .cableMachine, .latPulldown]
        let plan = PlanEngine.generate(goal: .strength, context: .gym, equipments: gp)
        XCTAssertEqual(plan.workouts.count, 3)
        let titles = plan.workouts.map(\.title).joined(separator: "|")
        XCTAssertTrue(titles.contains("Squat focus"))
        XCTAssertTrue(titles.contains("Press focus"))
        XCTAssertTrue(titles.contains("Hinge focus"))
        // main movement appears at least once
        let names = plan.workouts.flatMap { $0.blocks }.flatMap { $0 }.map(\.name)
        XCTAssertTrue(names.contains(where: { $0.contains("Squat") }))
        XCTAssertTrue(names.contains(where: { $0.contains("Bench") }))
        XCTAssertTrue(names.contains(where: { $0.contains("Deadlift") || $0.contains("RDL") }))
    }

    func test_strength_noBarbell_substitutesWithDBVariants() {
        let gp: [Equipment] = [.dumbbells, .benchFlat]
        let plan = PlanEngine.generate(goal: .strength, context: .gym, equipments: gp)
        let names = plan.workouts.flatMap { $0.blocks }.flatMap { $0 }.map(\.name)
        XCTAssertTrue(names.contains(where: { $0.contains("DB Bench") }))
        // no hard crash if squat rack missing
        XCTAssertTrue(plan.workouts.count == 3)
    }

    func test_home_context_usesHomeFriendlyAccessories() {
        let plan = PlanEngine.generate(goal: .hypertrophy, context: .home, equipments: [.dumbbells])
        let names = plan.workouts.flatMap { $0.blocks }.flatMap { $0 }.map(\.name)
        // no cable-only moves required
        XCTAssertFalse(names.contains("Cable Fly"))
    }
}
