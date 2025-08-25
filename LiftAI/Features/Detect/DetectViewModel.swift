//
//  DetectViewModel.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//


import Foundation
import UIKit
import Combine

@MainActor
final class DetectViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var equipments: [Equipment] = []
    @Published var useSampleGym = true

    var service: OpenAIService = OpenAIServiceMock()

    func runDetection(with images: [UIImage] = []) async {
        error = nil
        isLoading = true
        defer { isLoading = false }

        if useSampleGym {
            try? await Task.sleep(nanoseconds: 300_000_000)
            equipments = sampleEquipments
            return
        }

        do {
            let eq = try await service.detectEquipment(from: images)
            equipments = eq
        } catch {
            self.error = error.localizedDescription
        }
    }
}

private let sampleEquipments: [Equipment] = [
    .squatRack, .barbell, .benchFlat, .cableMachine, .latPulldown,
    .dumbbells, .treadmill, .legPress, .pullupBar
]
