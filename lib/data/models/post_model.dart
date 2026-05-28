import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType   { request, offer }
enum PostStatus { active, completed }

class PostModel {
  final String      id;
  final String      userId;
  final PostType    type;
  final String      title;
  final String?     details;
  final String      region;
  final double?     price;
  final String?     currency;
  final String?     imageUrl;
  final String?     storagePath;   // إلزامي إن وُجدت صورة
  final PostStatus  status;
  final Timestamp   createdAt;
  final Timestamp   expiresAt;
  final int         contactCount;
  final int         reportCount;
  final List<String> searchKeywords;

  const PostModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.details,
    required this.region,
    this.price,
    this.currency,
    this.imageUrl,
    this.storagePath,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.contactCount = 0,
    this.reportCount  = 0,
    this.searchKeywords = const [],
  });

  // ── من Firestore ──────────────────────────────────────────────────────
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PostModel(
      id:             doc.id,
      userId:         d['userId']       ?? '',
      type:           d['type'] == 'offer' ? PostType.offer : PostType.request,
      title:          d['title']        ?? '',
      details:        d['details'],
      region:         d['region']       ?? '',
      price:          (d['price'] as num?)?.toDouble(),
      currency:       d['currency'],
      imageUrl:       d['imageUrl'],
      storagePath:    d['storagePath'],
      status:         d['status'] == 'completed' ? PostStatus.completed : PostStatus.active,
      createdAt:      d['createdAt']    ?? Timestamp.now(),
      expiresAt:      d['expiresAt']    ?? Timestamp.now(),
      contactCount:   (d['contactCount'] as num?)?.toInt() ?? 0,
      reportCount:    (d['reportCount']  as num?)?.toInt() ?? 0,
      searchKeywords: List<String>.from(d['searchKeywords'] ?? []),
    );
  }

  // ── إلى Firestore ──────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'userId':         userId,
    'type':           type == PostType.offer ? 'offer' : 'request',
    'title':          title,
    'details':        details,
    'region':         region,
    'price':          price,
    'currency':       currency,
    'imageUrl':       imageUrl,
    'storagePath':    storagePath,
    'status':         status == PostStatus.completed ? 'completed' : 'active',
    'createdAt':      createdAt,
    'expiresAt':      expiresAt,
    'contactCount':   contactCount,
    'reportCount':    reportCount,
    'searchKeywords': searchKeywords,
  };

  // ── نسخة معدّلة ────────────────────────────────────────────────────────
  PostModel copyWith({
    PostStatus? status,
    Timestamp?  expiresAt,
    int?        contactCount,
    int?        reportCount,
  }) => PostModel(
    id:             id,
    userId:         userId,
    type:           type,
    title:          title,
    details:        details,
    region:         region,
    price:          price,
    currency:       currency,
    imageUrl:       imageUrl,
    storagePath:    storagePath,
    status:         status         ?? this.status,
    createdAt:      createdAt,
    expiresAt:      expiresAt      ?? this.expiresAt,
    contactCount:   contactCount   ?? this.contactCount,
    reportCount:    reportCount    ?? this.reportCount,
    searchKeywords: searchKeywords,
  );

  // ── مساعدات ────────────────────────────────────────────────────────────
  bool get isOffer   => type == PostType.offer;
  bool get isRequest => type == PostType.request;
  bool get isActive  => status == PostStatus.active;

  /// الأيام المتبقية (0 إذا انتهت)
  int get daysRemaining {
    final diff = expiresAt.toDate().difference(DateTime.now());
    return diff.inDays.clamp(0, 999);
  }

  /// هل يمكن التجديد (يومان أو أقل)
  bool get canRenew => isActive && daysRemaining <= 2;

  String get typeLabel   => isOffer ? 'عرض' : 'طلب';
  String get statusLabel => isActive ? 'نشط' : 'مكتمل';
}
