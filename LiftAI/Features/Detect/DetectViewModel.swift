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
    @Published var useSampleGym = false  // default off

    var service: OpenAIService = OpenAIServiceHTTP()
    var forceOffline: Bool = false

    func runDetection(with images: [UIImage] = []) async {
        // clear stale UI first
        error = nil
        equipments = []
        isLoading = true
        defer { isLoading = false }

        if useSampleGym || forceOffline {
            try? await Task.sleep(nanoseconds: 300_000_000)
            equipments = sampleEquipments
            Log.detect.info("Sample/Offline gym used. equipments=\(self.equipments.count)")
            return
        }

        Log.net.info("DetectViewModel starting. images=\(images.count)")
        do {
            let eq = try await service.detectEquipment(from: images)
            equipments = eq
            Log.net.info("DetectViewModel parsed equipments=\(eq.count) -> \(eq.map{$0.rawValue}.joined(separator: ","), privacy: .public)")
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
