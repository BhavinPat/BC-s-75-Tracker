//
//  Untitled.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/16/25.
//

import SwiftUI

class BCDate {
    private var completion: Double = 0.0
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    func setCompletion(_ completion: Double) {
        self.completion = completion
    }
    
    func getCompletion() -> Double {
        return completion
    }
}

struct RingDateView: View {
    var progress: Double // Value between 0.0 (0%) and 1.0 (100%)
    var date: Date // Number to display inside the circle
    
    func numberFromDate() -> Int {
        return Calendar.current.component(.day, from: date)
    }
    
    private var ringColor: Color {
        Color(red: 1.0 - progress, green: progress, blue: 0.0)
    }
    
    private let startAngle: Angle = .degrees(90) // 30 degrees from bottom
    private let endAngle: Angle = .degrees(30)    // 30 degrees from bottom
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Gradient(colors: [ringColor]).opacity(0.2), lineWidth: 10)
            // Completion ring
            Circle()
                .trim(from: 0, to: min(progress, 0.97))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.red, .yellow, .green]),
                        center: .center,
                        startAngle: .degrees(-1),
                        endAngle: .degrees(350)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(95)) // Offset start point to desired angle
            // Number inside the circle
            Text("\(numberFromDate())")
                .font(.largeTitle)
                .fontWeight(.bold)
            if progress > 0.99 {
                Image(systemName: "checkmark")
                    .resizable()
                    .foregroundStyle(.green.opacity(0.2))
                    .scaledToFit()
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(5)
    }
}
