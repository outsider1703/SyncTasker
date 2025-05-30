//
//  SleepInstructaionsView.swift
//  SyncTasker
//
//  Created by ingvar on 29.05.2025.
//

import SwiftUI

struct SleepInstructaionsView: View {
    
    // MARK: - Initial Private Properties
    
    @StateObject private var viewModel: SleepInstructionsViewModel
    
    // MARK: - Initialization
    
    init(
        viewModel: SleepInstructionsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            HStack {
                Text("Пробуждение: \(viewModel.weekdayStartSleepTime/60):\(String(format: "%02d", viewModel.weekdayStartSleepTime%60))")
                Spacer()
                Text("Отбой: \(viewModel.weekdayEndSleepTime/60):\(String(format: "%02d", viewModel.weekdayEndSleepTime%60))")
            }
            DoubleTimeSlider(wakeTime: $viewModel.weekdayStartSleepTime, sleepTime: $viewModel.weekdayEndSleepTime)
            
            HStack {
                Text("Пробуждение: \(viewModel.weekendStartSleepTime/60):\(String(format: "%02d", viewModel.weekendStartSleepTime%60))")
                Spacer()
                Text("Отбой: \(viewModel.weekendEndSleepTime/60):\(String(format: "%02d", viewModel.weekendEndSleepTime%60))")
            }
            DoubleTimeSlider(wakeTime: $viewModel.weekendStartSleepTime, sleepTime: $viewModel.weekendEndSleepTime)
            
            Spacer()
            
            Button("Save") {
                viewModel.saveNewSleepInstructions()
            }
            .padding(.all, 32)
            .background(.pink)
            Spacer()
        }
    }
}

struct DoubleTimeSlider: View {
    // минуты с полуночи: 0…1440
    @Binding var wakeTime: Int
    @Binding var sleepTime: Int
    
    private let minuteStep = 15
    private let totalMinutes = 24 * 60
    
    private let trackColor = Color.gray.opacity(0.3)
    private let highlightColor = Color.blue.opacity(0.5)
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            
            
            VStack(spacing: 8) {
                // MARK: — Сам слайдер
                ZStack(alignment: .leading) {
                    // фоновая полоса
                    Capsule()
                        .fill(trackColor)
                        .frame(height: 6)
                    
                    // зона «утреннего сна»
                    Capsule()
                        .fill(highlightColor)
                        .frame(width: xPosition(for: wakeTime, width: width), height: 6)
                    
                    // зона «вечернего сна»
                    Capsule()
                        .fill(highlightColor)
                        .frame(width: width - xPosition(for: sleepTime, width: width), height: 6)
                        .offset(x: xPosition(for: sleepTime, width: width))
                    
                    // ползунок «пробуждение»
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        .position(x: xPosition(for: wakeTime, width: width), y: 3)
                        .gesture(
                            DragGesture()
                                .onChanged { g in
                                    let new = timeFrom(x: g.location.x, width: width)
                                    // не пересекаем правый ползунок
                                    wakeTime = min(new, sleepTime)
                                }
                        )
                    
                    // ползунок «отбой»
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.red, lineWidth: 2))
                        .position(x: xPosition(for: sleepTime, width: width), y: 3)
                        .gesture(
                            DragGesture()
                                .onChanged { g in
                                    let new = timeFrom(x: g.location.x, width: width)
                                    // не пересекаем левый
                                    sleepTime = max(new, wakeTime)
                                }
                        )
                }
                .frame(height: 40)
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
    }
    
    // MARK: — Вспомогательные конвертеры
    func xPosition(for time: Int, width: CGFloat) -> CGFloat {
        // пропорционально ширине
        CGFloat(time) / CGFloat(totalMinutes) * width
    }
    func timeFrom(x: CGFloat, width: CGFloat) -> Int {
        // raw-время по позиции → округлим до шага
        let raw = Int((x / width) * CGFloat(totalMinutes))
        let stepped = (raw + minuteStep/2) / minuteStep * minuteStep
        return min(max(0, stepped), totalMinutes)
    }
}
