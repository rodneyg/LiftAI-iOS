//
//  GoalView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct GoalView: View {
    @EnvironmentObject var flow: FlowController
    var body: some View {
        VStack(spacing: 16) {
            Text("Goal").font(.title2).bold()
            Text("Placeholder").foregroundStyle(.secondary)
            Button("Next: Context") { flow.goTo(.context) }
        }
        .padding()
        .navigationTitle("Goal")
    }
}
