//
//  DetectViewModel.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//


import Foundation
import UIKit
import Combine
import os

@MainActor
final class DetectViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var equipments: [Equipment] = []
    @Published var useSampleGym = true

    var service: OpenAIService = OpenAIServiceHTTP()  // switched default to real

    func runDetection(with images: [UIImage] = []) async {
        error = nil; isLoading = true
        defer { isLoading = false }

        if useSampleGym {
            try? await Task.sleep(nanoseconds: 300_000_000)
            equipments = sampleEquipments
            Log.detect.info("Sample gym used. equipments=\(self.equipments.count)")
            return
        }

        do {
            let eq = try await service.detectEquipment(from: images)
            equipments = eq
            Log.detect.info("Detection success. equipments=\(eq.count)")
        } catch {
            equipments = []
            let err = error
            self.error = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
            Log.detect.error("Detection failed: \(self.error ?? "unknown", privacy: .public)")
        }
    }
}

private let sampleEquipments: [Equipment] = [
    .squatRack, .barbell, .benchFlat, .cableMachine, .latPulldown,
    .dumbbells, .treadmill, .legPress, .pullupBar
]
