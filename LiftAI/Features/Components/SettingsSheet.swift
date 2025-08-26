//
//  SettingsSheet.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section("Mode") {
                    Toggle("Offline only (use sample detection)", isOn: $appState.offlineOnly)
                }
                Section("OpenAI") {
                    HStack {
                        Text("API key")
                        Spacer()
                        Text(Secrets.openAIKey.isEmpty ? "Missing" : "Present")
                            .foregroundStyle(Secrets.openAIKey.isEmpty ? .red : .green)
                            .font(.footnote)
                    }
                    Text("Model: gpt-4o").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Privacy") {
                    Text("Photos are sent to OpenAI only for equipment detection when offline is disabled. No analytics. You can use offline mode to avoid any network calls.")
                        .font(.footnote)
                }
                Section {
                    Button(role: .destructive) {
                        appState.resetAll()
                    } label: { Text("Reset all data") }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
