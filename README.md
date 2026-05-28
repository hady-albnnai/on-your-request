# 📱 بخدمتك – Bkhedmtak

> سوق محلي يربط مقدمي الخدمات والمنتجات بطالبيها.

## 🗂️ هيكل المشروع

```
on-your-request/
├── 📱 app/                    ← Android (Kotlin)
│   └── src/main/java/com/bkhedmtak/
│       ├── ui/                ← Fragments + Activities
│       │   ├── auth/          ← تسجيل الدخول
│       │   ├── posts/         ← القوائم والبحث
│       │   ├── add/           ← إضافة منشور
│       │   ├── myaccount/     ← حسابي
│       │   └── common/        ← مكونات مشتركة
│       ├── data/
│       │   ├── model/         ← Post, User, Report
│       │   ├── repository/    ← PostRepository, UserRepository
│       │   └── remote/        ← Firebase datasources
│       ├── domain/
│       │   └── usecase/       ← PublishPostUseCase, SearchPostsUseCase
│       └── utils/             ← Helpers, Extensions
├── ☁️ functions/              ← Cloud Functions (Node.js 18+)
│   └── src/index.js           ← deleteExpiredPosts
├── 🔐 firebase/
│   ├── firestore.rules        ← قواعد الأمان
│   ├── firestore.indexes.json ← الفهارس
│   └── storage.rules          ← قواعد Storage
├── 📚 docs/
│   └── TECHNICAL_SPEC.md      ← الوثيقة التقنية الكاملة
└── firebase.json
```

## ⚙️ التقنيات

| المكوّن | التقنية |
|--------|---------|
| الواجهة | Android (Kotlin) + Jetpack |
| المصادقة | Firebase Authentication (Phone) |
| قاعدة البيانات | Firestore |
| الملفات | Firebase Storage |
| المهام الجدولة | Cloud Functions (Node.js 18+) |

## 🚀 خطة التنفيذ

```
1️⃣  الفهارس + قواعد الأمان
2️⃣  تسجيل الدخول + القوائم + البحث
3️⃣  النشر + الاتصال + شاشة حسابي
4️⃣  التبليغ + المشاركة
5️⃣  Cloud Function (الحذف التلقائي)
6️⃣  الاختبارات + المراجعة النهائية
```

## 📚 الوثيقة التقنية

راجع [docs/TECHNICAL_SPEC.md](./docs/TECHNICAL_SPEC.md) للاطلاع على الخوارزميات التفصيلية وهيكل البيانات وقواعد الأمان والفهارس.

---
*الإصدار: MVP 1.0 | التاريخ: 2026-05-28*
