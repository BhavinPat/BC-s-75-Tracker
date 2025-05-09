exports.sendNotification = functions.database
    .ref('/your/database/path/{id}')
    .onWrite(async (change, context) => {
        const afterData = change.after.val();
        if (!afterData) {
            console.log("Data deleted, no notification sent.");
            return null;
        }

        // Get all user FCM tokens
        const tokensSnapshot = await admin.database()
            .ref('users')
            .once('value');

        const tokens = [];
        tokensSnapshot.forEach(user => {
            if (user.val().fcmToken) {
                tokens.push(user.val().fcmToken);
            }
        });

        // Create notification message
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

        if (tokens.length === 0) {
            console.log("No tokens found.");
            return null;
        }

        // Send to all tokens
        return admin.messaging().sendToDevice(tokens, message);
    });
