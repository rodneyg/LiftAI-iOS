//
//  PlanCard.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct PlanCard: View {
    let workout: Workout
    let goal: Goal?

    @State private var expandAllTempo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header: Stronger section header with a chip-style info bar
            VStack(alignment: .leading, spacing: 10) {
                Text(workout.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    InfoChip(icon: "clock.fill", text: "\(workout.estMinutes) min", color: .secondary)
                    if let goal {
                        InfoChip(icon: goalIcon(goal), text: goalLabel(goal), color: .accentColor)
                    }
                    Spacer()
                    // Card-level progressive disclosure for tempos
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { expandAllTempo.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Text(expandAllTempo ? "Hide tempos" : "Show tempos")
                            Image(systemName: expandAllTempo ? "chevron.up" : "chevron.down")
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                .font(.subheadline)

                Divider().background(Color.secondary.opacity(0.3)).padding(.top, 4)
            }
            
            // Blocks
            VStack(spacing: 20) {
                ForEach(workout.blocks.indices, id: \.self) { i in
                    let block = workout.blocks[i]
                    VStack(alignment: .leading, spacing: 14) {
                        if block.count > 1 {
                            Tag(text: "Superset \(blockLabel(i))")
                        }
                        
                        ForEach(block.indices, id: \.self) { j in
                            MovementRow(m: block[j], showAllTempo: expandAllTempo)
                                .accessibilityElement(children: .combine)
                        }
                    }
                    
                    if i != workout.blocks.indices.last {
                        Divider().background(Color.secondary.opacity(0.3))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray5).opacity(0.5))
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private func blockLabel(_ index: Int) -> String {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return index < letters.count ? String(letters[index]) : "#\(index+1)"
    }

    private func goalLabel(_ g: Goal) -> String {
        switch g {
        case .strength: return "Strength"
        case .hypertrophy: return "Muscle"
        case .fatLoss: return "Fat loss"
        case .endurance: return "Endurance"
        case .mobility: return "Mobility"
        }
    }
    private func goalIcon(_ g: Goal) -> String {
        switch g {
        case .strength: return "bolt.fill"
        case .hypertrophy: return "figure.strengthtraining.traditional"
        case .fatLoss: return "flame.fill"
        case .endurance: return "figure.run"
        case .mobility: return "figure.cooldown"
        }
    }
}

// MARK: - Rows

private struct MovementRow: View {
    let m: Movement
    let showAllTempo: Bool

    @State private var showTempo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 1) Exercise name - primary anchor
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: iconName(for: m))
                    .foregroundColor(.accentColor)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 20)
                Text(m.name)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.bottom, 2)
            
            // 2) Muscle group & equipment
            if !m.primary.isEmpty || m.equipment != nil {
                HStack(spacing: 8) {
                    if !m.primary.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.caption2)
                            Text(primaryDisplay(m.primary))
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    if let eq = m.equipment {
                        HStack(spacing: 4) {
                            Image(systemName: "dumbbell.fill")
                                .font(.caption2)
                            Text(friendly(eq))
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            // 3) Sets & reps
            if let s = m.sets, let r = m.reps {
                Text("\(s) sets × \(r) reps")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            } else if let s = m.sets {
                Text("\(s) sets")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            } else if let r = m.reps {
                Text("\(r) reps")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            // 4) Progressive disclosure - tempo hidden by default
            if let t = m.tempo, !t.isEmpty {
                DisclosureButton(isExpanded: $showTempo, title: "View tempo") {
                    Text(tempoExplain(t))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                        .padding(.top, 4)
                }
            }
        }
        .onChange(of: showAllTempo) { newValue in
            withAnimation(.easeInOut(duration: 0.2)) { showTempo = newValue }
        }
    }
    
    private func primaryDisplay(_ s: String) -> String {
        guard let first = s.first else { return s }
        return String(first).uppercased() + s.dropFirst()
    }

    private func iconName(for m: Movement) -> String {
        let n = m.name.lowercased()
        if n.contains("squat") { return "figure.strengthtraining.traditional" }
        if n.contains("bench") || n.contains("press") { return "arrow.up.circle.fill" }
        if n.contains("row") { return "figure.rower" }
        if n.contains("curl") { return "dumbbell" }
        if n.contains("pulldown") || n.contains("pull-down") { return "arrow.down.circle.fill" }
        if n.contains("deadlift") { return "shippingbox.fill" }
        if n.contains("lunge") { return "figure.walk" }
        if n.contains("run") || n.contains("treadmill") { return "figure.run" }
        if n.contains("bike") || n.contains("cycle") { return "bicycle" }
        if n.contains("pull-up") || n.contains("pullup") { return "figure.pullup" }
        return "square.grid.2x2"
    }

    private func friendly(_ e: Equipment) -> String {
        switch e {
        case .benchFlat: return "Flat bench"
        case .benchIncline: return "Incline bench"
        case .latPulldown: return "Lat pulldown"
        case .pullupBar: return "Pull-up bar"
        case .squatRack: return "Squat rack"
        case .cableMachine: return "Cable machine"
        case .legPress: return "Leg press"
        case .smithMachine: return "Smith machine"
        case .barbell: return "Barbell"
        case .dumbbells: return "Dumbbells"
        case .treadmill: return "Treadmill"
        case .bike: return "Exercise bike"
        case .rower: return "Rowing machine"
        default: return e.rawValue
        }
    }

    private func tempoExplain(_ t: String) -> String {
        let parts = t.split(separator: "-").map { String($0) }
        if parts.count == 3, let a = Int(parts[0]), let b = Int(parts[1]), let c = Int(parts[2]) {
            return "Down \(a)s • Hold \(b)s • Up \(c)s"
        }
        return t
    }
}

// MARK: - Small UI elements

private struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            Text(text)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

private struct Tag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
            .foregroundColor(.primary)
    }
}

private struct DisclosureButton<Content: View>: View {
    @Binding var isExpanded: Bool
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.caption2.weight(.semibold))
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.semibold))
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)

            if isExpanded {
                content()
            }
        }
    }
}
