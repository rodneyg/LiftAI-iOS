//
//  CaptureView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct CaptureView: View {
    @EnvironmentObject var flow: FlowController
    var body: some View {
        VStack(spacing: 16) {
            Text("Capture").font(.title2).bold()
            Text("Placeholder").foregroundStyle(.secondary)
            Button("Next: Detect") { flow.advance(from: .capture) }
        }
        .padding()
        .navigationTitle("Capture")
    }
}
