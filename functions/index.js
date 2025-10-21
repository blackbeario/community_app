const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const {defineSecret} = require("firebase-functions/params");

// Define the Anthropic API key as a secret
const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

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

/**
 * Select an emoji based on keywords in name and description
 * TEMPORARY fallback until Anthropic billing works
 * @param {string} name - Group name
 * @param {string} description - Group description
 * @return {string} Selected emoji
 */
function selectEmojiByKeywords(name, description) {
  const text = `${name} ${description}`.toLowerCase();

  const keywords = [
    {words: ["sport", "fitness", "gym", "workout", "exercise"], emoji: "🏋️"},
    {words: ["golf", "golfing"], emoji: "⛳"},
    {words: ["boat", "sailing", "yacht", "marina"], emoji: "⛵"},
    {words: ["book", "reading", "library"], emoji: "📚"},
    {words: ["food", "cooking", "recipe", "chef"], emoji: "👨‍🍳"},
    {words: ["music", "band", "concert"], emoji: "🎵"},
    {words: ["art", "painting", "creative"], emoji: "🎨"},
    {words: ["tech", "coding", "programming", "developer"], emoji: "💻"},
    {words: ["game", "gaming", "esports"], emoji: "🎮"},
    {words: ["travel", "adventure", "explore"], emoji: "✈️"},
    {words: ["photo", "photography", "camera"], emoji: "📷"},
    {words: ["garden", "plant", "flower"], emoji: "🌱"},
    {words: ["pet", "dog", "cat", "animal"], emoji: "🐾"},
    {words: ["family", "parent", "kids", "children"], emoji: "👨‍👩‍👧‍👦"},
    {words: ["business", "professional", "work"], emoji: "💼"},
    {words: ["volunteer", "charity", "help"], emoji: "🤝"},
    {words: ["education", "school", "learning"], emoji: "🎓"},
    {words: ["health", "medical", "wellness"], emoji: "⚕️"},
    {words: ["movie", "film", "cinema"], emoji: "🎬"},
    {words: ["coffee", "cafe"], emoji: "☕"},
    {words: ["staff", "team", "admin"], emoji: "👥"},
  ];

  // Find matching keyword
  for (const {words, emoji} of keywords) {
    if (words.some((word) => text.includes(word))) {
      return emoji;
    }
  }

  // Default emojis if no match
  const defaults = ["📁", "💬", "🌟", "🎯", "🔔", "📌", "🎪", "🎭", "🎨", "🎯"];
  return defaults[Math.floor(Math.random() * defaults.length)];
}

/**
 * Callable function to generate an emoji for a group using Claude API
 * Only callable by admin users
 */
exports.generateGroupEmoji = onCall({secrets: [anthropicApiKey]}, async (request) => {
  const {name, description} = request.data;

  // Check if the caller is authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }

  // Get caller's info from Firestore
  const callerDoc = await admin.firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

  if (!callerDoc.exists) {
    throw new HttpsError("not-found", "User not found");
  }

  const caller = callerDoc.data();

  // Only admins can generate group emojis
  if (!caller.isAdmin) {
    throw new HttpsError(
        "permission-denied",
        "Only administrators can generate group emojis",
    );
  }

  // Validate input
  if (!name || !description) {
    throw new HttpsError("invalid-argument", "Name and description are required");
  }

  try {
    logger.log(`Generating emoji for group: ${name}`);

    // TEMPORARY FALLBACK: Use keyword-based emoji selection
    // TODO: Switch back to Claude API once billing is working
    // const emoji = selectEmojiByKeywords(name, description);
    // logger.log(`Generated emoji: ${emoji} for group: ${name}`);
    // return {emoji: emoji};

    // Call Anthropic API
    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": anthropicApiKey.value(),
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-5-20250929",
        max_tokens: 10,
        messages: [{
          role: "user",
          content: `Suggest ONE emoji that best represents a group named "${name}" with description "${description}". Respond with ONLY the emoji character, nothing else.`,
        }],
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      logger.error("Anthropic API error:", errorText);
      throw new HttpsError("internal", "Failed to generate emoji");
    }

    const data = await response.json();
    logger.log("Full API response:", JSON.stringify(data)); // Add this to see the full response
    const emoji = data.content[0].text.trim();

    logger.log(`Generated emoji: ${emoji} for group: ${name}`);
    return {emoji: emoji};

  } catch (error) {
    logger.error("Error generating emoji:", error);
    throw new HttpsError("internal", "Failed to generate emoji");
  }
});
