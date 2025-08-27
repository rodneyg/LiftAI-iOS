//
//  CaptureViewModel.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI
import PhotosUI
import Combine
import CryptoKit

struct CapturedPhoto: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    let hash: String
}

@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var photos: [CapturedPhoto] = []
    private var seen: Set<String> = []

    let minCount = 3
    let maxCount = 12
    var canContinue: Bool { photos.count >= minCount && photos.count <= maxCount }

    func add(_ image: UIImage) {
        guard photos.count < maxCount else { return }
        let key = Self.hash(image)
        guard !seen.contains(key) else { return }
        seen.insert(key)
        photos.append(CapturedPhoto(image: image, hash: key))
    }

    func remove(_ id: UUID) {
        if let idx = photos.firstIndex(where: { $0.id == id }) {
            let h = photos[idx].hash
            photos.remove(at: idx)
            seen.remove(h)
        }
    }

    private static func hash(_ img: UIImage) -> String {
        // compress to stabilize bytes
        let data = img.jpegData(compressionQuality: 0.6) ?? Data()
        let digest = Insecure.SHA1.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
