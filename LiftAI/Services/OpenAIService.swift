//
//  OpenAIService.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation
import UIKit
import os

struct DetectionResponse: Decodable { let equipments: [String] }

protocol OpenAIService {
    func detectEquipment(from images: [UIImage]) async throws -> [Equipment]
}

// Mock stays unchanged
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

final class OpenAIServiceHTTP: OpenAIService {
    struct APIError: Decodable { let error: Inner?; struct Inner: Decodable { let message: String? } }
    enum Err: LocalizedError {
        case noApiKey
        case badStatus(Int, String)
        case empty
        case decode

        var errorDescription: String? {
            switch self {
            case .noApiKey: return "Missing API key"
            case .badStatus(let code, let msg): return "HTTP \(code): \(msg)"
            case .empty: return "Empty model response"
            case .decode: return "Failed to decode model response"
            }
        }
    }
    
    private let apiKey: String
    private let model: String

    init(apiKey: String = Secrets.openAIKey, model: String = "gpt-4o") {
        self.apiKey = apiKey
        self.model = model
    }

    func detectEquipment(from images: [UIImage]) async throws -> [Equipment] {
        guard !apiKey.isEmpty else { throw Err.noApiKey }

        let dataUrls = images.prefix(6).map { "data:image/jpeg;base64,\(Self.jpegBase64($0, maxDim: 1024, quality: 0.7))" }
        Log.net.info("OpenAI detect start. images=\(dataUrls.count) model=\(self.model, privacy: .public)")

        let contents: [[String: Any]] =
            [["type": "text", "text": Self.promptAllowed]] +
            dataUrls.map { ["type": "image_url", "image_url": ["url": $0]] }

        let body: [String: Any] = [
            "model": model,  // default "gpt-4o"
            "messages": [["role": "user", "content": contents]],
            "response_format": ["type": "json_object"]
        ]

        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1

        guard code == 200 else {
            let server = (try? JSONDecoder().decode(APIError.self, from: data))?.error?.message
                ?? String(data: data, encoding: .utf8)
                ?? ""
            Log.net.error("OpenAI bad status \(code). server='\(server, privacy: .public)'")
            throw Err.badStatus(code, server.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        struct Root: Decodable {
            struct Choice: Decodable { struct Msg: Decodable { let content: String }; let message: Msg }
            let choices: [Choice]
        }

        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            guard let jsonString = root.choices.first?.message.content else { throw Err.empty }
            Log.net.debug("OpenAI content prefix: \(String(jsonString.prefix(120)), privacy: .public)")
            Log.net.info("OpenAI raw content: \(jsonString, privacy: .public)")
            let equipments = try DetectionParser.parse(Data(jsonString.utf8))
            return equipments
        } catch {
            Log.net.error("OpenAI decode failure: \(error.localizedDescription, privacy: .public)")
            throw Err.decode
        }
    }

    private static func jpegBase64(_ img: UIImage, maxDim: CGFloat, quality: CGFloat) -> String {
        let resized = resize(img, maxDim: maxDim)
        let data = resized.jpegData(compressionQuality: quality) ?? Data()
        return data.base64EncodedString()
    }

    private static func resize(_ image: UIImage, maxDim: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(1, maxDim / max(size.width, size.height))
        if scale >= 1 { return image }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let out = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return out
    }

    private static let promptAllowed = """
You identify gym equipment from photos. Output ONLY JSON:
{ "equipments": [ "<name>", ... ] }

Allowed names ONLY:
[barbell, squatRack, smithMachine, cableMachine, latPulldown, legPress,
 dumbbells, kettlebells, benchFlat, benchIncline, pullupBar,
 treadmill, rower, bike, stairClimber, trapBar, assistedDipChin,
 pecDeck, hackSquat, preacherCurl, hipAbductor, hipAdductor,
 calfRaise, landmine, sled, pulleySingle]

Rules:
- If uncertain, omit.
- No duplicates.
- No extra fields.
"""
}

/// Parsing helper used by tests and any real implementation later.
enum DetectionParser {
    static func parse(_ data: Data) throws -> [Equipment] {
        let resp = try JSONDecoder().decode(DetectionResponse.self, from: data)
        var out = [Equipment]()
        var seen = Set<Equipment>()
        for s in resp.equipments {
            if let eq = EquipmentNormalizer.normalize(s), !seen.contains(eq) {
                seen.insert(eq); out.append(eq)
            }
        }
        return out
    }
}

extension OpenAIServiceHTTP: PlanService {
    func generateWorkouts(goal: Goal, context: TrainingContext, equipments: [Equipment]) async throws -> [Workout] {
        guard !apiKey.isEmpty else { throw Err.noApiKey }

        let equipList = equipments.map { $0.rawValue }.joined(separator: ", ")
        let goalText: String = {
            switch goal {
            case .strength: return "Build strength"
            case .hypertrophy: return "Build muscle"
            case .fatLoss: return "Lose fat"
            case .endurance: return "Improve endurance"
            case .mobility: return "Improve mobility"
            }
        }()

        let allowed = Equipment.allCases.map { $0.rawValue }.joined(separator: ", ")
        let prompt = """
        You are a certified strength coach. Create EXACTLY 3 distinct workouts tailored to the user.

        Inputs:
        - Goal: \(goalText)
        - Location: \(context == .home ? "Home" : "Gym")
        - Available equipment (allowed values only): [\(equipList)]
        - Allowed equipment labels (MUST use these strings or null): [\(allowed)]

        Rules:
        - 4–6 exercises per workout.
        - Each exercise MUST include: name (string), primary (string), equipment (one of allowed labels or null), tempo (string or null), sets (int), reps (int).
        - Session length 30–60 minutes (estMinutes int).
        - Use only available equipment when specified. Prefer compound lifts when possible.
        - Respond ONLY with JSON in this exact shape:
        {
          "workouts": [
            {
              "title": "...",
              "estMinutes": 45,
              "exercises": [
                { "name": "...", "primary": "...", "equipment": "dumbbells" | null, "tempo": "3-1-3" | null, "sets": 4, "reps": 8 }
              ]
            }
          ]
        }
        - No extra fields. No prose. No markdown.
        """

        let body: [String: Any] = [
            "model": self.model, // default gpt-4o
            "messages": [
                ["role": "user", "content": [
                    ["type": "text", "text": prompt]
                ]]
            ],
            "response_format": ["type": "json_object"]
        ]

        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard code == 200 else {
            let server = (try? JSONDecoder().decode(APIError.self, from: data))?.error?.message
                ?? String(data: data, encoding: .utf8) ?? ""
            Log.net.error("OpenAI plan bad status \(code). server='\(server, privacy: .public)'")
            throw Err.badStatus(code, server.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        struct Root: Decodable {
            struct Choice: Decodable { struct Msg: Decodable { let content: String }; let message: Msg }
            let choices: [Choice]
        }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            guard let jsonString = root.choices.first?.message.content else { throw Err.empty }
            Log.net.info("OpenAI plan raw: \(jsonString, privacy: .public)")
            let workouts = try PlanParser.parse(Data(jsonString.utf8))
            Log.net.info("OpenAI plan parsed workouts=\(workouts.count)")
            return workouts
        } catch {
            Log.net.error("OpenAI plan decode failure: \(error.localizedDescription, privacy: .public)")
            throw Err.decode
        }
    }
}
