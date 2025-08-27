//
//  PlanCard.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//


import SwiftUI

struct PlanCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.title).font(.headline)
                Spacer()
                Text("\(workout.estMinutes) min").font(.subheadline).foregroundStyle(.secondary)
            }
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(workout.blocks.enumerated()), id: \.offset) { idx, block in
                    if block.count == 1 {
                        MovementRow(m: block[0])
                    } else {
                        Text("Superset \(idx + 1)").font(.caption).foregroundStyle(.secondary)
                        ForEach(block, id: \.name) { MovementRow(m: $0) }
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
    }
}

private struct MovementRow: View {
    let m: Movement
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName(for: m))
            VStack(alignment: .leading, spacing: 2) {
                Text(m.name)
                HStack(spacing: 6) {
                    if let eq = m.equipment { Chip(text: friendly(eq)) }
                    Chip(text: m.primary)
                    if let s = m.sets, let r = m.reps { Chip(text: "\(s)×\(r)") }
                    if let t = m.tempo { Chip(text: t) }
                }.font(.caption)
            }
            Spacer()
        }
    }
}

private func iconName(for m: Movement) -> String {
    if let eq = m.equipment {
        switch eq {
        case .dumbbells: return "dumbbell"
        case .treadmill: return "figure.run"
        case .bike: return "bicycle"
        case .rower: return "figure.rower"
        case .squatRack, .barbell, .smithMachine: return "figure.strengthtraining.traditional"
        case .cableMachine, .latPulldown, .pulleySingle: return "cable.connector"
        case .benchFlat, .benchIncline: return "rectangle.portrait"
        default: return "figure.strengthtraining.functional"
        }
    }
    // no equipment
    return "figure.cooldown"
}

private func friendly(_ e: Equipment) -> String {
    switch e {
    case .benchFlat: return "Flat bench"
    case .benchIncline: return "Incline bench"
    case .latPulldown: return "Lat pulldown"
    case .pullupBar: return "Pull-up bar"
    default: return e.rawValue
    }
}


private struct Chip: View {
    let text: String
    var body: some View {
        Text(text)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Capsule().fill(Color.secondary.opacity(0.15)))
    }
}
