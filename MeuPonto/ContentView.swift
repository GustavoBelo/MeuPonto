//
//  ContentView.swift
//  MeuPonto
//
//  Created by Gustavo Belo on 06/09/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Properties
    @ObservedObject var viewModel = WorkSessionViewModel()
    let dateFormat = Date.FormatStyle()
        .hour()
        .minute()
        .second()
    
    // MARK: - Body
    var body: some View {
        VStack {
            pointButton
            List {
                lastRecordsSection
                predictionsSection
            }
        }
    }
    
    @ViewBuilder
    var pointButton: some View {
        switch viewModel.futureState {
        case .startJourney:
            styledButton(text: "Registrar entrada expediente", action: viewModel.startJourney)
        case .startLunch:
            styledButton(text: "Registrar saída refeição", action: viewModel.startLunchSession)
        case .endLunch:
            styledButton(text: "Registrar entrada refeição", action: viewModel.endLunchSession)
        case .endJourney:
            styledButton(text: "Registrar saída expediente", action: viewModel.endWorkSession)
        }
    }
    
    @ViewBuilder
    var lastRecordsSection: some View {
        Section("Últimos registros") {
            if let startTime = viewModel.workSession.startTime?.formatted(dateFormat) {
                Text("Entrada expediente \(startTime)")
            }
            if let lunchStart = viewModel.workSession.lunchStart?.formatted(dateFormat) {
                Text("Saída refeição \(lunchStart)")
            }
            if let lunchEnd = viewModel.workSession.lunchEnd?.formatted(dateFormat) {
                Text("Entrada refeição \(lunchEnd)")
            }
        }
    }
    
    @ViewBuilder
    var predictionsSection: some View {
        Section("Previsões") {
            if let predictedEndTime = viewModel.predictedEndTime?.formatted(dateFormat) {
                Text("Encerrar expediente: \(predictedEndTime)")
            }
            if let predictedLunchEndTime = viewModel.predictedLunchEndTime?.formatted(dateFormat) {
                Text("Encerrar almoço: \(predictedLunchEndTime)")
            }
        }
        if viewModel.lunchTimeRemaining != "0h 0m" {
            Label("Tempo para acabar o almoço: \(viewModel.lunchTimeRemaining)", systemImage: "hourglass")
        }
        if viewModel.lunchDuration != "0h 0m" {
            Label("Duração do almoço: \(viewModel.lunchDuration)", systemImage: "fork.knife.circle.fill")
        }
        Label("Tempo para ir embora: \(viewModel.endTimeRemaining)", systemImage: "hourglass")
        Label("Duração do expediente anterior: \(viewModel.workDuration)", systemImage: "laptopcomputer")
    }
    
    func styledButton(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(text, systemImage: "clock.fill")
                .padding(5)
                .frame(maxWidth: .infinity)
        }
        .padding(10)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: MockWorkSessionViewModel())
            .environmentObject(MockWorkSessionViewModel())
    }
    
    class MockWorkSessionViewModel: WorkSessionViewModel {
        override init() {
            super.init()
            self.workSession.startTime = Date()
            self.workSession.lunchStart = Date().addingTimeInterval(3600)
            self.workSession.lunchEnd = Date().addingTimeInterval(7200)
            self.workSession.endTime = Date().addingTimeInterval(14400)
        }
    }
}
