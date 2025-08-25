//
//  Equipment.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

enum Equipment: String, Codable, CaseIterable, Hashable {
    case barbell, squatRack, smithMachine, cableMachine, latPulldown, legPress
    case dumbbells, kettlebells, benchFlat, benchIncline, pullupBar
    case treadmill, rower, bike, stairClimber, trapBar, assistedDipChin
    case pecDeck, hackSquat, preacherCurl, hipAbductor, hipAdductor
    case calfRaise, landmine, sled, pulleySingle
}
