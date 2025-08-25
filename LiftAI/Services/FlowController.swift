//
//  FlowController.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import SwiftUI
import Combine

final class FlowController: ObservableObject {
    @Published var path: [Step] = []
    func goTo(_ step: Step) { path.append(step) }
    func advance(from step: Step) { if let next = step.next { path.append(next) } }
    func reset() { path.removeAll() }
}
