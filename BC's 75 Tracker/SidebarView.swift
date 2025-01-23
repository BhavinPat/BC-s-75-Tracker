//
//  SidebarView.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//

import SwiftUI
import Network
struct SidebarView: View {
    @State private var selectedUser: String? = nil
    @State private var firebase = FirebaseService()
    @State private var appManager = AppManager()
    let users = ["Bhavin", "Chloe"]
    
    var body: some View {
        NavigationStack(path: $appManager.path) {
            VStack {
                if !appManager.isConnected {
                    Text("You are not connected to the internet. Return back to the app when you reconnect.")
                        .frame(height: 50.0)
                        .frame(maxWidth: .greatestFiniteMagnitude)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        .background(.red)
                } else if appManager.isConnected && !firebase.users.isEmpty {
                    List(users, id: \.self, selection: $selectedUser) { user in
                        Button {
                            appManager.path.append(.calender(userName: user))
                        } label: {
                            Text(user)
                        }
                    }
                } else {
                    Text("Loading Content...")
                }
                Spacer()
            }
            .onChange(of: appManager.isConnected, initial: true) {
                if appManager.isConnected {
                    if firebase.users.isEmpty {
                        _Concurrency.Task {
                            await firebase.loadUsers()
                        }
                    }
                }
            }
            .padding(.top, 30)
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
    var monitor: NWPathMonitor
    var isConnected = false
    
    init() {
        monitor = NWPathMonitor()
        startNetworkMonitor()
    }
    func startNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
                self.isConnected = true
            } else {
                print("No connection.")
                self.isConnected = false
            }
        }
        let queue = DispatchQueue(label: "Network-Monitor")
        monitor.start(queue: queue)
    }
}

enum BCNavigation: Hashable {
    case calender(userName: String)
    case taskView(userName: String, date: String)
}

