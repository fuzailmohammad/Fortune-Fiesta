enum JuiceEffectType {
  particle,
  shimmer,
  wiggle,
  rollingCoin,
  butterfly,
}

class JuiceParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  final double maxOpacity;
  final double speed;
  final int colorValue;

  JuiceParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.maxOpacity,
    required this.speed,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'vx': vx,
      'vy': vy,
      'size': size,
      'opacity': opacity,
      'maxOpacity': maxOpacity,
      'speed': speed,
      'colorValue': colorValue,
    };
  }

  factory JuiceParticle.fromJson(Map<String, dynamic> json) {
    return JuiceParticle(
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
      vx: (json['vx'] ?? 0.0).toDouble(),
      vy: (json['vy'] ?? 0.0).toDouble(),
      size: (json['size'] ?? 2.0).toDouble(),
      opacity: (json['opacity'] ?? 1.0).toDouble(),
      maxOpacity: (json['maxOpacity'] ?? 1.0).toDouble(),
      speed: (json['speed'] ?? 1.0).toDouble(),
      colorValue: json['colorValue'] ?? 0xFFFFFFFF,
    );
  }
}

class JuiceConfig {
  final int maxParticles;
  final bool batterySaver;
  final double scaleFactor;

  JuiceConfig({
    this.maxParticles = 50,
    this.batterySaver = false,
    this.scaleFactor = 1.0,
  });

  JuiceConfig copyWith({
    int? maxParticles,
    bool? batterySaver,
    double? scaleFactor,
  }) {
    return JuiceConfig(
      maxParticles: maxParticles ?? this.maxParticles,
      batterySaver: batterySaver ?? this.batterySaver,
      scaleFactor: scaleFactor ?? this.scaleFactor,
    );
  }

  factory JuiceConfig.fromJson(Map<String, dynamic> json) {
    return JuiceConfig(
      maxParticles: json['maxParticles'] ?? 50,
      batterySaver: json['batterySaver'] ?? false,
      scaleFactor: (json['scaleFactor'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxParticles': maxParticles,
      'batterySaver': batterySaver,
      'scaleFactor': scaleFactor,
    };
  }
}
