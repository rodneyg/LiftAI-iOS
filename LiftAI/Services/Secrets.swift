//
//  Secrets.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation
import Security

enum Secrets {
    private static let keychainKey = "openai_api_key"

    // Preferred: Keychain. Fallback: bundled Secrets.plist (development only).
    static var openAIKey: String {
        if let kc = Keychain.get(keychainKey), !kc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return kc
        }
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return "" }
        // Support either key casing
        let key = (dict["OPENAI_API_KEY"] as? String) ?? (dict["OpenAI_API_Key"] as? String) ?? ""
        return key
    }

    @discardableResult
    static func storeOpenAIKey(_ value: String) -> Bool {
        Keychain.set(Self.keychainKey, value: value)
    }

    @discardableResult
    static func clearOpenAIKey() -> Bool {
        Keychain.delete(Self.keychainKey)
    }
}
