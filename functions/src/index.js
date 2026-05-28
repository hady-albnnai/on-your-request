// functions/src/index.js
// Cloud Function: حذف المنشورات المنتهية الصلاحية كل 6 ساعات
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger }     = require("firebase-functions");
const admin          = require("firebase-admin");

admin.initializeApp();

exports.deleteExpiredPosts = onSchedule(
  { schedule: "0 */6 * * *", timeZone: "Asia/Damascus" },
  async () => {
    const db     = admin.firestore();
    const bucket = admin.storage().bucket();
    const now    = admin.firestore.Timestamp.now();

    // 1. جلب المنشورات النشطة المنتهية الصلاحية
    const expired = await db.collection("posts")
      .where("expiresAt", "<", now)
      .where("status", "==", "active")
      .get();

    if (expired.empty) {
      logger.info("No expired posts found.");
      return;
    }
    logger.info(`Found ${expired.size} expired posts.`);

    // 2. حذف الصور من Storage (storagePath فقط، بدون fallback)
    const imageDeletes = expired.docs.map(async (doc) => {
      const post = doc.data();
      if (!post.storagePath) {
        if (post.imageUrl) {
          logger.warn(`Post ${doc.id}: has imageUrl but no storagePath, skipping image.`);
        }
        return;
      }
      try {
        await bucket.file(post.storagePath).delete();
        logger.info(`Deleted image: ${post.storagePath}`);
      } catch (err) {
        logger.warn(`Failed to delete image ${post.storagePath}: ${err.message}`);
      }
    });
    await Promise.allSettled(imageDeletes);

    // 3. حذف التبليغات المرتبطة (على دفعات بسبب حد whereIn = 30)
    const expiredIds = expired.docs.map((d) => d.id);
    const chunks = [];
    for (let i = 0; i < expiredIds.length; i += 30) {
      chunks.push(expiredIds.slice(i, i + 30));
    }
    for (const chunk of chunks) {
      const reports = await db.collection("reports")
        .where("postId", "in", chunk)
        .get();
      if (!reports.empty) {
        const rb = db.batch();
        reports.docs.forEach((r) => rb.delete(r.ref));
        await rb.commit();
        logger.info(`Deleted ${reports.size} reports for chunk.`);
      }
    }

    // 4. حذف المنشورات على دفعات (حد 400 لهامش أمان)
    const BATCH_SIZE = 400;
    let batch = db.batch();
    let count = 0;
    const commits = [];

    expired.docs.forEach((doc) => {
      batch.delete(doc.ref);
      count++;
      if (count === BATCH_SIZE) {
        commits.push(batch.commit());
        batch = db.batch();
        count = 0;
      }
    });
    if (count > 0) commits.push(batch.commit());
    await Promise.all(commits);

    logger.info(`Done. Deleted ${expired.size} posts + images + reports.`);
  }
);
