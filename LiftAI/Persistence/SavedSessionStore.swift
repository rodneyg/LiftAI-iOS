//
//  SavedSessionStore.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import Foundation

/// Simple JSON-backed store using UserDefaults.
/// Chosen over @AppStorage here so it can be used from non-View types safely.
final class SavedSessionStore {
    static let shared = SavedSessionStore()
    private init() {}

    private let key = "savedSessionJSON"

    func exists() -> Bool {
        guard let str = UserDefaults.standard.string(forKey: key) else { return false }
        return !str.isEmpty
    }

    func load() -> SavedSession? {
        guard let str = UserDefaults.standard.string(forKey: key),
              let data = str.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(SavedSession.self, from: data)
    }

    func save(_ s: SavedSession) {
        guard let data = try? JSONEncoder().encode(s),
              let str = String(data: data, encoding: .utf8) else { return }
        UserDefaults.standard.set(str, forKey: key)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
