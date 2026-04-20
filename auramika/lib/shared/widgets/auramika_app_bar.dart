import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';

/// AURAMIKA Custom App Bar
///
/// Design:
///   • Centered "AURAMIKA" wordmark in Cinzel serif
///   • Transparent / cream background, zero elevation
///   • Thin stroke search + cart icons (right actions)
///   • Optional back button (left) for nested routes
///   • Subtle bottom border divider
///   • Cart badge counter support
class AuramikaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showSearch;
  final bool showCart;
  final bool showBack;
  final int cartCount;
  final List<Widget>? extraActions;
  final Color backgroundColor;
  final bool transparent;

  const AuramikaAppBar({
    super.key,
    this.title,
    this.showLogo = true,
    this.showSearch = true,
    this.showCart = true,
    this.showBack = false,
    this.cartCount = 0,
    this.extraActions,
    this.backgroundColor = AppColors.background,
    this.transparent = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        height: preferredSize.height + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: transparent ? Colors.transparent : backgroundColor,
          border: transparent
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: Back or spacer ────────────────────────────────────
              SizedBox(
                width: 80,
                child: showBack
                    ? _AppBarIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(),
                      )
                    : null,
              ),

              // ── Center: Logo or title ───────────────────────────────────
              Expanded(
                child: Center(
                  child: showLogo
                      ? Text(
                          AppConstants.appName,
                          style: AppTextStyles.brandLogo,
                        )
                            .animate()
                            .fadeIn(duration: AppConstants.animNormal)
                      : Text(
                          (title ?? '').toUpperCase(),
                          style: AppTextStyles.titleMedium.copyWith(
                            letterSpacing: 3.0,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),

              // ── Right: Actions ──────────────────────────────────────────
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (extraActions != null) ...extraActions!,
                    if (showSearch)
                      _AppBarIconButton(
                        icon: Icons.search_rounded,
                        onTap: () {
                          // Phase 3: navigate to search
                        },
                      ),
                    if (showCart)
                      _CartIconButton(count: cartCount),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── App Bar Icon Button ───────────────────────────────────────────────────────
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Cart Icon with Badge ──────────────────────────────────────────────────────
class _CartIconButton extends StatelessWidget {
  final int count;
  const _CartIconButton({required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.cart),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: AppConstants.animFast,
                      curve: Curves.elasticOut,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
