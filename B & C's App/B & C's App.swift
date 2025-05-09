//
//  BC_s_75_TrackerApp.swift
//  BC's 75 Tracker
//
//  Created by Bhavin Patel on 1/15/25.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Request notification permission
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Handle FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            // Store this token in your database to send notifications to this device
            print("FCM token: \(token)")
            saveTokenToDatabase(token: token)
        }
    }
    
    func saveTokenToDatabase(token: String) {
        let ref = Database.database().reference()
        // Save the token under the user's ID
        if let userId = Auth.auth().currentUser?.uid {
            ref.child("users").child(userId).child("fcmToken").setValue(token)
        }
    }
    
}

@main
struct YourApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthLandingView()
        }
    }
}
