//
//  PermissionsView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject var flow: FlowController
    var body: some View {
        VStack(spacing: 16) {
            Text("Permissions").font(.title2).bold()
            Text("Placeholder").foregroundStyle(.secondary)
            Button("Next: Capture") { flow.advance(from: .permissions) }
        }
        .padding()
        .navigationTitle("Permissions")
    }
}
