/// أدوات معالجة النص العربي للبحث
class ArabicUtils {

  /// تطبيع كلمة واحدة:
  /// - حذف التشكيل
  /// - توحيد الألف والهاء
  /// - حذف "ال" التعريف من البداية
  static String normalizeWord(String word) {
    return word
        .toLowerCase()
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '')  // حذف التشكيل
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'^ال'), '')           // حذف "ال" التعريف
        .trim();
  }

  /// بناء قائمة الكلمات المفتاحية للمنشور
  static List<String> buildKeywords(String title, String? details, String region) {
    final combined = '$title ${details ?? ''} $region';
    return combined
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.length >= 2)
        .map(normalizeWord)
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
  }

  /// تطبيع نص البحث – يجب أن يطابق normalizeWord تماماً
  static String normalizeQuery(String query) {
    final words = query.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    return normalizeWord(words.first); // Firestore: arrayContains كلمة واحدة
  }

  /// تنسيق السعر بفواصل عربية
  static String formatPrice(double price) {
    final n = price.toInt();
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  /// تنسيق التاريخ النسبي
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes  < 1)  return 'الآن';
    if (diff.inMinutes  < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours    < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays     < 30) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${diff.inDays ~/ 30} شهر';
  }
}
