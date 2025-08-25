//
//  CaptureViewModel.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI
import PhotosUI
import Combine

struct CapturedPhoto: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
}

@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var photos: [CapturedPhoto] = []

    let minCount = 3
    let maxCount = 12

    var canContinue: Bool { photos.count >= minCount && photos.count <= maxCount }

    func add(_ image: UIImage) {
        guard photos.count < maxCount else { return }
        photos.append(CapturedPhoto(image: image))
    }

    func remove(_ id: UUID) {
        photos.removeAll { $0.id == id }
    }
}
