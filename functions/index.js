const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotification = functions.database
    .ref('/your/database/path/{id}')
    .onWrite(async (change, context) => {
        const afterData = change.after.val();
        
        if (!afterData) {
            console.log("No data after change, skipping notification.");
            return null;
        }

        try {
            const tokensSnapshot = await admin.database().ref('users').once('value');
            const tokens = [];

            tokensSnapshot.forEach(user => {
                if (user.val().fcmToken) {
                    tokens.push(user.val().fcmToken);
                }
            });

            if (tokens.length === 0) {
                console.log("No valid FCM tokens found.");
                return null;
            }

            const message = {
                notification: {
                    title: 'Database Updated',
                    body: 'A change has occurred in the database'
                },
                data: {
                    changeType: 'update',
                    path: context.params.id
                }
            };

            const response = await admin.messaging().sendMulticast({
                tokens: tokens,
                ...message
            });

            console.log(`Successfully sent notifications: ${response.successCount} messages sent.`);

            if (response.failureCount > 0) {
                console.log(`Failed to send ${response.failureCount} messages.`);
            }

            return null;
        } catch (error) {
            console.error("Error sending notification:", error);
            return null;
        }
    });
