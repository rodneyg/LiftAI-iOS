//
//  OpenAIPlanService.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/26/25.
//


import Foundation

struct AIPlansResponse: Decodable {
    let workouts: [AIWorkout]
}
struct AIWorkout: Decodable {
    let title: String
    let estMinutes: Int
    let exercises: [AIExercise]
}
struct AIExercise: Decodable {
    let name: String
    let primary: String
    let equipment: String?
    let tempo: String?
    let sets: Int?
    let reps: Int?
}

protocol PlanService {
    func generateWorkouts(goal: Goal, context: TrainingContext, equipments: [Equipment]) async throws -> [Workout]
}

enum PlanParser {
    static func parse(_ data: Data) throws -> [Workout] {
        let decoded = try JSONDecoder().decode(AIPlansResponse.self, from: data)
        return decoded.workouts.map { w in
            let moves: [Movement] = w.exercises.map {
                Movement(
                    name: $0.name,
                    equipment: $0.equipment.flatMap(EquipmentNormalizer.normalize),
                    primary: $0.primary,
                    tempo: $0.tempo,
                    sets: $0.sets,
                    reps: $0.reps
                )
            }
            return Workout(title: w.title, blocks: moves.map { [$0] }, estMinutes: w.estMinutes)
        }
    }
}

final class PlanServiceMock: PlanService {
    func generateWorkouts(goal: Goal, context: TrainingContext, equipments: [Equipment]) async throws -> [Workout] {
        let m = Movement(name: "DB Bench Press", equipment: .dumbbells, primary: "chest", tempo: nil)
        return [Workout(title: "Upper A", blocks: [[m]], estMinutes: 30)]
    }
}
