//
//  SettingsSheet.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject var appState: AppState
    @State private var apiKeyInput: String = ""
    @State private var hasKey: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Mode") {
                    Toggle("Offline only (use sample detection)", isOn: $appState.offlineOnly)
                }
                Section("OpenAI") {
                    SecureField("API key", text: $apiKeyInput)
                        .textContentType(.password)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                    HStack {
                        Button("Save") {
                            let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            Secrets.storeOpenAIKey(trimmed)
                            hasKey = !trimmed.isEmpty
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.liftAccent)
                        if hasKey {
                            Button(role: .destructive) {
                                Secrets.clearOpenAIKey()
                                apiKeyInput = ""
                                hasKey = false
                            } label: { Text("Clear") }
                            .buttonStyle(.bordered)
                        }
                        Spacer()
                        Text(hasKey ? "Present" : "Missing")
                            .foregroundStyle(hasKey ? .green : .red)
                            .font(.footnote)
                    }
                    Text("Model: gpt-4o").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Privacy") {
                    Text("Photos are sent to OpenAI only for equipment detection when offline is disabled. No analytics. You can use offline mode to avoid any network calls.")
                        .font(.footnote)
                }
                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://liftai.app/privacy")!)
                    Link("Terms of Use", destination: URL(string: "https://liftai.app/terms")!)
                }
                Section("Disclaimer") {
                    Text("LiftAI provides general fitness information and is not medical advice. Consult a healthcare professional before beginning any exercise program. Use at your own risk.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section {
                    Button(role: .destructive) {
                        appState.resetAll()
                    } label: { Text("Reset all data") }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                apiKeyInput = Keychain.get("openai_api_key") ?? ""
                hasKey = !apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }
    }
}
