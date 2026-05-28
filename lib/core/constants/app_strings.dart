/// نصوص تطبيق "بخدمتك"
abstract class AppStrings {
  // ── عام ─────────────────────────────────────────────────────────────
  static const appName      = 'بخدمتك';
  static const appTagline   = 'خدماتك بين يديك';
  static const ok           = 'موافق';
  static const cancel       = 'إلغاء';
  static const confirm      = 'تأكيد';
  static const yes          = 'نعم';
  static const no           = 'لا';
  static const loading      = 'جارٍ التحميل…';
  static const retry        = 'إعادة المحاولة';
  static const save         = 'حفظ';
  static const close        = 'إغلاق';

  // ── المناطق الرئيسية الثلاث ──────────────────────────────────────────
  static const allRegions = 'جميع المناطق';
  static const regions = [
    'جميع المناطق',
    'السويداء',
    'صلخد',
    'شهبا',
  ];

  // ── العملات ─────────────────────────────────────────────────────────
  static const currencySYP = 'SYP';
  static const currencyUSD = 'USD';
  static const symbolSYP   = 'ل.س';
  static const symbolUSD   = r'$';

  // ── المصادقة ─────────────────────────────────────────────────────────
  static const enterPhone      = 'أدخل رقم هاتفك';
  static const phoneHint       = '+963 9XX XXX XXX';
  static const sendCode        = 'إرسال رمز التحقق';
  static const enterOtp        = 'أدخل رمز التحقق';
  static const resendCode      = 'إعادة الإرسال';
  static const browseAsGuest   = 'تصفح كزائر';
  static const login           = 'تسجيل الدخول';
  static const logout          = 'تسجيل الخروج';
  static const confirmLogout   = 'هل تريد تسجيل الخروج؟';
  static const loginRequired   = 'سجّل دخولك للمتابعة';

  // ── المنشورات ────────────────────────────────────────────────────────
  static const requests        = 'طلبات';
  static const offers          = 'عروض';
  static const addPost         = 'إضافة منشور';
  static const postTitle       = 'العنوان';
  static const postTitleHint   = 'مثال: مطلوب سباك متمرس…';
  static const postDetails     = 'التفاصيل (اختياري)';
  static const postRegion      = 'المنطقة الرئيسية';
  static const postLocation    = 'الموقع التفصيلي';
  static const postLocationHint= 'مثال: حي المطار، شارع الجلاء…';
  static const postPrice       = 'السعر';
  static const postCurrency    = 'العملة';
  static const postImage       = 'صورة توضيحية (اختياري)';
  static const typeRequest     = 'طلب';
  static const typeOffer       = 'عرض';
  static const publish         = 'نشر';
  static const publishing      = 'جارٍ النشر…';
  static const publishedOk     = '✅ تم نشر منشورك بنجاح';
  static const duplicatePost   = 'نشرت هذا المنشور خلال آخر 24 ساعة';
  static const renew           = 'تجديد';
  static const renewOk         = '✅ تم التجديد بنجاح';
  static const completePost    = 'إنهاء الطلب';
  static const delete          = 'حذف';
  static const noPostsYet      = 'لا توجد منشورات حالياً';
  static const noMyPosts       = 'لم تنشر أي منشور بعد';
  static const loadMore        = 'تحميل المزيد';
  static const expiresToday    = 'ينتهي اليوم';
  static const daysRemaining   = '%1d يوم متبقي';

  // ── التواصل ──────────────────────────────────────────────────────────
  static const callPhone       = '📞 اتصال هاتفي';
  static const whatsapp        = '💬 واتساب';
  static const noWhatsapp      = 'تطبيق واتساب غير مثبت';
  static const noPhone         = 'لا يوجد تطبيق اتصال';

  // ── التبليغ ──────────────────────────────────────────────────────────
  static const report          = 'تبليغ';
  static const reportConfirm   = 'هل أنت متأكد من تبليغ هذا المنشور كمحتوى مخالف؟';
  static const reportOk        = 'شكراً، تم التبليغ وسنراجعه قريباً';
  static const alreadyReported = 'لقد بلّغت عن هذا المنشور مسبقاً';

  // ── البحث ────────────────────────────────────────────────────────────
  static const searchHint      = 'ابحث في السويداء…';

  // ── التقييم ──────────────────────────────────────────────────────────
  static const ratingTitle     = 'شكراً لاستخدامك بخدمتك!';
  static const ratingMsg       = 'هل أعجبك التطبيق؟ تقييمك يساعدنا على التحسين';
  static const rateNow         = '⭐ تقييم الآن';
  static const rateLater       = 'لاحقاً';

  // ── الأخطاء ──────────────────────────────────────────────────────────
  static const errTitleRequired    = 'العنوان مطلوب';
  static const errTitleLong        = 'العنوان طويل جداً (100 حرف كحد أقصى)';
  static const errRegionRequired   = 'اختر منطقة رئيسية';
  static const errLocationRequired = 'الموقع التفصيلي مطلوب';
  static const errPriceRequired    = 'أدخل سعراً صحيحاً';
  static const errTimeout          = 'انتهت المهلة، تأكد من اتصالك بالإنترنت';
  static const errGeneric          = 'حدث خطأ، حاول مرة أخرى';
  static const errUploadImage      = 'فشل رفع الصورة';
  static const errNoPhone          = 'لا يمكن الحصول على رقم التواصل';
  static const errDetails500       = 'التفاصيل طويلة جداً (500 حرف كحد أقصى)';

  // ── المشاركة ─────────────────────────────────────────────────────────
  static const shareVia    = 'مشاركة عبر';
  static const shareFooter =
      'تم النشر في تطبيق "بخدمتك"'
      r' – حمّل التطبيق: https://play.google.com/store/apps/details?id=com.onyourrequest';

  // ── حسابي ────────────────────────────────────────────────────────────
  static const myAccount  = 'حسابي';
  static const myPosts    = 'منشوراتي';
  static const home       = 'الرئيسية';
  static const search     = 'بحث';
}
