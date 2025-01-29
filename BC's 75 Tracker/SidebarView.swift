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
    @Environment(FirebaseService.self) var firebase
    @Environment(AppManager.self) var appManager
    let users = ["Bhavin", "Chloe"]
    
    var body: some View {
        VStack(spacing: 0) {
            if !appManager.isConnected {
                // Offline Banner
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.title3)
                        
                        Text("No Internet Connection")
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    Text("Please check your connection and try again")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.1))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.red.opacity(0.2))
                }
                .padding()
            } else if !firebase.users.isEmpty {
                // User List
                List(users, id: \.self, selection: $selectedUser) { user in
                    Button {
                        appManager.path.append(.calender(userName: user))
                    } label: {
                        HStack {
                            Label {
                                Text(user)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            } icon: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    )
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(uiColor: .systemGroupedBackground))
            } else {
                // Loading State
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                    
                    Text("Loading Users...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
        .onChange(of: appManager.isConnected, initial: true) {
            if appManager.isConnected && firebase.users.isEmpty {
                firebase.loadUsers()
            }
        }
        .navigationTitle("75 Soft")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Add refresh action if needed
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(!appManager.isConnected)
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
    case createAccount
    case signin
    case chooseUser
}

