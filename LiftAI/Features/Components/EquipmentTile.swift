//
//  EquipmentTile.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/26/25.
//


import SwiftUI

struct EquipmentTile: View {
    let equipment: Equipment

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon(for: equipment)).font(.title3)
            Text(friendly(equipment))
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.12)))
    }

    private func icon(for e: Equipment) -> String {
        switch e {
        case .dumbbells: return "dumbbell"
        case .treadmill: return "figure.run"
        case .bike: return "bicycle"
        case .rower: return "figure.rower"
        case .squatRack, .barbell, .smithMachine: return "figure.strengthtraining.traditional"
        case .cableMachine, .latPulldown, .pulleySingle: return "cable.connector"
        case .benchFlat, .benchIncline: return "rectangle.portrait"
        case .legPress: return "rectangle.compress.vertical"
        case .pullupBar: return "figure.pullup"
        default: return "figure.strengthtraining.functional"
        }
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
}
