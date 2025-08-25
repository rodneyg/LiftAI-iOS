//
//  Persistence.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation

enum Persistence {
    private static var directory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func save<T: Codable>(_ value: T, as filename: String) throws {
        let url = directory.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(value)
        try data.write(to: url, options: .atomic)
    }

    static func load<T: Codable>(_ type: T.Type, from filename: String) throws -> T {
        let url = directory.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    static func exists(_ filename: String) -> Bool {
        let url = directory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path)
    }
}
