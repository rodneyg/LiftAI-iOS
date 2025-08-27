//
//  EquipmentNormalizer.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/26/25.
//


// Services/EquipmentNormalizer.swift
import Foundation

enum EquipmentNormalizer {
    // map lowercased/trimmed aliases → enum rawValue
    private static let aliases: [String: Equipment] = [
        "squatrack": .squatRack,
        "squat rack": .squatRack,
        "barbell": .barbell,
        "smithmachine": .smithMachine,
        "smith machine": .smithMachine,
        "cablemachine": .cableMachine,
        "cable machine": .cableMachine,
        "lat pulldown": .latPulldown,
        "latpulldown": .latPulldown,
        "legpress": .legPress,
        "leg press": .legPress,
        "dumbbell": .dumbbells,
        "dumbbells": .dumbbells,
        "kettlebell": .kettlebells,
        "kettlebells": .kettlebells,
        "flat bench": .benchFlat,
        "benchflat": .benchFlat,
        "incline bench": .benchIncline,
        "benchincline": .benchIncline,
        "pullupbar": .pullupBar,
        "pull-up bar": .pullupBar,
        "treadmill": .treadmill,
        "rower": .rower,
        "bike": .bike,
        "stairclimber": .stairClimber,
        "stair climber": .stairClimber,
        "trapbar": .trapBar,
        "trap bar": .trapBar,
        "assisted dip": .assistedDipChin,
        "assisted dip/chin": .assistedDipChin,
        "pecdeck": .pecDeck,
        "pec deck": .pecDeck,
        "hacksquat": .hackSquat,
        "hack squat": .hackSquat,
        "preachercurl": .preacherCurl,
        "preacher curl": .preacherCurl,
        "hipabductor": .hipAbductor,
        "hip abductor": .hipAbductor,
        "hipadductor": .hipAdductor,
        "hip adductor": .hipAdductor,
        "calfraise": .calfRaise,
        "calf raise": .calfRaise,
        "landmine": .landmine,
        "sled": .sled,
        "pulley": .pulleySingle,
        "single pulley": .pulleySingle
    ]

    static func normalize(_ raw: String) -> Equipment? {
        let key = raw.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let eq = Equipment(rawValue: key) { return eq } // exact rawValue match
        if let mapped = aliases[key] { return mapped }
        // fallback: strip spaces
        let nospace = key.replacingOccurrences(of: " ", with: "")
        return aliases[nospace]
    }
}
