//
//  CaptureView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct CaptureView: View {
    @EnvironmentObject var flow: FlowController
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = CaptureViewModel()

    @State private var showCamera = false
    @State private var showLibrary = false
    @Namespace private var anim

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Hero
                VStack(spacing: 8) {
                    Text("Add gym photos")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Provide 3–12 photos from different angles for best results.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Action buttons
                HStack(spacing: 16) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Take photo", systemImage: "camera")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.liftAccent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }

                    Button {
                        showLibrary = true
                    } label: {
                        Label("Choose", systemImage: "photo.on.rectangle.angled")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(vm.photos.count >= vm.maxCount ? Color.gray.opacity(0.4) : Color(.systemBackground).opacity(0.9))
                            .foregroundColor(vm.photos.count >= vm.maxCount ? .secondary : .primary)
                            .cornerRadius(14)
                    }
                    .disabled(vm.photos.count >= vm.maxCount)
                }
                .padding(.horizontal, 16)

                // Status
                statusChip

                // Grid of selected photos
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                        ForEach(vm.photos) { p in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: p.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(10)

                                Button {
                                    vm.remove(p.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 3)
                                        .padding(6)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Continue button
                Button {
                    appState.capturedImages = vm.photos.map(\.image)
                    flow.advance(from: .capture)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.canContinue ? Color.liftAccent : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                        .shadow(color: vm.canContinue ? .liftAccent.opacity(0.35) : .clear,
                                radius: 10, x: 0, y: 5)
                        .animation(.easeInOut, value: vm.canContinue)
                }
                .disabled(!vm.canContinue)
                .padding(.bottom, 24)
            }
            .padding(.top, 40)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCamera) {
            CameraPicker(isPresented: $showCamera) { img in vm.add(img) }
        }
        .sheet(isPresented: $showLibrary) {
            let remaining = vm.maxCount - vm.photos.count
            LibraryPicker(selectionLimit: remaining) { imgs in imgs.forEach { vm.add($0) } }
        }
    }

    // MARK: - Components

    private var statusChip: some View {
        let color: Color = vm.canContinue ? .green : .orange
        let text: String = "\(vm.photos.count)/\(vm.maxCount) selected"

        return Text(text)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
            .animation(.easeInOut, value: vm.photos.count)
    }
}
