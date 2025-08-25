//
//  DetectView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

import SwiftUI

struct DetectView: View {
    @EnvironmentObject var flow: FlowController
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = DetectViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detect equipment").font(.title2).bold()
            Text("Analyze your gym photos to identify available machines and free weights.")
                .font(.footnote).foregroundStyle(.secondary)

            Toggle("Use sample gym (no network)", isOn: $vm.useSampleGym)

            HStack {
                Button {
                    Task { await vm.runDetection() }
                } label: {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.horizontal, 8)
                    } else {
                        Label("Detect equipment", systemImage: "wand.and.stars")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)
                if let err = vm.error {
                    Text(err).font(.footnote).foregroundStyle(.red)
                }
            }

            if !vm.equipments.isEmpty {
                Text("Detected: \(vm.equipments.count)")
                    .font(.subheadline).bold()
                WrapChips(items: vm.equipments.map(\.rawValue))
            } else {
                Text("No equipment detected yet.")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            Spacer()

            HStack {
                Button("Back") { flow.path.removeLast() }
                Spacer()
                Button("Continue") {
                    appState.gymProfile = GymProfile(equipments: vm.equipments)
                    flow.advance(from: .detect)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.equipments.isEmpty)
            }
        }
        .padding()
        .navigationTitle("Detect")
    }
}

/// Simple flow layout
private struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return GeometryReader { geo in
            ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
                ForEach(Array(data), id: \.self) { item in
                    content(item)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geo.size.width {
                                width = 0
                                height -= d.height + spacing
                            }
                            let result = width
                            width -= d.width + spacing
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            return result
                        }
                }
            }
        }
        .frame(height: intrinsicHeight(in: UIScreen.main.bounds.width))
    }

    private func intrinsicHeight(in totalWidth: CGFloat) -> CGFloat {
        // Simple fixed height fallback to avoid complexity; chips list is short.
        120
    }
}
