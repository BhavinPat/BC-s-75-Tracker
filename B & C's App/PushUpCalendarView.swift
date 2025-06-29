//
//  PushUpCalendarView.swift
//  BC's 75 Tracker
//
//  Created by Assistant on 6/28/25.
//

import SwiftUI


struct PushUpCalendarView: View {
    //@State private var tasks: [String: Task] = [:]
    @Environment(FirebaseService.self) var firebase
    @Environment(AppManager.self) var appManager
    //@State private var presentSheet = false
    @State private var dateRange: ClosedRange<Date> = Date()...Date()
    //@State private var dates: [[Date]] = []
    @State private var datesGrouped: [String: [Date]] = [:]
    var userName: String
    
    @State var presentPushUpTaskView = false
    
    @State private var showGoalPopover = false
    @State private var newGoal = 0
    @State private var goalAnchor: Anchor<CGRect>? = nil
    
    func setDateRange() {
        let keys = firebase.users[userName]!.pushUpTasks.keys
        let sortedDates = keys.sorted(by: {
            formattedString($0) < formattedString($1)
        })
        
        let startDate = formattedString(sortedDates.first ?? nil)
        let endDate = Date()
        dateRange = startDate...endDate
        sortDates()
    }
    
    private func saveTask(date: String, _ task: PushUpTask) {
        firebase.users[userName]?.pushUpTasks[date] = task
        firebase.updatePushUpTask(userName: userName, date: date, task: task)
    }
    
    
    func sortDates() {
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
            if !(firebase.users[userName]!.pushUpTasks.keys.contains(dateString)) {
                // Determine previous day's goal, or default
                let previousDay = calendar.date(byAdding: .day, value: -1, to: date)
                let prevString = previousDay.map { formattedDate($0) } ?? ""
                let prevGoal = firebase.users[userName]?.pushUpTasks[prevString]?.goal ?? 50
                var newTask = PushUpTask()
                newTask.goal = prevGoal
                saveTask(date: dateString, newTask)
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
    func formattedString(_ string: String?) -> Date {
        guard let string else {
            return Date()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: string) ?? Date()
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
                                        appManager.path.append(.pushUpTaskView(userName: userName, date: formattedDate(date)))
                                    } label: {
                                        VStack {
                                            RingDateView(
                                                progress: firebase.users[userName]?.pushUpTasks[formattedDate(date)]?.completionPercentage ?? 0.0, date: date)
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
            let todayString = formattedDate(Date())
            newGoal = firebase.users[userName]?.pushUpTasks[todayString]?.goal ?? 50
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    let todayString = formattedDate(Date())
                    newGoal = firebase.users[userName]?.pushUpTasks[todayString]?.goal ?? 0
                    showGoalPopover = true
                } label: {
                    Text("Change Goal")
                }
                .popover(isPresented: $showGoalPopover) {
                    VStack {
                        Text("Set a New Goal")
                            .font(.headline)
                        Stepper(value: $newGoal, in: 0...1000, step: 1) {
                            Text("Goal: \(newGoal)")
                        }
                        Button("Save") {
                            let todayString = formattedDate(Date())
                            if let existingTask = firebase.users[userName]?.pushUpTasks[todayString] {
                                var updatedTask = existingTask
                                updatedTask.goal = newGoal
                                saveTask(date: todayString, updatedTask)
                            } else {
                                var newTask = PushUpTask()
                                newTask.goal = newGoal
                                saveTask(date: todayString, newTask)
                            }
                            showGoalPopover = false
                        }
                        .padding(.top)
                    }
                    .padding()
                    .frame(width: 220, height: 100)
                }
            }
        }
        /*
        .sheet(isPresented: $presentPushUpTaskView) {
            PushUpTaskView(userName: <#T##String#>, date: <#T##String#>)
        }
         */
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

