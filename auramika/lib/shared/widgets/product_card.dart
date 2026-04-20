import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';

/// AURAMIKA Product Card
///
/// Design Language:
///   • 4:5 full-bleed image (editorial fashion ratio)
///   • Sharp 4px corners — "High End" minimalism
///   • Brand name in small caps (Outfit, spaced)
///   • Price in Playfair Display serif
///   • Material badge (Brass / Copper) — thin border tag
///   • Express delivery badge overlay
///   • Wishlist heart icon (top-right overlay)
///   • Subtle press scale animation
class ProductCard extends StatefulWidget {
  final String id;
  final String brandName;
  final String productName;
  final double price;
  final String? imageUrl;
  final String material; // 'Brass' | 'Copper'
  final bool isExpressAvailable;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final int animationIndex;

  const ProductCard({
    super.key,
    required this.id,
    required this.brandName,
    required this.productName,
    required this.price,
    this.imageUrl,
    this.material = 'Brass',
    this.isExpressAvailable = true,
    this.isWishlisted = false,
    this.onTap,
    this.onWishlistTap,
    this.animationIndex = 0,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late bool _wishlisted;

  @override
  void initState() {
    super.initState();
    _wishlisted = widget.isWishlisted;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppConstants.animFast,
        curve: Curves.easeOut,
        child: _buildCard(),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.animationIndex * 70))
        .fadeIn(duration: AppConstants.animNormal, curve: Curves.easeOut)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppConstants.animNormal,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image (4:5 ratio) ─────────────────────────────────────────
          _ProductImage(
            imageUrl: widget.imageUrl,
            material: widget.material,
            isExpressAvailable: widget.isExpressAvailable,
            isWishlisted: _wishlisted,
            onWishlistTap: () {
              setState(() => _wishlisted = !_wishlisted);
              widget.onWishlistTap?.call();
            },
          ),

          // ── Info ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingS + 2,
              AppConstants.paddingS,
              AppConstants.paddingS + 2,
              AppConstants.paddingXS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand name — small caps
                Text(
                  widget.brandName.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    letterSpacing: 1.8,
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Product name
                Text(
                  widget.productName,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price in Playfair serif
                    Text(
                      '₹${_formatPrice(widget.price)}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    // Material tag
                    _MaterialTag(material: widget.material),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.toInt().toString();
  }
}

// ── Product Image with Overlays ───────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String material;
  final bool isExpressAvailable;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;

  const _ProductImage({
    required this.imageUrl,
    required this.material,
    required this.isExpressAvailable,
    required this.isWishlisted,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image ──────────────────────────────────────────────────────
          imageUrl != null
              ? (imageUrl!.startsWith('assets')
                  ? Builder(
                      builder: (context) {
                        debugPrint('Building Asset Image: $imageUrl');
                        return Image.asset(
                          imageUrl!,
                          fit: BoxFit.cover,
                          cacheWidth: 600, // Optimize memory for grid
                          errorBuilder: (ctx, error, stackTrace) {
                            debugPrint('Error loading asset $imageUrl: $error');
                            return _ImagePlaceholder(material: material);
                          },
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _ImagePlaceholder(material: material),
                      errorWidget: (_, __, ___) =>
                          _ImagePlaceholder(material: material),
                    ))
              : _ImagePlaceholder(material: material),

          // ── Bottom gradient overlay ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),

          // ── Express badge (top-left) ───────────────────────────────────
          if (isExpressAvailable)
            Positioned(
              top: AppConstants.paddingS,
              left: AppConstants.paddingS,
              child: _ExpressBadge(),
            ),

          // ── Wishlist button (top-right) ────────────────────────────────
          Positioned(
            top: AppConstants.paddingXS,
            right: AppConstants.paddingXS,
            child: _WishlistButton(
              isWishlisted: isWishlisted,
              onTap: onWishlistTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image Placeholder ─────────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  final String material;
  const _ImagePlaceholder({required this.material});

  static Color _materialColor(String mat) {
    final m = mat.toLowerCase();
    if (m.contains('gold')) return AppColors.gold;
    if (m.contains('silver')) return const Color(0xFFC0C0C0);
    if (m.contains('rose')) return const Color(0xFFB76E79);
    if (m.contains('pearl')) return const Color(0xFFEAE0D5);
    if (m.contains('copper')) return AppColors.copper;
    if (m.contains('brass')) return AppColors.brass;
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    final color = _materialColor(material);
    return Container(
      color: color.withValues(alpha: 0.12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond_outlined, color: color, size: 36),
            const SizedBox(height: 6),
            Text(
              material.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Express Badge ─────────────────────────────────────────────────────────────
class _ExpressBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.forestGreen,
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 9, color: AppColors.gold),
          const SizedBox(width: 2),
          Text(
            '2 HRS',
            style: AppTextStyles.expressBadge.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// ── Wishlist Button ───────────────────────────────────────────────────────────
class _WishlistButton extends StatelessWidget {
  final bool isWishlisted;
  final VoidCallback onTap;

  const _WishlistButton({required this.isWishlisted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        ),
        child: Icon(
          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 16,
          color: isWishlisted ? AppColors.terraCotta : AppColors.textMuted,
        ),
      )
          .animate(target: isWishlisted ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            duration: AppConstants.animFast,
            curve: Curves.elasticOut,
          ),
    );
  }
}

// ── Material Tag ──────────────────────────────────────────────────────────────
class _MaterialTag extends StatelessWidget {
  final String material;
  const _MaterialTag({required this.material});

  static Color _materialColor(String mat) {
    final m = mat.toLowerCase();
    if (m.contains('gold')) return AppColors.gold;
    if (m.contains('silver')) return const Color(0xFFC0C0C0);
    if (m.contains('rose')) return const Color(0xFFB76E79);
    if (m.contains('pearl')) return const Color(0xFFEAE0D5);
    if (m.contains('copper')) return AppColors.copper;
    if (m.contains('brass')) return AppColors.brass;
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    final color = _materialColor(material);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6), width: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Text(
        material.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
