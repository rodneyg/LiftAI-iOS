//
//  DetectView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct DetectView: View {
    @EnvironmentObject var flow: FlowController
    var body: some View {
        VStack(spacing: 16) {
            Text("Detect").font(.title2).bold()
            Text("Placeholder").foregroundStyle(.secondary)
            Button("Next: Plan") { flow.advance(from: .detect) }
        }
        .padding()
        .navigationTitle("Detect")
    }
}
