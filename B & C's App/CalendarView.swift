//
//  CalendarView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//

import SwiftUI

struct CalendarView: View {
    @Environment(FirebaseService.self) var firebase
    @Environment(AppManager.self) var appManager
    @State private var dateRange: ClosedRange<Date> = Date()...Date()
    @State private var datesGrouped: [String: [Date]] = [:]
    @State private var presentEndChallengeAlert: Bool = false
    @State private var challengeAlertMessage: String = ""
    @State private var presentChallengeAlert: Bool = false
    var userName: String
    var challengeID: String
    
    private var selectedChallenge: Challenge1? {
        firebase.challenge(for: userName, challengeID: challengeID)
    }
    
    private var isEditable: Bool {
        selectedChallenge?.isActive == true
    }
    
    private func endChallenge() {
        if let errorMessage = firebase.endChallenge(userName: userName, challengeID: challengeID) {
            challengeAlertMessage = errorMessage
            presentChallengeAlert = true
            return
        }
        loadTasks()
    }
    
    func setDateRange() {
        guard let challenge = selectedChallenge else {
            datesGrouped = [:]
            dateRange = Date()...Date()
            return
        }
        let startDate = challenge.startDate
        let endDate = challenge.endDate
        dateRange = startDate...endDate
        sortedDates()
    }
    
    private func saveTask(date: String, _ task: Task) {
        guard isEditable else { return }
        firebase.updateTask(userName: userName, challengeID: challengeID, date: date, task: task)
    }
    
    
    func sortedDates() {
        guard selectedChallenge != nil else {
            datesGrouped = [:]
            return
        }
        
        let calendar = Calendar.current
        
        // Extract all dates within the range
        var dates: [Date] = []
        var currentDate = dateRange.lowerBound
        
        while currentDate <= dateRange.upperBound {
            dates.append(currentDate)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        for date in dates {
            let dateString = formattedDate(date)
            let hasTask = selectedChallenge?.tasks.keys.contains(dateString) ?? false
            if isEditable && !hasTask {
                saveTask(date: dateString, Task())
            }
        }
        // Group dates by month and year
        let grouped = Dictionary(grouping: dates) { date -> String in
            let components = calendar.dateComponents([.year, .month], from: date)
            return String(format: "%04d-%02d", components.year ?? 0, components.month ?? 1)
        }
        self.datesGrouped = grouped
    }
    
    private let columns = [
        GridItem(.flexible()), // Flexible column for even spacing
        GridItem(.flexible()), // Flexible column for even spacing
        GridItem(.flexible()) // Two items per row
    ]
    
    
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        Group {
            if selectedChallenge != nil {
                ScrollViewReader { proxy in
                    List {
                        Section {
                            HStack {
                                Text(challengeID)
                                    .font(.headline)
                                Spacer()
                                Text(isEditable ? "Active" : "Archived")
                                    .foregroundStyle(isEditable ? .green : .secondary)
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        
                        ForEach(Array(datesGrouped.keys).sorted(), id: \.self) { sectionName in
                            Section(header: Text("\(formattedDateSection(sectionName))").font(.headline)) {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(datesGrouped[sectionName, default: []], id: \.self) { date in
                                        Button {
                                            print(formattedDate(date))
                                            appManager.path.append(.taskView(userName: userName, date: formattedDate(date), challengeID: challengeID))
                                        } label: {
                                            VStack {
                                                RingDateView(
                                                    progress: selectedChallenge?.tasks[formattedDate(date)]?.completionPercentage ?? 0.0,
                                                    date: date
                                                )
                                                .padding(8)
                                                .frame(maxWidth: .infinity) // Ensures square-like aspect ratio within grid spacing
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.secondary.opacity(0.2)) // Use your desired color
                                                )
                                            }
                                        }
                                        .id(date)
                                        .buttonStyle(.plain)
                                        
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(.clear)
                    .onAppear {
                        scrollToToday(proxy: proxy)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Challenge Not Found",
                    systemImage: "exclamationmark.circle",
                    description: Text("This challenge may have been removed or not synced yet.")
                )
            }
        }
        .onAppear {
            loadTasks()
        }
        .onChange(of: firebase.challenge(for: userName, challengeID: challengeID)?.isActive ?? false, initial: false) {
            loadTasks()
        }
        .navigationTitle(userName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEditable {
                    Button(role: .destructive) {
                        presentEndChallengeAlert = true
                    } label: {
                        Text("End")
                    }
                }
            }
        }
        .alert("End Challenge?", isPresented: $presentEndChallengeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End", role: .destructive) {
                endChallenge()
            }
        } message: {
            Text("This challenge will move to history and become view-only.")
        }
        .alert("75 Challenge", isPresented: $presentChallengeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(challengeAlertMessage)
        }
    }

    private func scrollToToday(proxy: ScrollViewProxy) {
        let today = Date()
        // Flatten all dates into a single array
        let allDates = datesGrouped.flatMap { $0.value }
        // Find the closest date to today
        if let closestDate = allDates.min(by: { abs($0.timeIntervalSince(today)) < abs($1.timeIntervalSince(today)) }) {
            proxy.scrollTo(closestDate, anchor: .top)
        }
    }
    
    func formattedDateSection(_ date1: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        guard let date = dateFormatter.date(from: date1) else { return date1 }
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func loadTasks() {
        setDateRange()
    }
    
}
