//
//  OpenAIService.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation
import UIKit

struct DetectionResponse: Decodable {
    let equipments: [String]
}

protocol OpenAIService {
    func detectEquipment(from images: [UIImage]) async throws -> [Equipment]
}

final class OpenAIServiceMock: OpenAIService {
    private let result: [Equipment]
    init(result: [Equipment] = [.squatRack, .barbell, .benchFlat, .cableMachine, .latPulldown, .dumbbells]) {
        self.result = result
    }
    func detectEquipment(from images: [UIImage]) async throws -> [Equipment] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return result
    }
}

/// Parsing helper used by tests and any real implementation later.
enum DetectionParser {
    static func parse(_ data: Data) throws -> [Equipment] {
        let resp = try JSONDecoder().decode(DetectionResponse.self, from: data)
        let uniq = Array(Set(resp.equipments))
        return uniq.compactMap { Equipment(rawValue: $0) }
    }
}
