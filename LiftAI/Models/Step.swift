//
//  Step.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation

enum Step: String, Hashable, CaseIterable {
    case goal, context, permissions, capture, detect, plan
    var next: Step? {
        switch self {
        case .goal: return .context
        case .context: return .permissions
        case .permissions: return .capture
        case .capture: return .detect
        case .detect: return .plan
        case .plan: return nil
        }
    }
}
