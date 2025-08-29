//
//  EquipmentEditorView.swift
//  LiftAI
//
//  Simple manual editor to select/deselect available equipment.
//

import SwiftUI

struct EquipmentEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let initial: [Equipment]
    let onSave: (Set<Equipment>) -> Void

    @State private var selection: Set<Equipment>
    @State private var query: String = ""

    init(initial: [Equipment], onSave: @escaping (Set<Equipment>) -> Void) {
        self.initial = initial
        self.onSave = onSave
        _selection = State(initialValue: Set(initial))
    }

    private var filtered: [Equipment] {
        let all = Equipment.allCases.sorted { $0.friendlyName.localizedCompare($1.friendlyName) == .orderedAscending }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return all }
        return all.filter { $0.friendlyName.localizedCaseInsensitiveContains(query) || $0.rawValue.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered, id: \.self) { eq in
                    Button {
                        if selection.contains(eq) { selection.remove(eq) } else { selection.insert(eq) }
                    } label: {
                        HStack {
                            Text(eq.friendlyName)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: selection.contains(eq) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selection.contains(eq) ? .liftAccent : .secondary)
                        }
                    }
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Edit Equipment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(selection)
                        dismiss()
                    }
                    .disabled(selection.isEmpty)
                }
            }
        }
    }
}

