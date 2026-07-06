enum ProductType {
  coins,
  diamonds,
  bundle,
  vip,
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final ProductType type;
  final int coinAmount;
  final int diamondAmount;
  final double price;
  final String discountLabel;
  final String badge; // 'best_value', 'most_popular', 'sale', 'limited'
  final bool isBestOffer;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.coinAmount,
    required this.diamondAmount,
    required this.price,
    this.discountLabel = '',
    this.badge = '',
    this.isBestOffer = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      type: ProductType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => ProductType.coins),
      coinAmount: json['coinAmount'] ?? 0,
      diamondAmount: json['diamondAmount'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      discountLabel: json['discountLabel'] ?? '',
      badge: json['badge'] ?? '',
      isBestOffer: json['isBestOffer'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'coinAmount': coinAmount,
      'diamondAmount': diamondAmount,
      'price': price,
      'discountLabel': discountLabel,
      'badge': badge,
      'isBestOffer': isBestOffer,
    };
  }
}

class PurchaseHistoryModel {
  final String id;
  final String productId;
  final double pricePaid;
  final String timestamp;

  PurchaseHistoryModel({
    required this.id,
    required this.productId,
    required this.pricePaid,
    required this.timestamp,
  });

  factory PurchaseHistoryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryModel(
      id: json['id'],
      productId: json['productId'],
      pricePaid: (json['pricePaid'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'pricePaid': pricePaid,
      'timestamp': timestamp,
    };
  }
}

class WalletModel {
  final int coins;
  final int diamonds;
  final int vipPoints;

  WalletModel({
    this.coins = 50000,
    this.diamonds = 150,
    this.vipPoints = 0,
  });

  WalletModel copyWith({
    int? coins,
    int? diamonds,
    int? vipPoints,
  }) {
    return WalletModel(
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      vipPoints: vipPoints ?? this.vipPoints,
    );
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      coins: json['coins'] ?? 50000,
      diamonds: json['diamonds'] ?? 150,
      vipPoints: json['vipPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'diamonds': diamonds,
      'vipPoints': vipPoints,
    };
  }
}
