//
//  DetectionParsingTests.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Testing
import XCTest
@testable import LiftAI

final class DetectionParsingTests: XCTestCase {

    func test_parsesKnownEquipments_andIgnoresUnknown_andDedupes() throws {
        let json = """
        { "equipments": ["squatRack","barbell","barbell","unknownThing","latPulldown"] }
        """
        let data = Data(json.utf8)
        let parsed = try DetectionParser.parse(data)
        XCTAssertTrue(parsed.contains(.squatRack))
        XCTAssertTrue(parsed.contains(.barbell))
        XCTAssertTrue(parsed.contains(.latPulldown))
        XCTAssertFalse(parsed.contains(where: { "\($0)" == "unknownThing" }))
        // deduped
        XCTAssertEqual(parsed.filter { $0 == .barbell }.count, 1)
    }

    func test_emptyWhenMalformedJson() {
        let bad = Data("{}".utf8)
        XCTAssertThrowsError(try DetectionParser.parse(bad))
    }
}
