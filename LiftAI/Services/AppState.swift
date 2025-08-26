//
//  AppState.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation
import Combine
import UIKit

final class AppState: ObservableObject {
    @Published var goal: Goal? = nil
    @Published var context: TrainingContext? = nil
    @Published var gymProfile: GymProfile? = nil
    @Published var capturedImages: [UIImage] = []
}
