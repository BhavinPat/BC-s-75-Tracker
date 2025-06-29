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
                List(selection: $selectedUser) {
                    // Shared Section
                    Section("Shared") {
                        Button {
                            appManager.path.append(.poopTracker)
                        } label: {
                            ListRowView(
                                title: "Poop Tracker",
                                iconName: "figure.2.circle.fill"
                            )
                        }
                    }
                    
                    // User Sections
                    ForEach(users, id: \.self) { user in
                        Section(user) {
                            Button {
                                appManager.path.append(.calender(userName: user))
                            } label: {
                                ListRowView(
                                    title: "75 Soft",
                                    iconName: "figure.strengthtraining.traditional"
                                )
                            }
                            Button {
                                // Push-Up Challenge for this user
                                // Use the first available challenge name if present, or a default (e.g., "Main")
                               // let challengeName = firebase.users[user]?.PushUpChallenges.keys.first ?? "Main"
                                appManager.path.append(.pushUpCalendar(userName: user))
                            } label: {
                                ListRowView(
                                    title: "Push-Up Challenge",
                                    iconName: "figure.strengthtraining.functional"
                                )
                            }
                        }
                    }
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
                print("Loading users")
                firebase.load()
            }
        }
        .navigationTitle("B & C's App!")
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
    case poopTracker
    case pushUpCalendar(userName: String)
    case pushUpTaskView(userName: String, date: String)
}


struct ListRowView: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack {
            Label {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: iconName)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}


