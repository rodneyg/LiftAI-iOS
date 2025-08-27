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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("We detect your gym equipment from photos you provide. Location helps confirm you’re at a gym. You can proceed without location by confirming manually.")
                    .foregroundStyle(.secondary)

                HStack {
                    Image(systemName: icon(for: vm.photosStatus))
                    VStack(alignment: .leading) {
                        Text("Photo Library").bold()
                        Text("Needed to select 3–12 gym photos for equipment detection.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: vm.requestPhotos) { Text(buttonTitle(for: vm.photosStatus)) }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.photosStatus == .granted)
                }

                HStack {
                    Image(systemName: icon(for: vm.cameraStatus))
                    VStack(alignment: .leading) {
                        Text("Camera").bold()
                        Text("Take 3–12 gym photos for equipment detection.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: vm.requestCamera) { Text(buttonTitle(for: vm.cameraStatus)) }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.cameraStatus == .granted)
                }

                HStack {
                    Image(systemName: icon(for: vm.locationStatus))
                    VStack(alignment: .leading) {
                        Text("Location (optional)").bold()
                        Text("Used to confirm you’re at a gym. You can skip by confirming manually.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: vm.requestLocation) { Text(buttonTitle(for: vm.locationStatus)) }
                        .buttonStyle(.bordered)
                        .disabled(vm.locationStatus == .granted)
                }

                Toggle("I confirm I’m currently at a gym", isOn: $vm.manualConfirmInGym)
                Text("Check this if you’re physically at your gym now.")
                    .font(.footnote).foregroundStyle(.secondary)

                HStack {
                    Spacer()
                    Button("Continue") { flow.advance(from: .permissions) }
                        .buttonStyle(.borderedProminent)
                        .disabled(!vm.canContinue)
                }
            }
            .padding()
        }
        .onAppear { vm.refreshStatuses() }
        .navigationTitle("Permissions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func icon(for status: PermissionsViewModel.Status) -> String {
        switch status { case .granted: return "checkmark.seal.fill"; case .denied: return "xmark.octagon.fill"; case .unknown: return "questionmark.circle" }
    }
    private func buttonTitle(for status: PermissionsViewModel.Status) -> String {
        switch status { case .granted: return "Granted"; case .denied, .unknown: return "Allow" }
    }
}
