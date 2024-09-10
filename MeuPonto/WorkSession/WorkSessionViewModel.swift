//
//  WorkSessionViewModel.swift
//  MeuPonto
//
//  Created by Gustavo Belo on 06/09/24.
//

import Foundation
import Combine
import UserNotifications

class WorkSessionViewModel: ObservableObject {
    // MARK: - Properties
    @Published var workSession = WorkSession()
    @Published var endTimeRemaining: String = "9h 15m"
    @Published var lunchTimeRemaining: String = "0h 0m"
    @Published var lunchDuration: String = "0h 0m"
    @Published var workDuration: String = "0h 0m"
    
    private var timer: Timer?
    
    // MARK: - State Management
    var futureState: WorkState = .startJourney
    
    // MARK: - Methods
    init() {
        startTimer()
    }
    
    func startJourney() {
        workSession.startTime = Date()
        workSession.endTime = workSession.startTime?.addingTimeInterval(workSession.workDuration + workSession.lunchDuration)
        futureState = .startLunch
        updateTimeRemaining()
    }
    
    func startLunchSession() {
        workSession.lunchStart = Date()
        futureState = .endLunch
        scheduleEndNotifications()
    }
    
    func endLunchSession() {
        workSession.lunchEnd = Date()
        futureState = .endJourney
        updateLunchDuration()
        updateTimeRemaining()
        scheduleEndNotifications()
    }
    
    func endWorkSession() {
        workSession.endTime = Date()
        stopTimer()
        updateWorkDuration()
        resetState()
        startTimer()
    }
    
    var predictedEndTime: Date? {
        return workSession.calculateEndTime()
    }
    
    var predictedLunchEndTime: Date? {
        return workSession.calculateLunchEndTime()
    }
    
    private func updateLunchDuration() {
        guard let lunchStart = workSession.lunchStart, let lunchEnd = workSession.lunchEnd else { return }
        
        let lunchTime = floor(lunchEnd.timeIntervalSince(lunchStart) / 60) * 60 // Arredonda para baixo
        lunchDuration = formatTime(lunchTime)
        
        if lunchTime > workSession.lunchDuration {
            let extraLunchTime = lunchTime - workSession.lunchDuration
            workSession.endTime = workSession.endTime?.addingTimeInterval(extraLunchTime) ?? workSession.startTime?.addingTimeInterval(workSession.workDuration + lunchTime)
        }
    }
        
    private func updateWorkDuration() {
        if let startTime = workSession.startTime, let endTime = workSession.endTime {
            let totalWorkTime = endTime.timeIntervalSince(startTime)
            workDuration = formatTime(totalWorkTime)
        }
    }
    
    private func resetState() {
        workSession = WorkSession()
        futureState = .startJourney
        endTimeRemaining = "9h 15m"
        lunchDuration = "0h 0m"
    }
    
    private func scheduleEndNotifications() {
        guard let endTime = getEndTimeForNotification() else { return }
        
        let notificationTimes = [
            endTime.addingTimeInterval(-(10 * 60)),
            endTime.addingTimeInterval(-(5 * 60)),
            endTime.addingTimeInterval(-(2 * 60))
        ]
        
        for notificationTime in notificationTimes {
            configureLocalNotification(notificationTime: notificationTime, endTime: endTime)
        }
    }
    
    private func getEndTimeForNotification() -> Date? {
        switch futureState {
        case .endLunch:
            return workSession.calculateLunchEndTime()
        case .endJourney:
            return workSession.calculateEndTime()
        default:
            return nil
        }
    }
    
    private func configureLocalNotification(notificationTime: Date, endTime: Date) {
        let content = UNMutableNotificationContent()
        let timeRemaining = Int(endTime.timeIntervalSince(notificationTime))
        
        switch futureState {
        case .endLunch:
            content.title = "Hora de voltar ao trabalho!"
            content.body = "Faltam \(timeRemaining / 60) minutos para terminar o almoço."
        case .endJourney:
            content.title = "Hora de sair!"
            content.body = "Faltam \(timeRemaining / 60) minutos para bater o ponto."
        default:
            return
        }
        
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationTime.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func updateTimeRemaining() {
        let remainingTime = floor(workSession.remainingTime() ?? 0 / 60) * 60
        endTimeRemaining = formatTime(remainingTime)
        let lunchRemainingTime = floor(workSession.calculateLunchEndTime()?.timeIntervalSinceNow ?? 0 / 60) * 60
        lunchTimeRemaining = formatTime(lunchRemainingTime)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}