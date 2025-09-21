//
//  ConsistencyService.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/27/25.
//

import Foundation
import Combine

/// Service for managing consistency floor tracking and statistics
/// Implements Atomic Habits principles:
/// - Consistency scores track overall adherence percentage
/// - Streaks use "never miss twice" rule: missing one day doesn't break streak, but two consecutive misses do
final class ConsistencyService: ObservableObject {
    static let shared = ConsistencyService()
    
    @Published var todayStatus: DailyFloorStatus?
    @Published var stats: ConsistencyStats = .empty
    
    private let userDefaults = UserDefaults.standard
    private let statusKey = "consistencyStatusHistory"
    
    private init() {
        loadTodayStatus()
        calculateStats()
    }
    
    // MARK: - Daily Status Management
    
    /// Load today's status if it exists
    private func loadTodayStatus() {
        let today = Calendar.current.startOfDay(for: Date())
        todayStatus = getStatus(for: today)
    }
    
    /// Get status for a specific date
    func getStatus(for date: Date) -> DailyFloorStatus? {
        let history = loadStatusHistory()
        let dayKey = createDateKey(for: date)
        return history[dayKey]
    }
    
    /// Mark today's floor as completed
    func markFloorCompleted(actionId: String, duration: Int? = nil, reps: Int? = nil) {
        let today = Calendar.current.startOfDay(for: Date())
        let status = DailyFloorStatus(
            date: today,
            met: true,
            actionId: actionId,
            duration: duration,
            reps: reps,
            completedAt: Date()
        )
        
        saveStatus(status)
        todayStatus = status
        calculateStats()
    }
    
    /// Check if today's floor has been completed
    var isTodayCompleted: Bool {
        todayStatus?.met ?? false
    }
    
    // MARK: - Statistics Calculation
    
    private func calculateStats() {
        let history = loadStatusHistory()
        let today = Calendar.current.startOfDay(for: Date())
        let calendar = Calendar.current
        
        // Calculate percentages for different periods
        let last7Days = calculateCompletionRate(history: history, from: today, days: 7, calendar: calendar)
        let last30Days = calculateCompletionRate(history: history, from: today, days: 30, calendar: calendar)
        let last90Days = calculateCompletionRate(history: history, from: today, days: 90, calendar: calendar)
        
        // Calculate streaks
        let streaks = calculateStreaks(history: history, from: today, calendar: calendar)
        
        stats = ConsistencyStats(
            last7Days: last7Days,
            last30Days: last30Days,
            last90Days: last90Days,
            currentStreak: streaks.current,
            longestStreak: streaks.longest
        )
    }
    
    private func calculateCompletionRate(
        history: [String: DailyFloorStatus],
        from date: Date,
        days: Int,
        calendar: Calendar
    ) -> Double {
        var completedDays = 0
        var totalDays = 0
        
        for i in 0..<days {
            guard let checkDate = calendar.date(byAdding: .day, value: -i, to: date) else { continue }
            let key = createDateKey(for: checkDate)
            totalDays += 1
            
            if let status = history[key], status.met {
                completedDays += 1
            }
        }
        
        return totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0.0
    }
    
    private func calculateStreaks(
        history: [String: DailyFloorStatus],
        from date: Date,
        calendar: Calendar
    ) -> (current: Int, longest: Int) {
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var consecutiveMisses = 0
        
        // Calculate current streak using Atomic Habits "never miss twice" rule
        // Missing one day doesn't break the streak, but missing two consecutive days does
        var checkDate = date
        var allowedMiss = true // Can miss one day without breaking streak
        
        while true {
            let status = history[createDateKey(for: checkDate)]
            
            if let status = status, status.met {
                // Day completed - add to streak and reset miss allowance
                currentStreak += 1
                allowedMiss = true
            } else {
                // Day missed
                if allowedMiss {
                    // First miss - don't break streak but mark as used
                    allowedMiss = false
                } else {
                    // Second consecutive miss - break streak
                    break
                }
            }
            
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDate
        }
        
        // Calculate longest streak using the same "never miss twice" rule
        let sortedDates = history.keys.sorted { $0 < $1 }
        tempStreak = 0
        consecutiveMisses = 0
        
        for dateKey in sortedDates {
            if let status = history[dateKey], status.met {
                // Day completed
                tempStreak += 1
                consecutiveMisses = 0
                longestStreak = max(longestStreak, tempStreak)
            } else {
                // Day missed
                consecutiveMisses += 1
                if consecutiveMisses >= 2 {
                    // Two consecutive misses - reset streak
                    tempStreak = 0
                    consecutiveMisses = 0
                }
            }
        }
        
        return (currentStreak, longestStreak)
    }
    
    // MARK: - Persistence
    
    private func loadStatusHistory() -> [String: DailyFloorStatus] {
        guard let data = userDefaults.data(forKey: statusKey),
              let history = try? JSONDecoder().decode([String: DailyFloorStatus].self, from: data) else {
            return [:]
        }
        return history
    }
    
    private func saveStatus(_ status: DailyFloorStatus) {
        var history = loadStatusHistory()
        history[status.dateKey] = status
        
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: statusKey)
        }
    }
    
    private func createDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Cleanup
    
    /// Remove old status entries to keep storage lean (keep last 6 months)
    func cleanupOldStatuses() {
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        var history = loadStatusHistory()
        
        let cutoffKey = createDateKey(for: sixMonthsAgo)
        history = history.filter { $0.key >= cutoffKey }
        
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: statusKey)
        }
    }
    
    /// Clear all consistency data (for reset/debugging)
    func clearAllData() {
        userDefaults.removeObject(forKey: statusKey)
        todayStatus = nil
        stats = .empty
    }
}