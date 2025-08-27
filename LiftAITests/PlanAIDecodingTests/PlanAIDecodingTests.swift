//
//  PlanAIDecodingTests.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/26/25.
//


import XCTest
@testable import LiftAI

final class PlanAIDecodingTests: XCTestCase {
    func test_parse_setsReps_andNormalizeEquipment() throws {
        let json = """
        { "workouts": [{
          "title":"Push",
          "estMinutes":45,
          "exercises":[
            { "name":"Incline DB Press", "primary":"chest", "equipment":"Incline bench", "tempo":null, "sets":4, "reps":8 },
            { "name":"Cable Fly", "primary":"chest", "equipment":"Cable Machine", "tempo":null, "sets":3, "reps":12 }
          ]
        }]}
        """
        let w = try PlanParser.parse(Data(json.utf8))
        XCTAssertEqual(w.first?.blocks.first?.first?.sets, 4)
        XCTAssertEqual(w.first?.blocks.first?.first?.reps, 8)
        // normalized:
        XCTAssertEqual(w.first?.blocks[0][0].equipment, .benchIncline)
        XCTAssertEqual(w.first?.blocks[1][0].equipment, .cableMachine)
    }

    func test_parse_rejectsExtraShape() {
        let bad = Data("{\"wrong\":[]}".utf8)
        XCTAssertThrowsError(try PlanParser.parse(bad))
    }
}
