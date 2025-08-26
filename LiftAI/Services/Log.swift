//
//  Log.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import os

enum Log {
    static let net = Logger(subsystem: "com.rodneygainous.LiftAI", category: "network")
    static let detect = Logger(subsystem: "com.rodneygainous.LiftAI", category: "detect")
}
