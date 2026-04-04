//
//  ContentView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 2/5/25.
//


import SwiftUI

struct PTrackerView: View {
    @Environment(FirebaseService.self) var firebase
    @State private var lockAlertMessage: String = ""
    @State private var showLockAlert: Bool = false
    
    private var sortedMonths: [(String, PMonth)] {
        let months = ["january", "february", "march", "april", "may", "june",
                      "july", "august", "september", "october", "november", "december"]
        
        return firebase.pTracker.sorted { (a, b) in
            let aComponents = a.key.lowercased().split(separator: "-")
            let bComponents = b.key.lowercased().split(separator: "-")
            
            guard let aMonthIndex = months.firstIndex(of: String(aComponents[0])),
                  let bMonthIndex = months.firstIndex(of: String(bComponents[0])),
                  let aYear = Int(aComponents[1]),
                  let bYear = Int(bComponents[1]) else { return false }
            
            // Sort by year descending first, then by month descending
            return aYear == bYear ? aMonthIndex > bMonthIndex : aYear > bYear
        }
    }


    
    private var groupedByYear: [String: [(String, PMonth)]] {
        Dictionary(grouping: sortedMonths) { entry in
            String(entry.0.split(separator: "-")[1])
        }
    }
    let months = ["january", "february", "march", "april", "may", "june",
                  "july", "august", "september", "october", "november", "december"]
    
    private var currentMonthKey: String {
        let now = Date()
        let calendar = Calendar.current
        let monthIndex = calendar.component(.month, from: now) - 1
        let year = calendar.component(.year, from: now)
        return "\(months[monthIndex])-\(year)"
    }
    
    private func canEdit(monthKey: String) -> Bool {
        monthKey.lowercased() == currentMonthKey
    }
    
    private func funnyLockedMessage(for monthKey: String) -> String {
        "Hands off \(formatMonth(monthKey))! Time travel is disabled, and past poops are officially archived."
    }
    
    private func updatePoopCount(monthKey: String, person: String, value: Int) {
        guard canEdit(monthKey: monthKey) else {
            lockAlertMessage = funnyLockedMessage(for: monthKey)
            showLockAlert = true
            return
        }
        
        var updatedMonth = firebase.pTracker[monthKey] ?? PMonth(bhavin: 0, chloe: 0)
        if person == "Bhavin" {
            updatedMonth.bhavin = value
        } else {
            updatedMonth.chloe = value
        }
        firebase.pTracker[monthKey] = updatedMonth
        firebase.updatePoops(key: monthKey, value: updatedMonth)
    }
    
    private func addNextMonth() {
        // If no months exist, start with January 2025
        if firebase.pTracker.isEmpty {
            let key = "january-2025"
            firebase.pTracker[key] = PMonth(bhavin: 0, chloe: 0)
            firebase.updatePoops(key: key, value: PMonth(bhavin: 0, chloe: 0))
            return
        }
        
        // Get the most recent month
        let lastEntry = sortedMonths.first! // Now correctly gets the latest month
        let components = lastEntry.0.lowercased().split(separator: "-")
        let currentMonth = String(components[0])
        let currentYear = Int(components[1])!
        
        guard let currentMonthIndex = months.firstIndex(of: currentMonth) else { return }
        
        // Calculate next month and year
        let nextMonthIndex = (currentMonthIndex + 1) % 12
        let nextYear = (nextMonthIndex == 0) ? currentYear + 1 : currentYear
        let nextMonth = months[nextMonthIndex]
        
        // Create new month entry
        let newKey = "\(nextMonth)-\(nextYear)"
        if firebase.pTracker[newKey] == nil {
            firebase.pTracker[newKey] = PMonth(bhavin: 0, chloe: 0)
            firebase.updatePoops(key: newKey, value: PMonth(bhavin: 0, chloe: 0))
        }
    }
    
    var body: some View {
        List {
            ForEach(groupedByYear.keys.sorted().reversed(), id: \.self) { year in
                Section(header: Text(year)) {
                    ForEach(groupedByYear[year] ?? [], id: \.0) { month in
                        MonthRowView(
                            month: month.0,
                            bhavinCount: Binding(
                                get: { firebase.pTracker["\(month.0)"]?.bhavin ?? 0 },
                                set: { newValue in
                                    updatePoopCount(monthKey: month.0, person: "Bhavin", value: newValue)
                                }
                            ),
                            chloeCount: Binding(
                                get: { firebase.pTracker["\(month.0)"]?.chloe ?? 0 },
                                set: { newValue in
                                    updatePoopCount(monthKey: month.0, person: "Chloe", value: newValue)
                                }
                            )
                        )
                    }
                }
            }
        }
        .onAppear {
            let now = Date()
            let calendar = Calendar.current
            let monthIndex = calendar.component(.month, from: now) - 1
            let year = calendar.component(.year, from: now)
            let currentKey = "\(months[monthIndex])-\(year)"
            if firebase.pTracker[currentKey] == nil {
                firebase.pTracker[currentKey] = PMonth(bhavin: 0, chloe: 0)
                firebase.updatePoops(key: currentKey, value: PMonth(bhavin: 0, chloe: 0))
            }
        }
        .navigationTitle("💩 Tracker")
        .alert("Nice Try 😄", isPresented: $showLockAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(lockAlertMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: addNextMonth) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func formatMonth(_ monthKey: String) -> String {
        let components = monthKey.split(separator: "-")
        guard components.count == 2 else { return monthKey }
        return "\(components[0].capitalized) \(components[1])"
    }
}

struct MonthRowView: View {
    let month: String
    @Binding var bhavinCount: Int
    @Binding var chloeCount: Int
    
    private func statusColor(name: String) -> Color {
        if bhavinCount > chloeCount {
            if name == "Bhavin" {
                return .green
            } else {
                return .red
            }
        } else if bhavinCount < chloeCount {
            if name == "Bhavin" {
                return .red
            } else {
                return .green
            }
        } else {
            return .yellow
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(formatMonth(month))
                .font(.headline)
                .padding(.bottom, 4)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    personRow(name: "Bhavin", count: $bhavinCount)
                    personRow(name: "Chloe", count: $chloeCount)
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
    
    private func personRow(name: String, count: Binding<Int>) -> some View {
        HStack {
            if iconName(for: name) == "💩" {
                Text("💩   \(name):")
                    .foregroundColor(statusColor(name: name))
                    .fontWeight(.bold)
            } else {
                Image(systemName: iconName(for: name))
                    .foregroundColor(statusColor(name: name))
                Text("\(name):")
                    .foregroundColor(statusColor(name: name))
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Stepper("\(count.wrappedValue)", value: count, in: 0...100)
        }
    }
    
    private func iconName(for name: String) -> String {
        
        if bhavinCount > chloeCount {
            if name == "Bhavin" {
                return "crown.fill"
            } else {
                return "💩"
            }
        } else if bhavinCount < chloeCount {
            if name == "Bhavin" {
                return "💩"
            } else {
                return "crown.fill"
            }
        } else {
            return "exclamationmark.circle.fill"
        }
    }
    
    private func formatMonth(_ monthKey: String) -> String {
        let components = monthKey.split(separator: "-")
        guard components.count == 2 else { return monthKey }
        return "\(components[0].capitalized) \(components[1])"
    }
}
