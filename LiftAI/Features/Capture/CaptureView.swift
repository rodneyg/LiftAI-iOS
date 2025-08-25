//
//  CaptureView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct CaptureView: View {
    @EnvironmentObject var flow: FlowController
    @StateObject private var vm = CaptureViewModel()

    @State private var showCamera = false
    @State private var showLibrary = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add gym photos").font(.title2).bold()
            Text("Add 3–12 photos. Different angles and areas recommended.")
                .font(.footnote).foregroundStyle(.secondary)

            HStack {
                Button {
                    showCamera = true
                } label: {
                    Label("Take photo", systemImage: "camera")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showLibrary = true
                } label: {
                    Label("Choose from library", systemImage: "photo.on.rectangle.angled")
                }
                .buttonStyle(.bordered)
                .disabled(vm.photos.count >= vm.maxCount)
            }

            Text("Selected: \(vm.photos.count)/\(vm.maxCount)")
                .font(.footnote)
                .foregroundStyle(vm.canContinue ? AnyShapeStyle(.secondary) : AnyShapeStyle(.red))

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(vm.photos) { p in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: p.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .clipped()
                                .cornerRadius(8)
                            Button {
                                vm.remove(p.id)
                            } label: {
                                Image(systemName: "xmark.circle.fill").padding(4)
                            }
                        }
                    }
                }
            }

            HStack {
                Button("Back") { flow.path.removeLast() }
                Spacer()
                Button("Continue") { flow.advance(from: .capture) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!vm.canContinue)
            }
        }
        .padding()
        .sheet(isPresented: $showCamera) {
            CameraPicker(isPresented: $showCamera) { img in
                vm.add(img)
            }
        }
        .sheet(isPresented: $showLibrary) {
            let remaining = vm.maxCount - vm.photos.count
            LibraryPicker(selectionLimit: remaining) { imgs in
                imgs.forEach { vm.add($0) }
            }
        }
        .navigationTitle("Capture")
    }
}
