//
//  CalendarView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//

import SwiftUI

struct CalendarView: View {
    //@State private var tasks: [String: Task] = [:]
    @Environment(FirebaseService.self) var firebase
    @Environment(AppManager.self) var appManager
    //@State private var presentSheet = false
    @State private var dateRange: ClosedRange<Date> = Date()...Date()
    //@State private var dates: [[Date]] = []
    @State private var datesGrouped: [String: [Date]] = [:]
    var userName: String
    
    func setDateRange() {
        let startDate = firebase.users[userName]!.Challenge75.Challenge1.startDate
        let endDate = firebase.users[userName]!.Challenge75.Challenge1.endDate
        dateRange = startDate...endDate
        sortedDates()
    }
    
    private func saveTask(date: String, _ task: Task) {
        firebase.users[userName]?.Challenge75.Challenge1.tasks[date] = task
        firebase.updateTask(userName: userName, date: date, task: task)
        //tasks[date] = task
    }
    
    
    func sortedDates() {
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
            if !(firebase.users[userName]!.Challenge75.Challenge1.tasks.keys.contains(dateString)) {
                saveTask(date: dateString, Task())
            }
        }
        // Group dates by month and year
        let grouped = Dictionary(grouping: dates) { date -> String in
            let components = calendar.dateComponents([.year, .month], from: date)
            return "\(components.year!)-\(components.month!)"
        }
        self.datesGrouped = grouped
        // Convert dictionary values to [[Date]], sorted by year and month
        //self.dates = grouped.sorted { $0.key < $1.key }.map { $0.value }
        
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
        VStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(datesGrouped.keys).sorted(), id: \.self) { sectionName in
                        Section(header: Text("\(formattedDateSection(sectionName))").font(.headline)) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(datesGrouped[sectionName, default: []], id: \.self) { date in
                                    Button {
                                        print(formattedDate(date))
                                        appManager.path.append(.taskView(userName: userName, date: formattedDate(date)))
                                    } label: {
                                        VStack {
                                            RingDateView(
                                                progress: firebase.users[userName]?.Challenge75.Challenge1.tasks[formattedDate(date)]?.completionPercentage ?? 0.0, date: date)
                                            .padding(8)
                                            .frame(maxWidth: .infinity) // Ensures square-like aspect ratio within grid spacing
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.secondary.opacity(0.2)) // Use your desired color
                                                //.shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
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
        }
        .onAppear {
            loadTasks()
        }
        .navigationTitle(userName)
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
        let date = dateFormatter.date(from: date1)!
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func loadTasks() {
        setDateRange()
    }
    
}
