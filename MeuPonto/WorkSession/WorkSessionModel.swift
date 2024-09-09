//
//  WorkSessionModel.swift
//  MeuPonto
//
//  Created by Gustavo Belo on 06/09/24.
//

import Foundation

struct WorkSession {
    var startTime: Date?
    var endTime: Date?
    var lunchStart: Date?
    var lunchEnd: Date?
    
    let workDuration: TimeInterval = 8 * 60 * 60 // 8 hours
    let lunchDuration: TimeInterval = 75 * 60 // 1 hour 15 minutes
    
    func calculateEndTime() -> Date? {
        guard let start = startTime else { return nil }
        return start.addingTimeInterval(workDuration + lunchDuration)
    }
    
    func calculateLunchEndTime() -> Date? {
        guard let start = lunchStart else { return nil }
        return start.addingTimeInterval(lunchDuration)
    }
    
    func remainingTime() -> TimeInterval? {
        guard let end = calculateEndTime() else { return nil }
        return end.timeIntervalSinceNow
    }
}

enum WorkState {
    case startJourney
    case startLunch
    case endLunch
    case endJourney
}
