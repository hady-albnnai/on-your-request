# 📱 تطبيق "بخدمتك" – الوثيقة التقنية النهائية الشاملة
**النسخة 2.0 – المحسّنة والمكتملة**
*تعتمد على الوثيقة الأصلية (v1.0) مع دمج جميع التحسينات المتفق عليها واقتراحات إضافية لضمان الأمان والأداء وقابلية التوسع.*

---

## 📋 قائمة المحتويات

1. [نظرة عامة عن التطبيق](#1-نظرة-عامة)
2. [حالات الاستخدام الرئيسية](#2-حالات-الاستخدام)
3. [تدفق المستخدم الكامل](#3-تدفق-المستخدم)
4. [الخوارزميات التفصيلية](#4-الخوارزميات)
   - 4.1 تسجيل الدخول ووضع الزائر
   - 4.2 عرض القوائم مع البحث والفلتر والترحيل
   - 4.3 إضافة منشور جديد (مع منع التكرار + تنظيف الصور)
   - 4.4 زر الاتصال وزيادة العداد
   - 4.5 شاشة "حسابي" وإدارة المنشورات
   - 4.6 التبليغ عن منشور
   - 4.7 مشاركة المنشور
   - 4.8 الحذف التلقائي للمنشورات (Cloud Function)
   - 4.9 [جديد] آلية إعادة المحاولة (Retry with Exponential Backoff)
   - 4.10 [جديد] بناء الكلمات المفتاحية المحسّن
5. [هيكل البيانات (Firestore)](#5-هيكل-البيانات)
6. [الفهارس المطلوبة](#6-الفهارس)
7. [قواعد الأمان](#7-قواعد-الأمان)
8. [معالجة الأخطاء وتحسين الأداء](#8-معالجة-الأخطاء)
9. [اختبار حالة السباق](#9-اختبار-السباق)
10. [سجل التغييرات (ما الجديد في v2.0)](#10-سجل-التغييرات)
11. [توصيات ما بعد MVP](#11-توصيات-مستقبلية)

---

## 1. نظرة عامة

**تطبيق "بخدمتك"** سوق محلي يربط مقدمي الخدمات/المنتجات (عروض) بطالبيها (طلبات). يعمل بنظام **مستخدمين مسجلين** (عبر رقم الهاتف) و**وضع زائر** (مشاهدة فقط).

### المميزات الرئيسية
- نشر طلبات وعروض مع صور اختيارية.
- بحث وفلترة حسب المنطقة ونص حر مع تطبيع عربي كامل.
- التواصل مع صاحب المنشور (هاتف أو واتساب) مع عداد الاتصالات.
- إدارة المنشورات: تجديد، إنهاء، حذف.
- التبليغ عن المنشورات المخالفة مع حماية من التكرار.
- حذف تلقائي للمنشورات المنتهية بعد 15 يوماً.
- تقييم التطبيق بعد إنهاء الطلب.

### التقنيات المستخدمة
| المكوّن | التقنية |
|--------|---------|
| الواجهة | Android (Kotlin) + Jetpack (ViewModel, LiveData, Coroutines) |
| المصادقة | Firebase Authentication (رقم الهاتف) |
| قاعدة البيانات | Firestore |
| الملفات | Firebase Storage |
| المهام الجدولة | Cloud Functions (Node.js 18+) |
| التخزين المحلي | SharedPreferences + ذاكرة مؤقتة في الـ ViewModel |

---

## 2. حالات الاستخدام

| المستخدم | الحالة | الوصف |
|---------|--------|-------|
| زائر | تصفح | يرى القوائم بدون اتصال أو إضافة |
| زائر | محاولة اتصال/إضافة | يُطلب منه تسجيل الدخول |
| مسجل | تسجيل الدخول | رقم هاتف + رمز SMS |
| مسجل | نشر طلب/عرض | مع منع تكرار نفس المنشور في 24 ساعة |
| مسجل | التواصل مع صاحب منشور | هاتف أو واتساب + زيادة العداد |
| مسجل | بحث وفلترة | بمنطقة ونص حر مع ترحيل |
| مسجل | إدارة منشوراته | تجديد (≤ يومان) / إنهاء / حذف |
| مسجل | التبليغ | لا يبلّغ عن نفسه، لا تكرار |
| النظام | حذف تلقائي | كل 6 ساعات – يحذف المنشورات وصورها |

---

## 3. تدفق المستخدم الكامل

### 3.1 فتح التطبيق (أول مرة)
```
فتح التطبيق
     │
     ├── userId موجود في SharedPreferences؟
     │        ├── نعم ──► MainActivity (حالة مسجل)
     │        └── لا  ──► شاشة الترحيب
     │                        ├── "تسجيل الدخول" ──► PhoneAuthActivity
     │                        └── "تصفح كزائر"   ──► MainActivity (حالة زائر)
```

### 3.2 تسجيل الدخول
```
إدخال رقم الهاتف ──► إرسال SMS ──► إدخال الرمز (60 ثانية)
     │
     ├── نجاح ──► تخزين userId + phoneNumber ──► MainActivity (مسجل)
     └── فشل / انتهاء مهلة ──► رسالة خطأ واضحة + زر "إعادة الإرسال"
```

### 3.3 الشاشة الرئيسية
- **تبويبان:** طلبات / عروض.
- شريط بحث مع تأخير `300ms` (debounce).
- فلتر منطقة (منسدل).
- التمرير للأسفل يحمّل المزيد (ترحيل بـ 20 عنصراً).
- لكل منشور: عنوان، تفاصيل مختصرة، سعر (للعروض)، منطقة، عداد الاتصالات.
- أزرار مشروطة: اتصال / تبليغ / مشاركة (للمسجلين فقط، وليس لصاحب المنشور).

### 3.4 إضافة منشور
```
FAB (+) ──► شاشة الإضافة
     │
     ├── نوع (طلب/عرض) + عنوان + تفاصيل + منطقة + سعر (عرض) + صورة (اختياري)
     │
     └── نشر:
          1. التحقق من صحة الحقول
          2. رفع الصورة (إن وجدت) ── فشل ──► حذف الصورة المرفوعة + رسالة خطأ
          3. معاملة Firestore (تحقق من التكرار + كتابة)
          4. فشل المعاملة ──► حذف الصورة المرفوعة (تنظيف) + رسالة خطأ
          5. نجاح ──► العودة + تحديث القائمة
```

### 3.5 شاشة "حسابي"
- قائمة منشورات المستخدم (الأحدث أولاً).
- تجديد (يظهر فقط إذا ≤ يومان على الانتهاء + `status = active`).
- إنهاء (يغيّر الحالة + يعرض حوار التقييم).
- حذف (يحذف المنشور + صورته من Storage).
- زر تسجيل الخروج.

---

## 4. الخوارزميات التفصيلية

### 4.1 تسجيل الدخول ووضع الزائر

```kotlin
// Splash / MainActivity
fun checkLoginState() {
    if (sharedPrefs.contains("userId")) {
        gotoMainActivity(loggedIn = true)
    } else {
        gotoWelcomeScreen()
    }
}

// شاشة تسجيل الدخول
fun sendVerificationCode(phone: String) {
    if (phone.isBlank() || !phone.startsWith("+")) {
        showError("أدخل رقم هاتف صحيح بصيغة دولية")
        return
    }
    showLoading(true)
    viewModelScope.launch {
        try {
            withTimeout(30_000) {
                FirebaseAuth.getInstance().signInWithPhoneNumber(phone, buildCallbacks())
            }
        } catch (e: TimeoutCancellationException) {
            showError("انتهت المهلة، تأكد من اتصالك بالإنترنت")
        } catch (e: FirebaseAuthException) {
            // [تحسين] تمييز أنواع الأخطاء للمستخدم
            val msg = when (e.errorCode) {
                "ERROR_INVALID_PHONE_NUMBER" -> "رقم الهاتف غير صحيح"
                "ERROR_TOO_MANY_REQUESTS"   -> "طلبات كثيرة، انتظر قليلاً"
                else                        -> "خطأ في التحقق: ${e.message}"
            }
            showError(msg)
        } finally {
            showLoading(false)
        }
    }
}

// بعد التحقق بنجاح
fun onVerificationSuccess(firebaseUser: FirebaseUser) {
    val userId = firebaseUser.uid
    val phone  = firebaseUser.phoneNumber ?: ""

    // [تحسين] merge لضمان عدم حذف بيانات موجودة
    val userData = mapOf(
        "phoneNumber" to phone,
        "userType"    to "user",
        "createdAt"   to FieldValue.serverTimestamp(),
        "lastLoginAt" to FieldValue.serverTimestamp() // [جديد] تتبع آخر دخول
    )
    usersRef.document(userId).set(userData, SetOptions.merge())

    sharedPrefs.edit()
        .putString("userId", userId)
        .putString("phoneNumber", phone) // [تحسين] تخزين محلي لتجنب استعلام لاحق
        .apply()

    phoneCache[userId] = phone
    gotoMainActivity(loggedIn = true)
}

// تحديث الواجهة بحسب حالة المستخدم
fun updateUIForUserState(isLoggedIn: Boolean) {
    fabAdd.visibility = if (isLoggedIn) View.VISIBLE else View.GONE
    adapter.setLoggedIn(isLoggedIn) // يتحكم في ظهور أزرار الاتصال/التبليغ
}
```

---

### 4.2 عرض القوائم مع البحث والفلتر والترحيل

```kotlin
// ViewModel
class PostsViewModel : ViewModel() {
    private var lastVisible: DocumentSnapshot? = null
    private var isLoading  = false
    private var hasMore    = true
    private var currentRequestId = 0

    var currentType   = "request"
    var selectedRegion = "جميع المناطق"
    var searchText    = ""

    // [تحسين] تأخير البحث لتجنب استعلامات زائدة
    private var searchJob: Job? = null
    fun onSearchTextChanged(text: String) {
        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            delay(300)
            searchText = text
            resetAndReload()
        }
    }

    fun resetAndReload() {
        lastVisible = null
        hasMore     = true
        currentRequestId++
        _posts.value = emptyList()
        loadMorePosts(currentRequestId)
    }

    fun loadMorePosts(requestId: Int) {
        if (isLoading || !hasMore || requestId != currentRequestId) return
        isLoading = true
        _loadingState.value = LoadingState.LOADING

        var query: Query = postsRef
            .whereEqualTo("type", currentType)
            .whereGreaterThan("expiresAt", Timestamp.now())
            .whereEqualTo("status", "active") // [تحسين] استبعاد المكتملة من القائمة الرئيسية

        if (selectedRegion != "جميع المناطق") {
            query = query.whereEqualTo("region", selectedRegion)
        }
        if (searchText.isNotBlank()) {
            // [تحسين] تطبيق نفس منطق التطبيع المستخدم عند الكتابة
            val normalized = normalizeAndRemoveArticle(searchText.trim())
            query = query.whereArrayContains("searchKeywords", normalized)
        }

        query = query
            .orderBy("expiresAt", Direction.ASCENDING)  // [تحسين] الترتيب بالانتهاء أولاً
            .orderBy("createdAt", Direction.DESCENDING)
            .limit(20)

        if (lastVisible != null) query = query.startAfter(lastVisible!!)

        viewModelScope.launch {
            try {
                val snapshots = withTimeout(30_000) { query.get().await() }

                // التحقق من أن الطلب لا يزال ذا صلة
                if (requestId != currentRequestId) return@launch

                val newPosts = snapshots.toObjects(Post::class.java)
                hasMore     = newPosts.size == 20
                lastVisible = if (newPosts.isNotEmpty()) snapshots.documents.last() else lastVisible

                _posts.value = (_posts.value ?: emptyList()) + newPosts
                _loadingState.value = LoadingState.SUCCESS

            } catch (e: TimeoutCancellationException) {
                if (requestId == currentRequestId) {
                    _loadingState.value = LoadingState.ERROR("فشل التحميل، اسحب للأسفل للمحاولة")
                }
            } catch (e: FirebaseFirestoreException) {
                if (requestId == currentRequestId) {
                    _loadingState.value = LoadingState.ERROR("خطأ في قاعدة البيانات")
                    Log.e("Posts", "Firestore error", e)
                }
            } finally {
                isLoading = false
            }
        }
    }
}
```

---

### 4.3 إضافة منشور جديد (مع تنظيف الصورة عند الفشل)

```kotlin
fun publishPost(
    type: String, title: String, details: String,
    region: String, price: Double?, currency: String, imageUri: Uri?
) {
    // ── 1. التحقق من صحة البيانات ──────────────────────────────────────
    if (title.isBlank())                          { showError("العنوان مطلوب"); return }
    if (title.length > 100)                       { showError("العنوان طويل جداً (100 حرف كحد أقصى)"); return }
    if (type == "offer" && (price == null || price <= 0)) { showError("أدخل سعراً صحيحاً"); return }
    if (region == "جميع المناطق")                { showError("اختر منطقة محددة"); return }
    if (details.length > 500)                     { showError("التفاصيل طويلة جداً (500 حرف كحد أقصى)"); return }

    // ── 2. منع الضغط المتكرر ──────────────────────────────────────────
    if (isPublishing) return
    isPublishing = true
    showLoading(true)

    val postId      = postsRef.document().id
    var imageUrl:   String? = null
    var storagePath: String? = null

    viewModelScope.launch {
        // ── 3. رفع الصورة إن وجدت ────────────────────────────────────
        if (imageUri != null) {
            storagePath = "posts/$postId/image.jpg"
            val imageRef    = FirebaseStorage.getInstance().getReference(storagePath!!)
            val compressed  = compressImage(imageUri, maxSizeKB = 300)
            try {
                withTimeout(30_000) { imageRef.putFile(compressed).await() }
                imageUrl = withTimeout(10_000) { imageRef.downloadUrl.await().toString() }
            } catch (e: Exception) {
                // [تحسين] تنظيف الصورة المرفوعة جزئياً قبل الخروج
                imageRef.delete().addOnFailureListener { Log.w("Upload", "Cleanup failed", it) }
                showError("فشل رفع الصورة، تأكد من الاتصال")
                isPublishing = false
                showLoading(false)
                return@launch
            }
        }

        // ── 4. بناء الكلمات المفتاحية ─────────────────────────────────
        val keywords = buildSearchKeywords(title, details, region)

        // ── 5. بيانات المنشور ─────────────────────────────────────────
        val now    = System.currentTimeMillis()
        val expiry = now + 15L * 24 * 60 * 60 * 1000
        val post   = mapOf(
            "id"             to postId,
            "userId"         to currentUserId,
            "type"           to type,
            "title"          to title.trim(),
            "details"        to details.trim(),
            "region"         to region,
            "price"          to price,
            "currency"       to currency,
            "imageUrl"       to imageUrl,
            "storagePath"    to storagePath, // [مهم] إلزامي إذا وُجدت صورة
            "status"         to "active",
            "createdAt"      to Timestamp.now(),
            "expiresAt"      to Timestamp(Date(expiry)),
            "contactCount"   to 0,
            "reportCount"    to 0,
            "searchKeywords" to keywords
        )

        // ── 6. معاملة Firestore (تحقق من التكرار + كتابة) ────────────
        val cutoff = Timestamp(Date(now - 24L * 60 * 60 * 1000))
        try {
            val success = withTimeout(30_000) {
                FirebaseFirestore.getInstance().runTransaction { tx ->
                    val existing = tx.get(
                        postsRef
                            .whereEqualTo("userId", currentUserId)
                            .whereEqualTo("type", type)
                            .whereEqualTo("title", title.trim())
                            .whereEqualTo("region", region)
                            .whereGreaterThan("createdAt", cutoff)
                    )
                    if (existing.documents.isNotEmpty()) return@runTransaction false
                    tx.set(postsRef.document(postId), post)
                    true
                }.await()
            }

            if (success == true) {
                showSuccess("تم النشر بنجاح! سيظهر منشورك خلال ثوانٍ")
                finish()
            } else {
                // [تحسين] حذف الصورة عند فشل المعاملة بسبب التكرار
                cleanupUploadedImage(storagePath)
                showError("نشرت هذا المنشور مسبقاً خلال آخر 24 ساعة")
            }

        } catch (e: Exception) {
            // [تحسين] حذف الصورة عند أي فشل في المعاملة
            cleanupUploadedImage(storagePath)
            val msg = when (e) {
                is TimeoutCancellationException -> "انتهت المهلة، حاول مرة أخرى"
                is FirebaseFirestoreException   -> "خطأ في الاتصال بقاعدة البيانات"
                else                            -> "حدث خطأ غير متوقع"
            }
            showError(msg)
            Log.e("Publish", "Transaction failed", e)
        } finally {
            isPublishing = false
            showLoading(false)
        }
    }
}

// [تحسين] دالة تنظيف الصورة المعزولة
private fun cleanupUploadedImage(storagePath: String?) {
    storagePath ?: return
    FirebaseStorage.getInstance()
        .getReference(storagePath)
        .delete()
        .addOnFailureListener { Log.w("Cleanup", "Image cleanup failed for: $storagePath", it) }
}
```

---

### 4.4 زر الاتصال وزيادة العداد

```kotlin
// في PostsViewModel أو PostsAdapter
private val phoneCache = mutableMapOf<String, String>()
private var lastContactClickTime = 0L
private val DEBOUNCE_MS = 2_000L

fun onContactClick(post: Post) {
    // حماية: لا اتصال بمنشور المستخدم نفسه
    if (post.userId == currentUserId) return

    // حماية: الزائر يُطلب منه تسجيل الدخول
    if (!isLoggedIn) { showLoginDialog(); return }

    // منع الضغط المتكرر
    val now = System.currentTimeMillis()
    if (now - lastContactClickTime < DEBOUNCE_MS) return
    lastContactClickTime = now

    getPhoneNumber(post.userId) { phone ->
        if (phone == null) {
            showError("لا يمكن الحصول على رقم التواصل")
            return@getPhoneNumber
        }

        AlertDialog.Builder(context)
            .setTitle("تواصل بشأن: ${post.title}")
            .setItems(arrayOf("📞  اتصال هاتفي", "💬  واتساب")) { _, which ->
                val intent = when (which) {
                    0 -> Intent(Intent.ACTION_DIAL, Uri.parse("tel:$phone"))
                    else -> Intent(Intent.ACTION_VIEW,
                        Uri.parse("https://api.whatsapp.com/send?phone=${phone.removePrefix("+")}"))
                }
                // [تحسين] التحقق من وجود تطبيق يستجيب قبل التشغيل
                if (intent.resolveActivity(context.packageManager) != null) {
                    context.startActivity(intent)
                    // زيادة العداد بعد نجاح فتح النية فقط
                    incrementContactCount(post.id)
                } else {
                    val msg = if (which == 1) "تطبيق واتساب غير مثبت" else "لا يوجد تطبيق اتصال"
                    showError(msg)
                }
            }
            .show()
    }
}

private fun getPhoneNumber(userId: String, callback: (String?) -> Unit) {
    // أولاً من الـ SharedPreferences إذا كان نفس المستخدم
    if (userId == currentUserId) {
        callback(sharedPrefs.getString("phoneNumber", null))
        return
    }
    // ثانياً من الكاش
    phoneCache[userId]?.let { callback(it); return }
    // أخيراً من Firestore
    viewModelScope.launch {
        try {
            val doc = withTimeout(10_000) { usersRef.document(userId).get().await() }
            val phone = doc.getString("phoneNumber")
            if (phone != null) phoneCache[userId] = phone
            callback(phone)
        } catch (e: Exception) {
            callback(null)
        }
    }
}

private fun incrementContactCount(postId: String) {
    postsRef.document(postId)
        .update("contactCount", FieldValue.increment(1))
        .addOnFailureListener { Log.e("Contact", "Increment failed for $postId", it) }
}
```

---

### 4.5 شاشة "حسابي" وإدارة المنشورات

```kotlin
// جلب منشورات المستخدم
fun loadMyPosts() {
    viewModelScope.launch {
        try {
            val snapshots = withTimeout(30_000) {
                postsRef
                    .whereEqualTo("userId", currentUserId)
                    .orderBy("createdAt", Direction.DESCENDING)
                    .get().await()
            }
            _myPosts.value = snapshots.toObjects(Post::class.java)
        } catch (e: Exception) {
            showError("فشل تحميل منشوراتك")
            Log.e("MyPosts", "Load failed", e)
        }
    }
}

// حساب الأيام المتبقية
fun daysRemaining(expiresAt: Timestamp): Int {
    val diff = expiresAt.toDate().time - System.currentTimeMillis()
    return ceil(diff / (24.0 * 60 * 60 * 1000)).toInt().coerceAtLeast(0)
}

// تجديد منشور
fun renewPost(post: Post) {
    if (daysRemaining(post.expiresAt) > 2) {
        showError("لا يمكن التجديد الآن، يتبقى أكثر من يومين")
        return
    }
    if (post.status != "active") {
        showError("لا يمكن تجديد منشور غير نشط")
        return
    }

    val newExpiry = Timestamp(Date(System.currentTimeMillis() + 15L * 24 * 60 * 60 * 1000))
    viewModelScope.launch {
        try {
            // [تحسين] استخدام withRetry للعمليات الحرجة
            withRetry(times = 2) {
                withTimeout(30_000) {
                    postsRef.document(post.id)
                        .update("expiresAt", newExpiry)
                        .await()
                }
            }
            // تحديث محلي فوري
            _myPosts.value = _myPosts.value?.map {
                if (it.id == post.id) it.copy(expiresAt = newExpiry) else it
            }
            showSuccess("تم التجديد بنجاح، يسري حتى ${formatDate(newExpiry)}")
        } catch (e: Exception) {
            showError("فشل التجديد، حاول مرة أخرى")
        }
    }
}

// إنهاء الطلب مع طلب التقييم
fun completePost(postId: String, context: Context) {
    viewModelScope.launch {
        try {
            withTimeout(30_000) {
                postsRef.document(postId).update("status", "completed").await()
            }
            // تحديث محلي
            _myPosts.value = _myPosts.value?.map {
                if (it.id == postId) it.copy(status = "completed") else it
            }
            // عرض مربع حوار التقييم
            showRatingDialog(context)
        } catch (e: Exception) {
            showError("فشل إنهاء الطلب")
        }
    }
}

fun showRatingDialog(context: Context) {
    AlertDialog.Builder(context)
        .setTitle("🎉 شكراً لاستخدامك بخدمتك!")
        .setMessage("هل أعجبك التطبيق؟ تقييمك يساعدنا على التحسين")
        .setPositiveButton("⭐ تقييم الآن") { _, _ -> openMarket(context) }
        .setNeutralButton("لاحقاً", null)
        .setNegativeButton("لا، شكراً", null)
        .show()
}

// حذف منشور مع حذف الصورة
fun deletePost(post: Post, context: Context) {
    AlertDialog.Builder(context)
        .setTitle("تأكيد الحذف")
        .setMessage("هل تريد حذف \"${post.title}\" نهائياً؟")
        .setPositiveButton("حذف") { _, _ ->
            viewModelScope.launch {
                try {
                    // [تحسين] حذف الصورة أولاً ثم المنشور
                    // إذا فشل حذف الصورة لا نوقف عملية حذف المنشور
                    post.storagePath?.let { path ->
                        FirebaseStorage.getInstance().getReference(path)
                            .delete()
                            .addOnFailureListener {
                                Log.w("Delete", "Image delete failed: $path", it)
                            }
                    }
                    withTimeout(30_000) {
                        postsRef.document(post.id).delete().await()
                    }
                    _myPosts.value = _myPosts.value?.filter { it.id != post.id }
                    showSuccess("تم حذف المنشور")
                } catch (e: Exception) {
                    showError("فشل الحذف، حاول مرة أخرى")
                }
            }
        }
        .setNegativeButton("إلغاء", null)
        .show()
}
```

---

### 4.6 التبليغ عن منشور

```kotlin
fun reportPost(post: Post) {
    // حماية: لا تبليغ على المنشور الخاص
    if (post.userId == currentUserId) return
    if (!isLoggedIn) { showLoginDialog(); return }

    // [تحسين] معرّف التبليغ: postId_userId (ليس userId_postId لمطابقة قواعد الأمان)
    val reportId  = "${post.id}_${currentUserId}"
    val reportRef = firestore.collection("reports").document(reportId)

    viewModelScope.launch {
        try {
            val exists = withTimeout(10_000) { reportRef.get().await() }.exists()
            if (exists) {
                showError("لقد بلّغت عن هذا المنشور مسبقاً")
                return@launch
            }

            // عرض مربع حوار التأكيد
            withContext(Dispatchers.Main) {
                AlertDialog.Builder(context)
                    .setTitle("تبليغ عن منشور")
                    .setMessage("هل أنت متأكد من تبليغ هذا المنشور كمحتوى مخالف؟")
                    .setPositiveButton("تبليغ") { _, _ ->
                        viewModelScope.launch {
                            try {
                                val batch = firestore.batch()
                                batch.update(
                                    postsRef.document(post.id),
                                    "reportCount", FieldValue.increment(1)
                                )
                                batch.set(reportRef, mapOf(
                                    "postId"     to post.id,
                                    "reporterId" to currentUserId,
                                    "reportedAt" to FieldValue.serverTimestamp()
                                ))
                                withTimeout(30_000) { batch.commit().await() }
                                showSuccess("شكراً، تم التبليغ وسنراجعه قريباً")

                                // [تحسين] إخفاء المنشور تلقائياً إذا تجاوز حد التبليغات
                                if ((post.reportCount + 1) >= REPORT_THRESHOLD) {
                                    _posts.value = _posts.value?.filter { it.id != post.id }
                                }
                            } catch (e: Exception) {
                                showError("فشل التبليغ، حاول مرة أخرى")
                            }
                        }
                    }
                    .setNegativeButton("إلغاء", null)
                    .show()
            }
        } catch (e: Exception) {
            showError("فشل التحقق، حاول مرة أخرى")
        }
    }
}

// حد التبليغات لإخفاء المنشور محلياً (قابل للضبط)
private val REPORT_THRESHOLD = 5
```

---

### 4.7 مشاركة المنشور

```kotlin
fun sharePost(post: Post, context: Context) {
    val priceText = if (post.type == "offer" && post.price != null) {
        val symbol = if (post.currency == "SYP") "ل.س" else "$"
        "\n💰 السعر: ${formatPrice(post.price)} $symbol"
    } else ""

    val typeLabel = if (post.type == "request") "🔍 طلب" else "🛍️ عرض"

    val shareBody = """
        $typeLabel: ${post.title}
        ${post.details?.take(150)?.let { if (it.length == 150) "$it..." else it } ?: ""}$priceText
        📍 المنطقة: ${post.region}
        
        تم النشر في تطبيق "بخدمتك"
        📲 حمّل التطبيق: ${getMarketLink()}
    """.trimIndent()

    val intent = Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"
        putExtra(Intent.EXTRA_SUBJECT, post.title)
        putExtra(Intent.EXTRA_TEXT, shareBody)
    }
    context.startActivity(Intent.createChooser(intent, "مشاركة عبر"))
}

// [تحسين] تنسيق السعر بفواصل (مثل: 1,500,000)
fun formatPrice(price: Double): String =
    NumberFormat.getNumberInstance(Locale("ar")).format(price.toLong())

fun getMarketLink() = "https://play.google.com/store/apps/details?id=com.bkhedmtak"
```

---

### 4.8 الحذف التلقائي للمنشورات (Cloud Function)

```javascript
// functions/index.js  (Node.js 18+, Firebase Functions v2)
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

        // ── 1. جلب المنشورات المنتهية ─────────────────────────────────
        const expired = await db.collection("posts")
            .where("expiresAt", "<", now)
            .where("status", "==", "active") // [تحسين] فقط النشطة
            .get();

        if (expired.empty) {
            logger.info("No expired posts found.");
            return;
        }

        logger.info(`Found ${expired.size} expired posts to delete.`);

        // ── 2. حذف الصور من Storage ───────────────────────────────────
        const imageDeletePromises = expired.docs.map(async (doc) => {
            const post = doc.data();
            // [تحسين] الاعتماد فقط على storagePath وليس استخراجه من imageUrl
            if (!post.storagePath) {
                if (post.imageUrl) {
                    logger.warn(`Post ${doc.id} has imageUrl but no storagePath – skipping image deletion.`);
                }
                return;
            }
            try {
                await bucket.file(post.storagePath).delete();
                logger.info(`Deleted image: ${post.storagePath}`);
            } catch (err) {
                // [تحسين] لا نوقف العملية بسبب فشل حذف صورة واحدة
                logger.warn(`Failed to delete image ${post.storagePath}: ${err.message}`);
            }
        });

        await Promise.allSettled(imageDeletePromises); // allSettled لا all

        // ── 3. حذف تقارير المنشورات المحذوفة ──────────────────────────
        // [جديد] حذف reports المرتبطة لتنظيف كامل
        const expiredIds = expired.docs.map(d => d.id);
        // Firestore لا يدعم whereIn بأكثر من 30 عنصراً في كل استعلام
        const chunks = [];
        for (let i = 0; i < expiredIds.length; i += 30) {
            chunks.push(expiredIds.slice(i, i + 30));
        }
        for (const chunk of chunks) {
            const reports = await db.collection("reports")
                .where("postId", "in", chunk)
                .get();
            const reportBatch = db.batch();
            reports.docs.forEach(r => reportBatch.delete(r.ref));
            if (!reports.empty) await reportBatch.commit();
        }

        // ── 4. حذف وثائق المنشورات على دفعات (500 كحد أقصى) ─────────
        const BATCH_SIZE = 400; // هامش أمان
        let   batch      = db.batch();
        let   count      = 0;
        const batchCommits = [];

        expired.docs.forEach((doc) => {
            batch.delete(doc.ref);
            count++;
            if (count === BATCH_SIZE) {
                batchCommits.push(batch.commit());
                batch = db.batch();
                count = 0;
            }
        });
        if (count > 0) batchCommits.push(batch.commit());

        await Promise.all(batchCommits);
        logger.info(`Successfully deleted ${expired.size} expired posts and their images/reports.`);
    }
);
```

---

### 4.9 [جديد] آلية إعادة المحاولة (Retry with Exponential Backoff)

```kotlin
/**
 * تنفيذ كتلة معلقة مع إعادة المحاولة عند الفشل.
 * مناسبة للعمليات الحرجة: النشر، التجديد.
 *
 * @param times   عدد المحاولات الكلي (افتراضي 2)
 * @param initialDelay  التأخير الأولي بالملي ثانية (افتراضي 1000)
 * @param block   الكتلة التي يُعاد تنفيذها
 */
suspend fun <T> withRetry(
    times: Int = 2,
    initialDelay: Long = 1_000,
    block: suspend () -> T
): T {
    var currentDelay = initialDelay
    repeat(times - 1) { attempt ->
        try {
            return block()
        } catch (e: Exception) {
            if (e is TimeoutCancellationException || e is FirebaseFirestoreException) {
                Log.w("Retry", "Attempt ${attempt + 1} failed, retrying in ${currentDelay}ms", e)
                delay(currentDelay)
                currentDelay *= 2 // exponential backoff
            } else {
                throw e // لا نعيد المحاولة لأخطاء غير شبكية
            }
        }
    }
    return block() // المحاولة الأخيرة بدون try
}

// الاستخدام:
withRetry(times = 2) {
    withTimeout(30_000) { postsRef.document(postId).update("expiresAt", newExpiry).await() }
}
```

---

### 4.10 [جديد] بناء الكلمات المفتاحية المحسّن

```kotlin
/**
 * تطبيع النص العربي:
 * - تحويل للأحرف الصغيرة
 * - حذف التشكيل
 * - توحيد الألف والهاء
 * - [جديد] حذف "ال" من بداية كل كلمة (أساسي لتحسين البحث)
 */
fun normalizeWord(word: String): String {
    return word
        .lowercase(Locale("ar"))
        .let { java.text.Normalizer.normalize(it, java.text.Normalizer.Form.NFD) }
        .replace(Regex("[ًٌٍَُِّْ]"), "")  // حذف التشكيل
        .replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")
        .replace("ة", "ه")
        .replace(Regex("^ال"), "")           // [جديد] حذف "ال" من بداية كل كلمة
        .trim()
}

/**
 * بناء قائمة الكلمات المفتاحية للمنشور.
 * تشمل: كلمات العنوان + التفاصيل + المنطقة.
 * [تحسين] تطبيق التطبيع على كل كلمة منفردة، وليس على النص كاملة.
 */
fun buildSearchKeywords(title: String, details: String?, region: String): List<String> {
    val combined = "$title ${details ?: ""} $region"
    return combined
        .split(Regex("\\s+"))
        .map { it.trim() }
        .filter { it.length >= 2 }          // [تحسين] تجاهل الكلمات القصيرة جداً
        .map { normalizeWord(it) }
        .filter { it.isNotBlank() }
        .distinct()
}

/**
 * تطبيع نص البحث بنفس المنطق لضمان التطابق.
 * [مهم] يجب أن يكون متطابقاً تماماً مع normalizeWord
 */
fun normalizeSearchQuery(query: String): String {
    return query.split(Regex("\\s+"))
        .map { normalizeWord(it) }
        .filter { it.isNotBlank() }
        .firstOrNull() ?: "" // Firestore يدعم arrayContains بكلمة واحدة فقط
}
```

> **ملاحظة:** Firestore لا يدعم `arrayContainsAny` مع ترتيب وفلترة في نفس الاستعلام.  
> للبحث بكلمات متعددة مستقبلاً، انظر قسم [11 – توصيات ما بعد MVP](#11-توصيات-مستقبلية).

---

## 5. هيكل البيانات (Firestore)

### مجموعة `users`
| الحقل | النوع | الوصف |
|-------|------|-------|
| `phoneNumber` | string | رقم الهاتف الموثق |
| `userType` | string | ثابت `"user"` |
| `createdAt` | timestamp | وقت إنشاء الحساب |
| `lastLoginAt` | timestamp | [جديد] آخر دخول |

### مجموعة `posts`
| الحقل | النوع | الوصف |
|-------|------|-------|
| `id` | string | معرف المنشور |
| `userId` | string | معرف المستخدم |
| `type` | string | `"request"` أو `"offer"` |
| `title` | string | العنوان (حد 100 حرف) |
| `details` | string | التفاصيل (حد 500 حرف، اختياري) |
| `region` | string | المنطقة |
| `price` | number | السعر (للعروض، يمكن null) |
| `currency` | string | `"SYP"` أو `"USD"` |
| `imageUrl` | string | رابط الصورة (اختياري) |
| `storagePath` | string | **[إلزامي إن وُجدت صورة]** مسار Storage |
| `status` | string | `"active"` أو `"completed"` |
| `createdAt` | timestamp | وقت النشر |
| `expiresAt` | timestamp | وقت الانتهاء (15 يوماً) |
| `contactCount` | number | عداد الاتصالات |
| `reportCount` | number | عداد التبليغات |
| `searchKeywords` | array\<string\> | كلمات مفتاحية مطبّعة |

### مجموعة `reports`
| الحقل | النوع | الوصف |
|-------|------|-------|
| `postId` | string | معرف المنشور |
| `reporterId` | string | معرف المبلِّغ |
| `reportedAt` | timestamp | وقت التبليغ |

**معرف الوثيقة:** `{postId}_{reporterId}` (يضمن عدم التكرار على مستوى قاعدة البيانات)

> **[تحسين]** وثيقة `reports` لا تُحذف يدوياً – تُحذف تلقائياً بواسطة Cloud Function عند حذف المنشور الأصلي.

---

## 6. الفهارس المطلوبة (Firestore Indexes)

```json
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "type",      "order": "ASCENDING"  },
        { "fieldPath": "status",    "order": "ASCENDING"  },
        { "fieldPath": "expiresAt", "order": "ASCENDING"  },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "type",      "order": "ASCENDING"  },
        { "fieldPath": "status",    "order": "ASCENDING"  },
        { "fieldPath": "expiresAt", "order": "ASCENDING"  },
        { "fieldPath": "region",    "order": "ASCENDING"  },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "type",           "order": "ASCENDING"  },
        { "fieldPath": "status",         "order": "ASCENDING"  },
        { "fieldPath": "expiresAt",      "order": "ASCENDING"  },
        { "fieldPath": "searchKeywords", "arrayConfig": "CONTAINS" },
        { "fieldPath": "createdAt",      "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId",    "order": "ASCENDING"  },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId",    "order": "ASCENDING"  },
        { "fieldPath": "type",      "order": "ASCENDING"  },
        { "fieldPath": "title",     "order": "ASCENDING"  },
        { "fieldPath": "region",    "order": "ASCENDING"  },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "reports",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "postId", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

نشر الفهارس:
```bash
firebase deploy --only firestore:indexes
```

---

## 7. قواعد الأمان (Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── المنشورات ────────────────────────────────────────────────────
    match /posts/{postId} {
      // القراءة مسموحة للجميع (الزوار يتصفحون)
      allow read: if true;

      // الإنشاء: مستخدم مسجل، userId مطابق، status = active
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid
                    && request.resource.data.status == "active"
                    && request.resource.data.title.size() <= 100
                    && request.resource.data.keys().hasAll(["userId","type","title","region","status","createdAt","expiresAt"]);

      // التحديث:
      // - صاحب المنشور يمكنه تحديث أي حقل مسموح
      // - المستخدمون الآخرون: فقط contactCount أو reportCount
      allow update: if request.auth != null && (
          (resource.data.userId == request.auth.uid) ||
          (resource.data.userId != request.auth.uid &&
           request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(["contactCount", "reportCount"]))
      );

      // الحذف: صاحب المنشور فقط
      allow delete: if request.auth != null
                    && resource.data.userId == request.auth.uid;
    }

    // ── المستخدمون ───────────────────────────────────────────────────
    match /users/{userId} {
      // القراءة: مسموحة (يحتاجها الآخرون لجلب رقم الهاتف)
      allow read: if true;
      // الكتابة: المستخدم نفسه فقط
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // ── التبليغات ────────────────────────────────────────────────────
    match /reports/{reportId} {
      // [تحسين] التحقق من تنسيق المعرف: postId_userId
      allow create: if request.auth != null
                    && reportId == request.resource.data.postId + "_" + request.auth.uid
                    && request.resource.data.reporterId == request.auth.uid
                    && request.resource.data.keys().hasAll(["postId","reporterId","reportedAt"]);
      // لا قراءة ولا تعديل ولا حذف يدوي
      allow read, update, delete: if false;
    }
  }
}
```

---

## 8. معالجة الأخطاء وتحسين الأداء

### 8.1 مبادئ المعالجة
| المبدأ | التطبيق |
|--------|---------|
| مهلة 30 ثانية | جميع العمليات الشبكية الحرجة |
| مهلة 10 ثانية | العمليات الثانوية (جلب رقم، التحقق من التبليغ) |
| Debounce 300ms | البحث النصي لتجنب الاستعلامات الزائدة |
| Debounce 2000ms | زر الاتصال لمنع الضغط المتكرر |
| منع النشر المتكرر | `isPublishing` flag في ViewModel |
| تنظيف الصور | عند أي فشل بعد رفع الصورة |
| Retry مرتان | للعمليات الحرجة (نشر، تجديد) مع exponential backoff |
| Cache | رقم الهاتف في `phoneCache` + `SharedPreferences` |
| requestId | إلغاء نتائج الاستعلامات القديمة عند تغيير الفلتر |

### 8.2 حجم الصور ومعالجتها
```kotlin
fun compressImage(uri: Uri, maxSizeKB: Int = 300): Uri {
    val bitmap = MediaStore.Images.Media.getBitmap(contentResolver, uri)
    // تصغير إذا كانت أبعادها كبيرة جداً
    val scaled = if (bitmap.width > 1080) {
        val ratio = 1080.0 / bitmap.width
        Bitmap.createScaledBitmap(bitmap, 1080, (bitmap.height * ratio).toInt(), true)
    } else bitmap

    var quality = 90
    var output: ByteArray
    do {
        val stream = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        output = stream.toByteArray()
        quality -= 10
    } while (output.size > maxSizeKB * 1024 && quality > 30)

    val tempFile = File(cacheDir, "compressed_${System.currentTimeMillis()}.jpg")
    tempFile.writeBytes(output)
    return Uri.fromFile(tempFile)
}
```

### 8.3 حالات التحميل (LoadingState)
```kotlin
sealed class LoadingState {
    object LOADING : LoadingState()
    object SUCCESS : LoadingState()
    data class ERROR(val message: String) : LoadingState()
}
```

---

## 9. اختبار حالة السباق (Race Condition)

**السيناريو:** مستخدم يضغط "نشر" مرتين متتاليتين بسرعة (أو من جهازين).

**الحماية الأولى:** `isPublishing = true` يمنع إرسال طلب ثانٍ من نفس الجهاز.  
**الحماية الثانية:** معاملة Firestore تضمن أن طلباً واحداً فقط يُكتب حتى عند التزامن.

### اختبار وحدة (Unit Test)
```kotlin
@Test
fun testDuplicatePostPrevention() = runTest {
    val db     = FirebaseFirestore.getInstance() // emulator
    val userId = "testUser"
    val postData = mapOf(
        "type" to "request", "title" to "مساعد", "region" to "دمشق"
    )

    // تشغيل طلبين متزامنين
    val result1 = async { createPostWithTransaction(userId, postData) }
    val result2 = async { createPostWithTransaction(userId, postData) }
    val results = awaitAll(result1, result2)

    // يجب أن ينجح طلب واحد فقط
    assertEquals(1, results.count { it == true })

    // التحقق من عدد المستندات في Firestore
    val posts = db.collection("posts")
        .whereEqualTo("userId", userId)
        .get().await()
    assertEquals(1, posts.size())
}
```

### اختبار تكامل Cloud Function
```javascript
// test/deleteExpired.test.js
it("should delete expired posts and their images", async () => {
    // إضافة منشور منتهي الصلاحية
    await db.collection("posts").doc("expired1").set({
        expiresAt: admin.firestore.Timestamp.fromDate(new Date("2020-01-01")),
        status: "active",
        storagePath: "posts/expired1/image.jpg"
    });
    // تشغيل الدالة
    await deleteExpiredPosts();
    // التحقق من الحذف
    const doc = await db.collection("posts").doc("expired1").get();
    expect(doc.exists).toBe(false);
});
```

---

## 10. سجل التغييرات (ما الجديد في v2.0)

| # | التغيير | الأثر |
|---|---------|-------|
| 1 | **حذف الصورة عند فشل المعاملة** | منع تراكم ملفات يتيمة في Storage |
| 2 | **`storagePath` إلزامي عند وجود صورة** | ضمان نظافة Storage دائماً |
| 3 | **حذف "ال" من كل كلمة (أساسي)** | تحسين دقة البحث العربي |
| 4 | **Cloud Function تعتمد فقط على `storagePath`** | لا استخراج هش من `imageUrl` |
| 5 | **`withRetry` للعمليات الحرجة** | مقاومة انقطاع الشبكة |
| 6 | **فلتر `status = active` في القائمة الرئيسية** | لا تظهر المنشورات المكتملة |
| 7 | **التحقق من وجود تطبيق قبل فتح النية** | لا crash عند غياب واتساب |
| 8 | **زيادة العداد بعد نجاح فتح النية** | دقة أعلى في الإحصاء |
| 9 | **حذف `reports` عند حذف المنشور** | تنظيف كامل للبيانات |
| 10 | **تمييز أنواع الأخطاء في AuthException** | رسائل واضحة للمستخدم |
| 11 | **`lastLoginAt` في مجموعة users** | بيانات تحليلية مفيدة |
| 12 | **حد أقصى للعنوان والتفاصيل** | منع الإدخال المفرط |
| 13 | **مربع تأكيد قبل الحذف** | حماية من الحذف الخاطئ |
| 14 | **فهرس `reports` على `postId`** | أداء حذف التبليغات في Cloud Function |
| 15 | **`allSettled` بدل `all` في Cloud Function** | لا توقف عند فشل حذف صورة واحدة |

---

## 11. توصيات ما بعد MVP

### قريبة المدى (الإصدار 1.1)
- **إشعارات Push (FCM):** تنبيه صاحب المنشور عند كل اتصال جديد.
- **صفحة تفاصيل المنشور:** عرض الصورة كاملة والتفاصيل في شاشة منفردة.
- **تقرير المشرف:** لوحة تحكم بسيطة لمراجعة التبليغات.
- **تحسين ضغط الصور:** WebP بدلاً من JPEG.

### متوسطة المدى (الإصدار 1.2 – 2.0)
- **بحث متعدد الكلمات:** استخدام Algolia أو Typesense لتجاوز قيود `arrayContains`.
- **حظر المستخدمين:** قائمة `blockedUsers` في مستند المستخدم.
- **المفضلة:** مجموعة `favorites` لحفظ المنشورات.
- **التحقق من رقم الهاتف ثنائياً:** OTP عند تغيير بيانات حساسة.

### بعيدة المدى
- **دعم iOS:** Flutter أو React Native.
- **وضع داكن وتوطين:** دعم لغة إنجليزية وكردية.
- **تحليلات:** Firebase Analytics + Crashlytics.
- **نظام تقييم الأطراف:** تقييم مزدوج بعد إتمام الصفقة.

---

## ✅ خلاصة التنفيذ

```
الأولوية 1: الفهارس + قواعد الأمان (قبل أي اختبار)
     ↓
الأولوية 2: تسجيل الدخول + القوائم + البحث
     ↓
الأولوية 3: النشر + الاتصال + شاشة حسابي
     ↓
الأولوية 4: التبليغ + المشاركة
     ↓
الأولوية 5: Cloud Function (الحذف التلقائي)
     ↓
الأولوية 6: الاختبارات + مراجعة قواعد الأمان النهائية
```

---

*الإصدار: 2.0 | التاريخ: 2026-05-28*  
*يغطي: MVP الكامل + 15 تحسيناً على النسخة الأصلية*  
*الحالة: ✅ جاهز للتطوير الفوري*
