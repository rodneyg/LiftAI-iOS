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

    // MARK: - Equipment detection

    func detectEquipment(from images: [UIImage]) async throws -> [Equipment] {
        guard !apiKey.isEmpty else { throw Err.noApiKey }

        let dataUrls = images.prefix(6).map { "data:image/jpeg;base64,\(Self.jpegBase64($0, maxDim: 1024, quality: 0.7))" }
        Log.net.info("OpenAI detect start. images=\(dataUrls.count) model=\(self.model, privacy: .public)")

        let systemText = """
        You see ONLY these photos. Identify gym equipment that is CLEARLY VISIBLE.
        Return STRICT JSON: { "equipments": ["<label>", ...] }
        Rules:
        - Labels ONLY from (case-sensitive): [\(Equipment.allCases.map{$0.rawValue}.joined(separator: ", "))]
        - Include an item ONLY if unambiguous and mostly in-frame.
        - No guesses. No duplicates. If uncertain, omit.
        - If nothing is visible, return { "equipments": [] }.
        """

        let userContents: [[String: Any]] =
            [["type": "text", "text": "Photos follow. Output JSON only."]]
            + dataUrls.map { ["type": "image_url", "image_url": ["url": $0]] }

        let body: [String: Any] = [
            "model": model,
            "temperature": 0.2,
            "messages": [
                ["role": "system", "content": [["type": "text", "text": systemText]]],
                ["role": "user",   "content": userContents]
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
            Log.net.info("Detection counts: parsed=\(equipments.count)")
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
}

// MARK: - Parse helper

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

// MARK: - Plan generation with post-filter

extension OpenAIServiceHTTP: PlanService {
    func generateWorkouts(goal: Goal, context: TrainingContext, equipments: [Equipment]) async throws -> [Workout] {
        guard !apiKey.isEmpty else { throw Err.noApiKey }

        let allowedSet = Set(equipments)
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

        let systemText = """
        HARD RULES:
        - Use only equipment the user has: [\(equipList)]. Equipment not in this list is forbidden.
        - If an exercise requires unavailable equipment, replace it with a bodyweight or available-equipment alternative.
        - Keep JSON strictly to schema. No prose. No extra fields.
        """

        let prompt = """
        You are a certified strength coach. Create EXACTLY 3 distinct workouts for the user.

        Inputs:
        - Goal: \(goalText)
        - Location: \(context == .home ? "Home" : "Gym")
        - Available equipment (only these may be used): [\(equipList)]
        - Allowed equipment labels (strings or null): [\(allowed)]

        Rules:
        - 4–6 exercises per workout.
        - Each exercise MUST include: name (string), primary (string), equipment (one of allowed labels or null), tempo (string or null), sets (int), reps (int).
        - Session length 30–60 minutes (estMinutes int).
        - Prefer compound lifts when possible. If equipment is limited, bias to bodyweight and tempo control for stimulus.
        - Respond ONLY with JSON:
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
        """

        let body: [String: Any] = [
            "model": self.model,
            "temperature": 0.2,
            "messages": [
                ["role": "system", "content": [["type": "text", "text": systemText]]],
                ["role": "user", "content": [["type": "text", "text": prompt]]]
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
            var workouts = try PlanParser.parse(Data(jsonString.utf8))

            // Post-filter: drop movements that use unavailable equipment.
            workouts = filterWorkoutsToAllowed(workouts, allowed: allowedSet)

            // If model violated constraints and everything got filtered, fall back to deterministic engine constrained to allowed.
            if workouts.allSatisfy({ $0.blocks.flatMap{$0}.isEmpty }) {
                Log.net.error("Plan post-filter removed all exercises; falling back to PlanEngine.")
                let fallback = PlanEngine.generate(goal: goal, context: context, equipments: Array(allowedSet))
                workouts = fallback.workouts
            }

            Log.net.info("OpenAI plan parsed workouts=\(workouts.count)")
            return workouts
        } catch {
            Log.net.error("OpenAI plan decode failure: \(error.localizedDescription, privacy: .public)")
            throw Err.decode
        }
    }

    // Filter helpers
    private func filterWorkoutsToAllowed(_ ws: [Workout], allowed: Set<Equipment>) -> [Workout] {
        ws.map { w in
            var newBlocks: [[Movement]] = []
            for block in w.blocks {
                let kept = block.filter { m in
                    guard let eq = m.equipment else { return true } // bodyweight allowed
                    return allowed.contains(eq)
                }
                if !kept.isEmpty { newBlocks.append(kept) }
            }
            return Workout(id: w.id, title: w.title, blocks: newBlocks, estMinutes: w.estMinutes)
        }
    }
}
