# 🗺️ خارطة طريق تطبيق "بخدمتك"

## ✅ المرحلة 0 – البنية التحتية (مكتملة)
- [x] إنشاء الـ Repository على GitHub
- [x] الوثيقة التقنية الكاملة (`docs/TECHNICAL_SPEC.md`)
- [x] قواعد الأمان (`firebase/firestore.rules`)
- [x] الفهارس (`firebase/firestore.indexes.json`)
- [x] قواعد Storage (`firebase/storage.rules`)
- [x] Cloud Function الحذف التلقائي (`functions/src/index.js`)
- [x] `.gitignore` و `firebase.json`

---

## 🔲 المرحلة 1 – مشروع Android الأساسي
- [ ] إنشاء مشروع Android Studio (Kotlin + Jetpack)
- [ ] إضافة Firebase SDK (Auth, Firestore, Storage)
- [ ] هيكل المجلدات (ui / data / domain / utils)
- [ ] نماذج البيانات: `Post.kt`, `User.kt`, `Report.kt`
- [ ] `PostRepository.kt`, `UserRepository.kt`
- [ ] `LoadingState.kt` (sealed class)

---

## 🔲 المرحلة 2 – المصادقة (Auth)
- [ ] `WelcomeActivity` (تسجيل دخول / زائر)
- [ ] `PhoneAuthActivity` (إدخال رقم الهاتف)
- [ ] `OtpActivity` (إدخال رمز SMS)
- [ ] `AuthViewModel.kt`
- [ ] تخزين `userId` في `SharedPreferences`
- [ ] Cache رقم الهاتف

---

## 🔲 المرحلة 3 – الشاشة الرئيسية والقوائم
- [ ] `MainActivity` (BottomNavigation أو Tabs)
- [ ] `PostsFragment` (طلبات / عروض)
- [ ] `PostsViewModel.kt` (ترحيل + إلغاء استعلامات)
- [ ] `PostAdapter.kt`
- [ ] شريط البحث مع Debounce 300ms
- [ ] فلتر المنطقة (Spinner)
- [ ] تمييز حالة الزائر vs المسجل

---

## 🔲 المرحلة 4 – إضافة منشور
- [ ] `AddPostActivity`
- [ ] `AddPostViewModel.kt`
- [ ] رفع الصورة مع ضغط (300KB)
- [ ] معاملة Firestore (منع التكرار)
- [ ] تنظيف الصورة عند الفشل
- [ ] `buildSearchKeywords()` مع إزالة "ال"

---

## 🔲 المرحلة 5 – التواصل والتبليغ
- [ ] زر الاتصال (هاتف / واتساب) مع Debounce 2s
- [ ] التحقق من وجود التطبيق قبل فتح النية
- [ ] زيادة `contactCount` بعد نجاح فتح النية
- [ ] `reportPost()` مع منع التكرار
- [ ] زر المشاركة

---

## 🔲 المرحلة 6 – شاشة حسابي
- [ ] `MyAccountFragment`
- [ ] قائمة منشورات المستخدم
- [ ] تجديد (≤ يومان)
- [ ] إنهاء الطلب + حوار التقييم
- [ ] حذف المنشور + الصورة
- [ ] تسجيل الخروج

---

## 🔲 المرحلة 7 – Cloud Function والاختبار
- [ ] نشر `deleteExpiredPosts` على Firebase
- [ ] اختبار الحذف التلقائي بـ Emulator
- [ ] اختبار حالة السباق (Race Condition)
- [ ] مراجعة قواعد الأمان النهائية
- [ ] نشر الفهارس: `firebase deploy --only firestore:indexes`

---

## 🔲 المرحلة 8 – الإطلاق
- [ ] توقيع الـ APK (Signing Config)
- [ ] رفع الـ AAB على Google Play
- [ ] ربط Firebase Analytics + Crashlytics
- [ ] مراجعة الـ Firestore Rules قبل الإنتاج

---

## 🔮 ما بعد MVP (الإصدار 1.1+)
- [ ] إشعارات Push (FCM)
- [ ] صفحة تفاصيل المنشور
- [ ] بحث متعدد الكلمات (Algolia)
- [ ] حظر المستخدمين
- [ ] المفضلة
- [ ] دعم iOS (Flutter)
- [ ] وضع داكن
