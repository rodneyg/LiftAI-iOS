//
//  PermissionsView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject var flow: FlowController
    @StateObject private var vm = PermissionsViewModel()
    @Namespace private var anim

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Hero
                    VStack(spacing: 8) {
                        Text("Permissions")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Allow access so LiftAI can detect your gym equipment. Location is optional.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // Cards
                    VStack(spacing: 16) {
                        permissionCard(
                            title: "Photo Library",
                            subtitle: "Choose 3–12 photos of your gym.",
                            icon: "photo.on.rectangle.angled",
                            status: vm.photosStatus,
                            prominent: true,
                            action: vm.requestPhotos
                        )

                        permissionCard(
                            title: "Camera",
                            subtitle: "Take 3–12 photos inside your gym.",
                            icon: "camera.fill",
                            status: vm.cameraStatus,
                            prominent: true,
                            action: vm.requestCamera
                        )

                        permissionCard(
                            title: "Location",
                            subtitle: "Helps confirm you’re at a gym (optional).",
                            icon: "location.fill",
                            status: vm.locationStatus,
                            prominent: false,
                            action: vm.requestLocation
                        )
                    }

                    // Manual confirm
                    VStack(spacing: 8) {
                        Toggle(isOn: $vm.manualConfirmInGym) {
                            Text("Skip location, confirm manually")
                                .font(.headline)
                        }
                        .tint(.liftAccent)

                        Text("Check this if you’re at your gym and don’t want to share location.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)

                    // Continue
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        flow.advance(from: .permissions)
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
        }
        .navigationBarHidden(true)
        .onAppear { vm.refreshStatuses() }
    }

    // MARK: - Components

    private func permissionCard(
        title: String,
        subtitle: String,
        icon: String,
        status: PermissionsViewModel.Status,
        prominent: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.systemBackground).opacity(0.9))
                    .frame(width: 42, height: 42)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Button(action: {
                if status != .granted {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    action()
                }
            }) {
                Text(buttonTitle(for: status))
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(buttonBackground(for: status, prominent: prominent))
                    .foregroundColor(buttonForeground(for: status, prominent: prominent))
                    .clipShape(Capsule())
            }
            .disabled(status == .granted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.9))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
    }

    private func buttonTitle(for status: PermissionsViewModel.Status) -> String {
        switch status {
        case .granted: return "Granted"
        case .denied, .unknown: return "Allow"
        }
    }

    private func buttonBackground(for status: PermissionsViewModel.Status, prominent: Bool) -> Color {
        if status == .granted { return Color.gray.opacity(0.2) }
        return prominent ? .liftAccent : Color.liftAccent.opacity(0.25)
    }

    private func buttonForeground(for status: PermissionsViewModel.Status, prominent: Bool) -> Color {
        if status == .granted { return .secondary }
        return prominent ? .white : .liftAccent
    }
}
