//
//  SidebarView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//

import SwiftUI

struct SidebarView: View {
    @State private var selectedUser: String? = nil
    @State private var firebase = FirebaseService()
    @State private var appManager = AppManager()
    let users = ["Bhavin", "Chloe"]
    
    var body: some View {
        NavigationStack(path: $appManager.path) {
            List(users, id: \.self, selection: $selectedUser) { user in
                Button {
                    appManager.path.append(.calender(userName: user))
                } label: {
                    Text(user)
                }
            }
            .listStyle(.automatic)
            .navigationTitle("75 Soft")
            .navigationDestination(for: BCNavigation.self) {
                value in
                switch value {
                    case .calender(let userName):
                        CalendarView(userName: userName)
                            .environment(firebase)
                            .environment(appManager)
                    case .taskView(let userName, let date):
                        TaskView(userName: userName, date: date)
                            .environment(firebase)
                            .environment(appManager)
                }
            }
        }
    }
}
@Observable
class AppManager {
    var path: [BCNavigation] = []
}

enum BCNavigation: Hashable {
    case calender(userName: String)
    case taskView(userName: String, date: String)
}

