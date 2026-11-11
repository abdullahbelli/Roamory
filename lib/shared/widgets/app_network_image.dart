import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';

/// Uzak URL ve imzalı Supabase Storage görsellerini önbellekli ve güvenli gösterir.
///
/// Görsel adresi boşsa veya yükleme başarısız olursa uygulamanın tasarım diline
/// uygun sade bir yer tutucu kutu gösterilir; kırık görsel hatası fırlatılmaz.
class AppNetworkImage extends StatelessWidget {
  /// Önbellekli ağ görseli oluşturur.
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.radiusMd,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.placeholderIcon = Icons.landscape_outlined,
  });

  /// Görüntülenecek görselin URL adresi (imzalı veya herkese açık).
  final String? imageUrl;

  /// Görsel genişliği.
  final double? width;

  /// Görsel yüksekliği.
  final double? height;

  /// Köşe yuvarlaklığı.
  final double borderRadius;

  /// Görsel sığdırma modu.
  final BoxFit fit;

  /// Ekran okuyucular için erişilebilirlik etiketi.
  final String? semanticLabel;

  /// Yükleme hatasında veya boş URL'de gösterilecek ikon.
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final url = imageUrl?.trim();

    Widget fallback() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: Icon(placeholderIcon, color: colors.textSecondary, size: 28),
      );
    }

    if (url == null || url.isEmpty) {
      return fallback();
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (_, _) => Container(
            width: width,
            height: height,
            color: colors.surfaceVariant,
          ),
          errorWidget: (_, _, _) => fallback(),
        ),
      ),
    );
  }
}
