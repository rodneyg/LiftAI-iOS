//
//  LiftAISplashView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/26/25.
//


import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(.systemGray6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.liftAccent.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .blur(radius: 12)

                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.liftAccent)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                }

                Text("LiftAI")
                    .font(.title.bold())
                    .foregroundColor(.primary)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4)) {
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onFinish()
            }
        }
    }
}
