/// أدوات معالجة النص العربي للبحث
class ArabicUtils {

  /// تطبيع كلمة واحدة
  static String normalizeWord(String word) {
    return word
        .toLowerCase()
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'^ال'), '')
        .trim();
  }

  /// بناء قائمة الكلمات المفتاحية
  /// تشمل: العنوان + التفاصيل + الفئة + المنطقة + الموقع
  static List<String> buildKeywords(String title, String? details, String extra) {
    final combined = '$title ${details ?? ''} $extra';
    return combined
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.length >= 2)
        .map(normalizeWord)
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
  }

  /// تطبيع نص البحث - يعيد أول كلمة مطبّعة
  /// Firestore arrayContains يدعم كلمة واحدة فقط
  static String normalizeQuery(String query) {
    final words = query.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    return normalizeWord(words.first);
  }

  /// تطبيع نص البحث - يعيد كل الكلمات (للفلترة المحلية)
  static List<String> normalizeQueryAll(String query) {
    return query.trim().split(RegExp(r'\s+'))
        .map(normalizeWord)
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// تنسيق السعر بفواصل
  static String formatPrice(double price) {
    final n = price.toInt();
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  /// تنسيق الوقت النسبي
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes  < 1)  return 'الآن';
    if (diff.inMinutes  < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours    < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays     < 30) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${diff.inDays ~/ 30} شهر';
  }
}
