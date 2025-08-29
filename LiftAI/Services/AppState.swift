//
//  AppState.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation
import UIKit
import Combine

final class AppState: ObservableObject {
    // Cross-step state
    @Published var goal: Goal?
    @Published var context: TrainingContext?
    @Published var capturedImages: [UIImage] = []
    @Published var gymProfile: GymProfile?
    @Published var offlineOnly: Bool = false

    // Cached workouts for instant render from Dashboard
    @Published var cachedWorkouts: [Workout]? = nil

    // Saved session accessor
    var savedSession: SavedSession? {
        SavedSessionStore.shared.load()
    }

    // Persist the current session to storage
    func saveCurrentSession(workouts: [Workout]) {
        guard let goal = goal, let context = context else { return }
        let equipments = gymProfile?.equipments ?? []
        let session = SavedSession(
            savedAt: Date(),
            goal: goal,
            context: context,
            equipments: equipments,
            workouts: workouts
        )
        SavedSessionStore.shared.save(session)
        cachedWorkouts = workouts
    }

    // Clear persisted session and in-memory state
    func clearSavedSession() {
        SavedSessionStore.shared.clear()
        goal = nil
        context = nil
        gymProfile = nil
        capturedImages = []
        cachedWorkouts = nil
    }

    // Back-compat for SettingsSheet
    func resetAll() {
        clearSavedSession()
        offlineOnly = false
    }

    // Update saved equipments in the current saved session, if any, and reflect in-memory state.
    func updateSavedEquipments(_ equipments: [Equipment]) {
        if let existing = SavedSessionStore.shared.load() {
            let updated = SavedSession(
                savedAt: Date(),
                goal: existing.goal,
                context: existing.context,
                equipments: equipments,
                workouts: existing.workouts
            )
            SavedSessionStore.shared.save(updated)
            cachedWorkouts = existing.workouts
        }
        gymProfile = GymProfile(equipments: equipments)
    }
}
