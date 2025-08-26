//
//  PlanEngine.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation

struct PlanEngine {
    struct TemplateDay {
        let title: String
        let main: [Movement]      // pick first available
        let accessories: [Movement] // fill to target count
        let targetCount: Int
    }

    static func generate(goal: Goal, context: TrainingContext, equipments: [Equipment]) -> Plan {
        let set = Set(equipments)
        let days = template(for: goal, context: context)

        let workouts: [Workout] = days.map { day in
            var chosen: [Movement] = []
            if let main = day.main.first(where: { $0.equipment == nil || set.contains($0.equipment!) }) {
                chosen.append(main)
            } else if let fallback = day.main.first {
                chosen.append(fallback) // always have one main
            }
            for m in day.accessories where chosen.count < day.targetCount {
                if m.equipment == nil || set.contains(m.equipment!) {
                    chosen.append(m)
                }
            }
            // if still short, backfill from accessories regardless of equipment to keep count
            var i = 0
            while chosen.count < day.targetCount && i < day.accessories.count {
                if !chosen.contains(where: { $0.name == day.accessories[i].name }) {
                    chosen.append(day.accessories[i])
                }
                i += 1
            }
            return Workout(title: day.title, blocks: chosen.map { [$0] }, estMinutes: estimateMinutes(for: chosen))
        }

        return Plan(goal: goal, workouts: workouts)
    }

    private static func estimateMinutes(for moves: [Movement]) -> Int {
        let base = 8 // per movement minutes
        return max(30, min(75, moves.count * base))
    }

    private static func template(for goal: Goal, context: TrainingContext) -> [TemplateDay] {
        let homeOnly = context == .home
        switch goal {
        case .strength:
            return [
                TemplateDay(
                    title: "Day 1 — Squat focus",
                    main: [ Movement(name: "Back Squat", equipment: .squatRack, primary: "quads", tempo: nil),
                            Movement(name: "Goblet Squat", equipment: .dumbbells, primary: "quads", tempo: nil) ],
                    accessories: strengthAccessories(homeOnly: homeOnly),
                    targetCount: 5
                ),
                TemplateDay(
                    title: "Day 2 — Press focus",
                    main: [ Movement(name: "Bench Press", equipment: .benchFlat, primary: "chest", tempo: nil),
                            Movement(name: "DB Bench Press", equipment: .dumbbells, primary: "chest", tempo: nil) ],
                    accessories: strengthAccessories(homeOnly: homeOnly),
                    targetCount: 5
                ),
                TemplateDay(
                    title: "Day 3 — Hinge focus",
                    main: [ Movement(name: "Deadlift", equipment: .barbell, primary: "posterior", tempo: nil),
                            Movement(name: "DB RDL", equipment: .dumbbells, primary: "posterior", tempo: nil) ],
                    accessories: strengthAccessories(homeOnly: homeOnly),
                    targetCount: 5
                )
            ]
        case .hypertrophy:
            return [
                TemplateDay(
                    title: "Push",
                    main: [ Movement(name: "Incline DB Press", equipment: .benchIncline, primary: "chest", tempo: nil) ],
                    accessories: hyperAccessories(homeOnly: homeOnly),
                    targetCount: 6
                ),
                TemplateDay(
                    title: "Pull",
                    main: [ Movement(name: "Lat Pulldown", equipment: .latPulldown, primary: "back", tempo: nil),
                            Movement(name: "1-Arm DB Row", equipment: .dumbbells, primary: "back", tempo: nil) ],
                    accessories: hyperAccessories(homeOnly: homeOnly),
                    targetCount: 6
                ),
                TemplateDay(
                    title: "Legs",
                    main: [ Movement(name: "Leg Press", equipment: .legPress, primary: "quads", tempo: nil),
                            Movement(name: "DB Split Squat", equipment: .dumbbells, primary: "quads", tempo: nil) ],
                    accessories: hyperAccessories(homeOnly: homeOnly),
                    targetCount: 6
                ),
                TemplateDay(
                    title: "Shoulders & Arms",
                    main: [ Movement(name: "DB Overhead Press", equipment: .dumbbells, primary: "shoulders", tempo: nil) ],
                    accessories: hyperAccessories(homeOnly: homeOnly),
                    targetCount: 6
                )
            ]
        case .fatLoss:
            return [
                TemplateDay(
                    title: "Intervals + Full Body",
                    main: [ Movement(name: "Treadmill Intervals", equipment: .treadmill, primary: "cardio", tempo: nil),
                            Movement(name: "KB Swings", equipment: .kettlebells, primary: "posterior", tempo: nil) ],
                    accessories: fatlossAccessories(homeOnly: homeOnly),
                    targetCount: 5
                ),
                TemplateDay(
                    title: "Row + Core",
                    main: [ Movement(name: "Row Intervals", equipment: .rower, primary: "cardio", tempo: nil) ],
                    accessories: fatlossAccessories(homeOnly: homeOnly),
                    targetCount: 5
                ),
                TemplateDay(
                    title: "Bike + Upper",
                    main: [ Movement(name: "Bike Intervals", equipment: .bike, primary: "cardio", tempo: nil) ],
                    accessories: fatlossAccessories(homeOnly: homeOnly),
                    targetCount: 5
                )
            ]
        case .endurance:
            return [
                TemplateDay(
                    title: "Zone 2 Treadmill",
                    main: [ Movement(name: "Zone 2 Walk/Jog", equipment: .treadmill, primary: "cardio", tempo: nil) ],
                    accessories: enduranceAccessories(homeOnly: homeOnly),
                    targetCount: 4
                ),
                TemplateDay(
                    title: "Row 5k Prep",
                    main: [ Movement(name: "Steady Row", equipment: .rower, primary: "cardio", tempo: nil) ],
                    accessories: enduranceAccessories(homeOnly: homeOnly),
                    targetCount: 4
                ),
                TemplateDay(
                    title: "Bike Tempo",
                    main: [ Movement(name: "Bike Tempo", equipment: .bike, primary: "cardio", tempo: nil) ],
                    accessories: enduranceAccessories(homeOnly: homeOnly),
                    targetCount: 4
                )
            ]
        case .mobility:
            return [
                TemplateDay(
                    title: "Hips & Ankles",
                    main: [ Movement(name: "Cossack Squat", equipment: nil, primary: "mobility", tempo: nil) ],
                    accessories: mobilityAccessories(),
                    targetCount: 5
                ),
                TemplateDay(
                    title: "T-Spine & Shoulders",
                    main: [ Movement(name: "Wall Slides", equipment: nil, primary: "mobility", tempo: nil) ],
                    accessories: mobilityAccessories(),
                    targetCount: 5
                ),
                TemplateDay(
                    title: "Hinge Mobility",
                    main: [ Movement(name: "Jefferson Curl (light)", equipment: .dumbbells, primary: "mobility", tempo: "3-1-3") ],
                    accessories: mobilityAccessories(),
                    targetCount: 5
                )
            ]
        }
    }

    private static func strengthAccessories(homeOnly: Bool) -> [Movement] {
        var arr: [Movement] = [
            Movement(name: "Seated Cable Row", equipment: .cableMachine, primary: "back", tempo: nil),
            Movement(name: "Lat Pulldown", equipment: .latPulldown, primary: "back", tempo: nil),
            Movement(name: "DB RDL", equipment: .dumbbells, primary: "posterior", tempo: nil),
            Movement(name: "DB Lunge", equipment: .dumbbells, primary: "quads", tempo: nil),
            Movement(name: "Plank", equipment: nil, primary: "core", tempo: nil)
        ]
        if homeOnly { arr.removeAll { $0.equipment == .cableMachine || $0.equipment == .latPulldown } }
        return arr
    }

    private static func hyperAccessories(homeOnly: Bool) -> [Movement] {
        var arr: [Movement] = [
            Movement(name: "Cable Fly", equipment: .cableMachine, primary: "chest", tempo: nil),
            Movement(name: "Lateral Raise", equipment: .dumbbells, primary: "shoulders", tempo: nil),
            Movement(name: "Leg Extension", equipment: .legPress, primary: "quads", tempo: nil), // approx
            Movement(name: "Seated Row", equipment: .cableMachine, primary: "back", tempo: nil),
            Movement(name: "Hammer Curl", equipment: .dumbbells, primary: "arms", tempo: nil),
            Movement(name: "Triceps Pressdown", equipment: .cableMachine, primary: "arms", tempo: nil)
        ]
        if homeOnly { arr.removeAll { $0.equipment == .cableMachine || $0.equipment == .legPress } }
        return arr
    }

    private static func fatlossAccessories(homeOnly: Bool) -> [Movement] {
        var arr: [Movement] = [
            Movement(name: "DB Thruster", equipment: .dumbbells, primary: "full", tempo: nil),
            Movement(name: "Step-ups", equipment: .benchFlat, primary: "quads", tempo: nil),
            Movement(name: "Mountain Climbers", equipment: nil, primary: "core", tempo: nil),
            Movement(name: "Burpees", equipment: nil, primary: "full", tempo: nil)
        ]
        if homeOnly { /* unchanged, all available */ }
        return arr
    }

    private static func enduranceAccessories(homeOnly: Bool) -> [Movement] {
        var arr: [Movement] = [
            Movement(name: "Core Bracing", equipment: nil, primary: "core", tempo: nil),
            Movement(name: "DB Romanian Deadlift", equipment: .dumbbells, primary: "posterior", tempo: nil),
            Movement(name: "Hip Flexor Stretch", equipment: nil, primary: "mobility", tempo: nil)
        ]
        return arr
    }

    private static func mobilityAccessories() -> [Movement] {
        [
            Movement(name: "90/90 Hips", equipment: nil, primary: "mobility", tempo: nil),
            Movement(name: "Bretzel Stretch", equipment: nil, primary: "mobility", tempo: nil),
            Movement(name: "Calf Raises (slow)", equipment: .calfRaise, primary: "mobility", tempo: "3-1-3"),
            Movement(name: "Thoracic Extension on Bench", equipment: .benchFlat, primary: "mobility", tempo: nil)
        ]
    }
}
