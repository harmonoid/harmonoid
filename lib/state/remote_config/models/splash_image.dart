import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_image.freezed.dart';
part 'splash_image.g.dart';

@freezed
abstract class SplashImage with _$SplashImage {
  const factory SplashImage({
    required String url,
    required String fit,
    required String alignment,
    String? backgroundColor,
  }) = _SplashImage;

  factory SplashImage.fromJson(Map<String, dynamic> json) => _$SplashImageFromJson(json);
}
