//
//  PlanView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct PlanView: View {
    @EnvironmentObject var flow: FlowController
    var body: some View {
        VStack(spacing: 16) {
            Text("Plan").font(.title2).bold()
            Text("Placeholder").foregroundStyle(.secondary)
            Button("Restart") { flow.reset() }
        }
        .padding()
        .navigationTitle("Plan")
    }
}
