const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Cloud Function triggered when a new message is created
 * Sends push notifications to users mentioned in the message
 */
exports.onMessageCreated = onDocumentCreated("messages/{messageId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.log("No data associated with the event");
    return;
  }

  const message = snapshot.data();
  const messageId = event.params.messageId;

  logger.log("New message created:", messageId);

  // Get mentioned user IDs from message
  const mentions = message.mentions || [];

  if (mentions.length === 0) {
    logger.log("No mentions found in message");
    return null;
  }

  logger.log(`Found ${mentions.length} mentions in message`);

  // Get author info
  const authorDoc = await admin.firestore()
      .collection("users")
      .doc(message.userId)
      .get();

  if (!authorDoc.exists) {
    logger.error(`Author not found: ${message.userId}`);
    return null;
  }

  const author = authorDoc.data();

  // Send notification to each mentioned user
  const notifications = mentions.map(async (userId) => {
    try {
      // Get user's FCM token
      const userDoc = await admin.firestore()
          .collection("users")
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        logger.warn(`Mentioned user not found: ${userId}`);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        logger.warn(`No FCM token for user ${userId}`);
        return null;
      }

      // Send notification
      const payload = {
        notification: {
          title: `${author.name} mentioned you`,
          body: truncate(message.content, 100),
        },
        data: {
          type: "mention",
          messageId: messageId,
          fromUserId: message.userId,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: fcmToken,
      };

      await admin.messaging().send(payload);
      logger.log(`Notification sent to user ${userId}`);

      return true;
    } catch (error) {
      logger.error(`Failed to send notification to ${userId}:`, error);
      return null;
    }
  });

  await Promise.all(notifications);
  return null;
});

/**
 * Cloud Function triggered when a new comment is created
 * Sends push notifications to users mentioned in the comment
 */
exports.onCommentCreated = onDocumentCreated("comments/{commentId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.log("No data associated with the event");
    return;
  }

  const comment = snapshot.data();
  const commentId = event.params.commentId;

  logger.log("New comment created:", commentId);

  // Get mentioned user IDs from comment
  const mentions = comment.mentions || [];

  if (mentions.length === 0) {
    logger.log("No mentions found in comment");
    return null;
  }

  logger.log(`Found ${mentions.length} mentions in comment`);

  // Get author info
  const authorDoc = await admin.firestore()
      .collection("users")
      .doc(comment.userId)
      .get();

  if (!authorDoc.exists) {
    logger.error(`Comment author not found: ${comment.userId}`);
    return null;
  }

  const author = authorDoc.data();

  // Send notification to each mentioned user
  const notifications = mentions.map(async (userId) => {
    try {
      // Get user's FCM token
      const userDoc = await admin.firestore()
          .collection("users")
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        logger.warn(`Mentioned user not found: ${userId}`);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        logger.warn(`No FCM token for user ${userId}`);
        return null;
      }

      // Send notification
      const payload = {
        notification: {
          title: `${author.name} mentioned you in a comment`,
          body: truncate(comment.content, 100),
        },
        data: {
          type: "comment_mention",
          messageId: comment.messageId,
          commentId: commentId,
          fromUserId: comment.userId,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: fcmToken,
      };

      await admin.messaging().send(payload);
      logger.log(`Comment notification sent to user ${userId}`);

      return true;
    } catch (error) {
      logger.error(`Failed to send notification to ${userId}:`, error);
      return null;
    }
  });

  await Promise.all(notifications);
  return null;
});

/**
 * Callable function to set admin custom claim
 * Can only be called by existing admins
 */
exports.setAdminClaim = onCall(async (request) => {
  const {userId, isAdmin} = request.data;

  // Check if the caller is authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }

  // Get caller's custom claims
  const caller = await admin.auth().getUser(request.auth.uid);
  const callerClaims = caller.customClaims || {};

  // Only existing admins can modify admin status
  if (!callerClaims.admin) {
    throw new HttpsError(
        "permission-denied",
        "Only administrators can set admin claims",
    );
  }

  // Prevent users from removing their own admin status
  if (request.auth.uid === userId && !isAdmin) {
    throw new HttpsError(
        "permission-denied",
        "You cannot remove your own admin status",
    );
  }

  try {
    // Set the custom claim
    await admin.auth().setCustomUserClaims(userId, {admin: isAdmin});

    // Update the user's isAdmin field in Firestore
    await admin.firestore()
        .collection("users")
        .doc(userId)
        .update({isAdmin: isAdmin});

    logger.log(`Admin claim ${isAdmin ? "set" : "removed"} for user ${userId} by ${request.auth.uid}`);

    return {success: true, message: `Admin status ${isAdmin ? "granted" : "revoked"} successfully`};
  } catch (error) {
    logger.error("Error setting admin claim:", error);
    throw new HttpsError("internal", "Failed to set admin claim");
  }
});

/**
 * Cloud Function triggered when a message is created in the announcements group
 * Sends push notification to all users subscribed to announcements topic
 */
exports.onAnnouncementCreated = onDocumentCreated("messages/{messageId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.log("No data associated with the event");
    return;
  }

  const message = snapshot.data();
  const messageId = event.params.messageId;

  // Only process messages in the announcements group
  if (message.groupId !== "announcements") {
    return null;
  }

  logger.log("New announcement created:", messageId);

  try {
    // Verify the sender is an admin
    const authorDoc = await admin.firestore()
        .collection("users")
        .doc(message.userId)
        .get();

    if (!authorDoc.exists) {
      logger.error(`Author not found: ${message.userId}`);
      return null;
    }

    const author = authorDoc.data();

    if (!author.isAdmin) {
      logger.error(`Non-admin user ${message.userId} attempted to send announcement`);
      return null;
    }

    // Send notification to the announcements topic
    const payload = {
      notification: {
        title: `Announcement from ${author.name}`,
        body: truncate(message.content, 100),
      },
      data: {
        type: "announcement",
        messageId: messageId,
        groupId: "announcements",
        fromUserId: message.userId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      topic: "announcements",
    };

    await admin.messaging().send(payload);
    logger.log("Announcement notification sent to topic: announcements");

    return true;
  } catch (error) {
    logger.error("Failed to send announcement notification:", error);
    return null;
  }
});

/**
 * Truncate a string to a maximum length
 * @param {string} str - The string to truncate
 * @param {number} length - Maximum length
 * @return {string} Truncated string
 */
function truncate(str, length) {
  if (!str) return "";
  return str.length > length ? str.substring(0, length) + "..." : str;
}
