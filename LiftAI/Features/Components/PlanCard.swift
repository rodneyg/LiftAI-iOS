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
        HStack(spacing: 8) {
            Image(systemName: "figure.strengthtraining.traditional")
            VStack(alignment: .leading, spacing: 2) {
                Text(m.name)
                HStack(spacing: 6) {
                    if let eq = m.equipment { Chip(text: eq.rawValue) }
                    Chip(text: m.primary)
                    if let t = m.tempo { Chip(text: t) }
                }.font(.caption)
            }
            Spacer()
        }
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
