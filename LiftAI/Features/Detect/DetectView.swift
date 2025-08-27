//
//  DetectView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct DetectView: View {
    @EnvironmentObject var flow: FlowController
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = DetectViewModel()
    @State private var shouldAutoRun = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if appState.offlineOnly {
                Text("Offline mode: using sample detection").font(.footnote).foregroundStyle(.secondary)
            }

            Toggle("Use sample gym (no network)", isOn: $vm.useSampleGym)
                .disabled(appState.offlineOnly)

            if vm.isLoading {
                HStack(spacing: 8) { ProgressView("Analyzing photos…"); Spacer() }
            } else if let err = vm.error {
                Text(err).font(.footnote).foregroundStyle(.red).textSelection(.enabled)
            }

            if !vm.equipments.isEmpty {
                Text("Detected: \(vm.equipments.count)").font(.subheadline).bold()
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                    ForEach(vm.equipments, id: \.self) { eq in
                        EquipmentTile(equipment: eq)
                    }
                }
            } else if !vm.isLoading && vm.error == nil {
                Text("No equipment detected yet.").font(.footnote).foregroundStyle(.secondary)
            }

            Spacer()

            HStack {
                Spacer()
                Button("Continue") {
                    appState.gymProfile = GymProfile(equipments: vm.equipments)
                    flow.advance(from: .detect)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading || vm.equipments.isEmpty)
            }
        }
        .padding()
        .navigationTitle("Detect equipment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.forceOffline = appState.offlineOnly
            if shouldAutoRun {
                shouldAutoRun = false
                Task {
                    if vm.useSampleGym || appState.offlineOnly { await vm.runDetection() }
                    else { await vm.runDetection(with: appState.capturedImages) }
                }
            }
        }
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
