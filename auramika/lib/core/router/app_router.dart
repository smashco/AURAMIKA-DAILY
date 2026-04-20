import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/style_vibe_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/stylist/presentation/screens/stylist_screen.dart';
import '../../features/vendor/presentation/screens/vendor_screen.dart';
import '../../shared/widgets/main_wrapper.dart';

// ── Route Path Constants ──────────────────────────────────────────────────────
abstract class AppRoutes {
  // Shell branches (bottom nav tabs)
  static const String home    = '/';
  static const String vendor  = '/vendor';
  static const String stylist = '/stylist';
  static const String cart    = '/cart';
  static const String profile = '/profile';

  // Nested routes
  static const String productDetail    = '/product/:id';
  static const String vendorDetail     = '/vendor/:vendorId';
  static const String checkout         = '/cart/checkout';
  static const String orderConfirmation = '/cart/confirmation';
  static const String search           = '/search';
  static const String styleVibe        = '/vibe/:vibe';

  // Helper to build concrete paths
  static String product(String id)       => '/product/$id';
  static String vendorById(String id)    => '/vendor/$id';
}

// ── Router Provider ───────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) => _buildRouter());

// ── Router Builder ────────────────────────────────────────────────────────────
GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
    routes: [
      // ── StatefulShellRoute — Main Shell with Bottom Nav ──────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainWrapper(navigationShell: navigationShell),
        branches: [

          // ── Branch 0: Home ───────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) =>
                    _buildPage(state: state, child: const HomeScreen()),
                routes: [
                  GoRoute(
                    path: 'vibe/:vibe',
                    name: 'styleVibe',
                    pageBuilder: (context, state) => _buildPage(
                      state: state,
                      child: StyleVibeScreen(
                        vibeId: state.pathParameters['vibe'] ?? 'old_money',
                      ),
                    ),
                  ),
                  // ── Product Detail (from Home) ───────────────────────────
                  GoRoute(
                    path: 'product/:id',
                    name: 'productDetailFromHome',
                    pageBuilder: (context, state) => _buildPage(
                      state: state,
                      child: ProductDetailScreen(
                        productId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 1: Vendor / Shop ──────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.vendor,
                name: 'vendor',
                pageBuilder: (context, state) =>
                    _buildPage(state: state, child: const VendorScreen()),
                routes: [
                  // ── Vendor Detail ────────────────────────────────────────
                  GoRoute(
                    path: ':vendorId',
                    name: 'vendorDetail',
                    pageBuilder: (context, state) => _buildPage(
                      state: state,
                      child: VendorScreen(
                        vendorId: state.pathParameters['vendorId'],
                      ),
                    ),
                  ),
                  // ── Product Detail (from Vendor) ─────────────────────────
                  GoRoute(
                    path: 'product/:id',
                    name: 'productDetailFromVendor',
                    pageBuilder: (context, state) => _buildPage(
                      state: state,
                      child: ProductDetailScreen(
                        productId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 2: AI Stylist / Magic Mirror ──────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stylist,
                name: 'stylist',
                pageBuilder: (context, state) =>
                    _buildPage(state: state, child: const StylistScreen()),
              ),
            ],
          ),

          // ── Branch 3: Cart ───────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                name: 'cart',
                pageBuilder: (context, state) =>
                    _buildPage(state: state, child: const CartScreen()),
                routes: [
                  // ── Checkout ─────────────────────────────────────────────
                  GoRoute(
                    path: 'checkout',
                    name: 'checkout',
                    pageBuilder: (context, state) =>
                        _buildPage(state: state, child: const CheckoutScreen()),
                  ),
                  // ── Order Confirmation ────────────────────────────────────
                  GoRoute(
                    path: 'confirmation',
                    name: 'orderConfirmation',
                    pageBuilder: (context, state) => _buildPage(
                      state: state,
                      child: const OrderConfirmationScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 4: Profile ────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) =>
                    _buildPage(state: state, child: const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),

      // ── Top-level product route (for deep links / push from anywhere) ────
      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: ProductDetailScreen(
            productId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
    ],
  );
}

// ── Page Builder Helper ───────────────────────────────────────────────────────
CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}

// ── Error Screen ──────────────────────────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFD4AF37)),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A2F25)),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'The page you are looking for does not exist.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('GO HOME'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Placeholder Screen ────────────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF5),
        elevation: 0,
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            letterSpacing: 2.0, color: Color(0xFF1A2F25),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_rounded, size: 48, color: Color(0xFFD4AF37)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A2F25))),
          ],
        ),
      ),
    );
  }
}
