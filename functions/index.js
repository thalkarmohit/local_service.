const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.bookingNotification = functions.firestore
  .document("bookings/{id}")
  .onCreate(async (snap, context) => {

    const data = snap.data();

    const providerId = data.providerId;

    // get provider token
    const providerDoc = await admin.firestore()
      .collection("providers")
      .doc(providerId)
      .get();

    const token = providerDoc.data().fcmToken;

    // send notification
    await admin.messaging().send({
      token: token,
      notification: {
        title: "New Booking",
        body: `Date: ${data.date}, Time: ${data.time}`
      }
    });
});