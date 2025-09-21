//
//  MicroActionView.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import SwiftUI

struct MicroActionView: View {
    let floor: ConsistencyFloor
    let action: MicroAction
    let onComplete: (Int?, Int?) -> Void // duration, reps
    let onExpandToWorkout: (() -> Void)? // Optional callback to expand to full workout
    
    @Environment(\.dismiss) private var dismiss
    @State private var isRunning = false
    @State private var timeElapsed = 0
    @State private var repCount = 0
    @State private var isComplete = false
    @State private var timer: Timer?
    
    // Default initializer without expand callback
    init(floor: ConsistencyFloor, action: MicroAction, onComplete: @escaping (Int?, Int?) -> Void) {
        self.floor = floor
        self.action = action
        self.onComplete = onComplete
        self.onExpandToWorkout = nil
    }
    
    // Full initializer with expand callback
    init(floor: ConsistencyFloor, action: MicroAction, onComplete: @escaping (Int?, Int?) -> Void, onExpandToWorkout: (() -> Void)?) {
        self.floor = floor
        self.action = action
        self.onComplete = onComplete
        self.onExpandToWorkout = onExpandToWorkout
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.black, Color(.systemGray6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Today's Floor")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        Text(action.name)
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text(action.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Progress display
                VStack(spacing: 24) {
                    if floor.type == .time {
                        timeProgressView
                    } else {
                        repsProgressView
                    }
                }
                
                Spacer()
                
                // Controls
                VStack(spacing: 16) {
                    if !isComplete {
                        if floor.type == .time {
                            timeControlButtons
                        } else {
                            repsControlButtons
                        }
                    } else {
                        completionView
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .padding(.top, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.liftAccent)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Time-based Views
    
    private var timeProgressView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray6), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: timeProgress)
                    .stroke(Color.liftAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: timeProgress)
                
                VStack(spacing: 8) {
                    Text(formatTime(timeElapsed))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("of \(floor.value) min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(isRunning ? "Keep going!" : "Ready to start?")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
    
    private var timeControlButtons: some View {
        HStack(spacing: 20) {
            Button {
                if isRunning {
                    pauseTimer()
                } else {
                    startTimer()
                }
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.liftAccent)
                    .clipShape(Circle())
            }
            
            if timeElapsed > 0 {
                Button {
                    resetTimer()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .foregroundColor(.liftAccent)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            
            if timeElapsed >= floor.value * 60 {
                Button {
                    completeAction()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    // MARK: - Reps-based Views
    
    private var repsProgressView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("\(repCount)")
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("of \(floor.value) reps")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 8)
                        .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(Color.liftAccent)
                        .frame(width: geometry.size.width * repsProgress, height: 8)
                        .clipShape(Capsule())
                        .animation(.easeInOut(duration: 0.3), value: repsProgress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 24)
            
            Text(repCount >= floor.value ? "Great job!" : "Tap + for each rep")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
    
    private var repsControlButtons: some View {
        HStack(spacing: 20) {
            Button {
                if repCount > 0 {
                    repCount -= 1
                }
            } label: {
                Image(systemName: "minus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(repCount > 0 ? Color.red : Color(.systemGray5))
                    .clipShape(Circle())
            }
            .disabled(repCount == 0)
            
            Button {
                repCount += 1
                if repCount >= floor.value {
                    // Auto-complete when target reached
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if repCount >= floor.value {
                            completeAction()
                        }
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.liftAccent)
                    .clipShape(Circle())
            }
            
            if repCount > 0 {
                Button {
                    repCount = 0
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .foregroundColor(.liftAccent)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            
            if repCount >= floor.value {
                Button {
                    completeAction()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("Floor complete!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Well done! Your consistency streak continues.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.liftAccent)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                if let onExpandToWorkout = onExpandToWorkout {
                    Button {
                        onExpandToWorkout()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Expand to full workout")
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var timeProgress: CGFloat {
        let targetSeconds = floor.value * 60
        return targetSeconds > 0 ? CGFloat(timeElapsed) / CGFloat(targetSeconds) : 0
    }
    
    private var repsProgress: CGFloat {
        floor.value > 0 ? CGFloat(repCount) / CGFloat(floor.value) : 0
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1
            if timeElapsed >= floor.value * 60 {
                pauseTimer()
                // Auto-complete when time is up
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completeAction()
                }
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        pauseTimer()
        timeElapsed = 0
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func completeAction() {
        isComplete = true
        pauseTimer()
        
        let duration = floor.type == .time ? timeElapsed / 60 : nil
        let reps = floor.type == .reps ? repCount : nil
        
        onComplete(duration, reps)
    }
}