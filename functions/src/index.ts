import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as graphqlRequest from "graphql-request";

admin.initializeApp();

exports.onCreateUser = functions.auth.user().onCreate(async user => {
  return await admin
    .firestore()
    .collection("users")
    .doc(user.uid)
    .set({
      uid: user.uid,
      displayName: user.displayName ? user.displayName : null,
      email: user.email ? user.email : null,
      avatarURL: user.photoURL ? user.photoURL : null,
      role: "user",
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    });
});

exports.onUserCreateInCollection = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const user = snap.data();

    console.log(user, "this is a new user and claims must be added for them");
    let customClaims;

    // User can have there own logic for admin

    if (user.email && user.email.indexOf("@hathtech.com") !== -1) {
      customClaims = {
        "https://hasura.io/jwt/claims": {
          "x-hasura-default-role": "admin",
          "x-hasura-allowed-roles": ["user", "admin"],
          "x-hasura-user-id": user.uid
        }
      };
    } else {
      customClaims = {
        "https://hasura.io/jwt/claims": {
          "x-hasura-default-role": "user",
          "x-hasura-allowed-roles": ["user", "admin"],
          "x-hasura-user-id": user.uid
        }
      };
    }

    /**
     * Add user to hasura db
     */

    // Set custom user claims on this newly created user.
    console.log(customClaims);
    return admin
      .auth()
      .setCustomUserClaims(user.uid, customClaims)
      .then(() => {
        // Update real-time database to notify client to force refresh.
        const metadataRef = admin.database().ref("metadata/" + user.uid);
        // Set the refresh time to the current UTC timestamp.
        // This will be captured on the client to force a token refresh.
        return metadataRef.set({ refreshTime: new Date().getTime() });
      })
      .catch(error => {
        console.log(error);
      });
  });
