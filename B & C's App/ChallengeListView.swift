//
//  ChallengeListView.swift
//  BC's 75 Tracker
//
//  Created by Codex on 4/4/26.
//

import SwiftUI

struct ChallengeListView: View {
    @Environment(FirebaseService.self) var firebase
    @Environment(AppManager.self) var appManager
    
    @State private var presentCreateSheet: Bool = false
    @State private var selectedParticipants: ChallengeParticipants = .both
    @State private var challengeAlertMessage: String = ""
    @State private var presentChallengeAlert: Bool = false
    
    var userName: String
    
    private var allChallenges: [(String, Challenge1)] {
        firebase.challenges(for: userName)
    }
    
    private var activeChallenges: [(String, Challenge1)] {
        allChallenges.filter { $0.1.isActive }
    }
    
    private var archivedChallenges: [(String, Challenge1)] {
        allChallenges.filter { !$0.1.isActive }
    }
    
    private func defaultParticipants(for user: String) -> ChallengeParticipants {
        if user.lowercased() == "chloe" {
            return .chloe
        }
        if user.lowercased() == "bhavin" {
            return .bhavin
        }
        return .both
    }
    
    private func challengeRangeText(for challenge: Challenge1) -> String {
        "\(formattedDate(challenge.startDate)) - \(formattedDate(challenge.endDate))"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    private func startChallenge() {
        if let blockedReason = firebase.startBlockedReason(participants: selectedParticipants) {
            challengeAlertMessage = blockedReason
            presentChallengeAlert = true
            return
        }
        
        if let errorMessage = firebase.startChallenge(participants: selectedParticipants) {
            challengeAlertMessage = errorMessage
            presentChallengeAlert = true
            return
        }
        
        presentCreateSheet = false
        
        if selectedParticipants.userNames.contains(userName),
           let createdChallengeID = firebase.lastCreatedChallengeID {
            appManager.path.append(.challengeCalendar(userName: userName, challengeID: createdChallengeID))
        }
    }
    
    var body: some View {
        List {
            Section("Active") {
                if activeChallenges.isEmpty {
                    Text("No active challenges.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(activeChallenges, id: \.0) { entry in
                        Button {
                            appManager.path.append(.challengeCalendar(userName: userName, challengeID: entry.0))
                        } label: {
                            challengeRow(challengeID: entry.0, challenge: entry.1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Section("History") {
                if archivedChallenges.isEmpty {
                    Text("No archived challenges yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(archivedChallenges, id: \.0) { entry in
                        Button {
                            appManager.path.append(.challengeCalendar(userName: userName, challengeID: entry.0))
                        } label: {
                            challengeRow(challengeID: entry.0, challenge: entry.1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("\(userName) 75 Challenges")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    selectedParticipants = defaultParticipants(for: userName)
                    presentCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $presentCreateSheet) {
            NavigationStack {
                Form {
                    Section("Participants") {
                        Picker("Create For", selection: $selectedParticipants) {
                            ForEach(ChallengeParticipants.allCases) { participant in
                                Text(participant.rawValue).tag(participant)
                            }
                        }
                    }
                    
                    if let blockedReason = firebase.startBlockedReason(participants: selectedParticipants) {
                        Section {
                            Text(blockedReason)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .navigationTitle("New 75 Challenge")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            presentCreateSheet = false
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Create") {
                            startChallenge()
                        }
                        .disabled(firebase.startBlockedReason(participants: selectedParticipants) != nil)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("75 Challenge", isPresented: $presentChallengeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(challengeAlertMessage)
        }
    }
    
    private func challengeRow(challengeID: String, challenge: Challenge1) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(challengeID)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(challengeRangeText(for: challenge))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(challenge.isActive ? "Active" : "Archived")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(challenge.isActive ? .green : .secondary)
        }
        .padding(.vertical, 2)
    }
}
