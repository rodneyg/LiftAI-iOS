//
//  ContextView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct ContextView: View {
    @EnvironmentObject var flow: FlowController
    var body: some View {
        VStack(spacing: 16) {
            Text("Context").font(.title2).bold()
            Text("Placeholder").foregroundStyle(.secondary)
            Button("Next: Permissions") { flow.advance(from: .context) }
        }
        .padding()
        .navigationTitle("Context")
    }
}
