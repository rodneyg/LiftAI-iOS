//
//  LiftAISplashView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/26/25.
//


import SwiftUI

struct LiftAISplashView: View {
    @EnvironmentObject var flow: FlowController
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(.systemGray6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.liftAccent.opacity(0.22))
                        .frame(width: animate ? 240 : 80, height: animate ? 240 : 80)
                        .scaleEffect(animate ? 1 : 0.6)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)

                    Text("LiftAI")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.liftAccent)
                        .shadow(color: .liftAccent.opacity(0.6), radius: 12, x: 0, y: 0)
                }

                Text("A plan for every gym.")
                    .font(.headline)
                    .foregroundColor(.liftGold)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeInOut(duration: 1.2).delay(0.3), value: animate)
            }
        }
        .toolbar(.hidden, for: .navigationBar) // hide nav on splash
        .onAppear {
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                flow.goTo(.goal)
            }
        }
    }
}
