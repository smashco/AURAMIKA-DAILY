import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/rive_animation_widget.dart';
import '../controllers/cart_controller.dart';

// ── Checkout Screen ───────────────────────────────────────────────────────────
/// Address → Payment → Order Summary → Pay
/// On "Pay" → navigates to OrderConfirmationScreen
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Address
  final _nameCtrl    = TextEditingController(text: 'Priya Sharma');
  final _phoneCtrl   = TextEditingController(text: '9876543210');
  final _line1Ctrl   = TextEditingController(text: '42, Bandra West');
  final _cityCtrl    = TextEditingController(text: 'Mumbai');
  final _pinCtrl     = TextEditingController(text: '400050');

  // Payment
  _PaymentMethod _payment = _PaymentMethod.razorpay;

  bool _paying = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    
    // Clear cart before showing confirmation
    ref.read(cartProvider.notifier).clear();
    
    if (!mounted) return;
    context.pushReplacement(AppRoutes.orderConfirmation);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;
    
    // Get real cart data from provider
    final cart = ref.watch(cartProvider);
    final isExpress = cart.isAllExpress;
    final subtotal = cart.subtotal;
    final delivery = cart.deliveryFee;
    final total = cart.total;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: EdgeInsets.fromLTRB(
              AppConstants.paddingM, topPad + 8,
              AppConstants.paddingM, AppConstants.paddingM,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Text(
                    'CHECKOUT',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 11, letterSpacing: 3.0,
                    ),
                  ),
                ),
                if (isExpress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, size: 10, color: AppColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          '2 HRS',
                          style: AppTextStyles.expressBadge.copyWith(
                            color: AppColors.white, fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Address Section ──────────────────────────────────────
                  _SectionHeader(label: 'DELIVERY ADDRESS', icon: Icons.location_on_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _CheckoutField(controller: _nameCtrl,  label: 'FULL NAME',    hint: 'Priya Sharma',    icon: Icons.person_outline_rounded),
                  const SizedBox(height: AppConstants.paddingS),
                  _CheckoutField(controller: _phoneCtrl, label: 'PHONE',        hint: '9876543210',      icon: Icons.phone_outlined, inputType: TextInputType.phone, formatters: [FilteringTextInputFormatter.digitsOnly]),
                  const SizedBox(height: AppConstants.paddingS),
                  _CheckoutField(controller: _line1Ctrl, label: 'ADDRESS',      hint: 'Flat / Street',   icon: Icons.home_outlined),
                  const SizedBox(height: AppConstants.paddingS),
                  Row(
                    children: [
                      Expanded(child: _CheckoutField(controller: _cityCtrl, label: 'CITY', hint: 'Mumbai', icon: Icons.location_city_outlined)),
                      const SizedBox(width: AppConstants.paddingS),
                      SizedBox(
                        width: 110,
                        child: _CheckoutField(controller: _pinCtrl, label: 'PIN CODE', hint: '400050', icon: Icons.pin_outlined, inputType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly]),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Delivery Type ────────────────────────────────────────
                  _SectionHeader(label: 'DELIVERY TYPE', icon: Icons.local_shipping_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _DeliveryToggle(
                    isExpress: isExpress,
                    onChanged: (_) {}, // Delivery type is determined by cart items
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Payment Section ──────────────────────────────────────
                  _SectionHeader(label: 'PAYMENT METHOD', icon: Icons.payment_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _PaymentSelector(
                    selected: _payment,
                    onChanged: (v) => setState(() => _payment = v),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Order Summary ────────────────────────────────────────
                  _SectionHeader(label: 'ORDER SUMMARY', icon: Icons.receipt_long_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _CheckoutSummary(
                    subtotal: subtotal,
                    delivery: delivery,
                    total: total,
                    isExpress: isExpress,
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ── Pay Button ───────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: EdgeInsets.fromLTRB(
              AppConstants.paddingM, AppConstants.paddingM,
              AppConstants.paddingM, botPad + AppConstants.paddingM,
            ),
            child: GestureDetector(
              onTap: cart.isEmpty || _paying ? null : _pay,
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                height: 56,
                decoration: BoxDecoration(
                  color: cart.isEmpty || _paying ? AppColors.forestGreen.withValues(alpha: 0.7) : AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _paying
                      ? const RiveLoadingRing(size: 28, color: AppColors.gold)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isExpress) ...[
                              const Icon(Icons.bolt, size: 16, color: AppColors.gold),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              _payment == _PaymentMethod.cod
                                  ? 'PLACE ORDER · ₹${total.toInt()}'
                                  : 'PAY ₹${total.toInt()}',
                              style: AppTextStyles.categoryChip.copyWith(
                                color: AppColors.white,
                                fontSize: 13,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.forestGreen),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.categoryChip.copyWith(
            fontSize: 10, letterSpacing: 2.5, color: AppColors.textPrimary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: AppConstants.animNormal);
  }
}

// ── Checkout Field ────────────────────────────────────────────────────────────
class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final List<TextInputFormatter>? formatters;

  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.inputType = TextInputType.text,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.categoryChip.copyWith(
            fontSize: 8, letterSpacing: 2.0, color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          inputFormatters: formatters,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 16, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM, vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Delivery Toggle ───────────────────────────────────────────────────────────
class _DeliveryToggle extends StatelessWidget {
  final bool isExpress;
  final ValueChanged<bool> onChanged;
  const _DeliveryToggle({required this.isExpress, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DeliveryOption(
            label: 'EXPRESS',
            sublabel: 'Get it in 2 Hours · FREE',
            icon: Icons.bolt,
            iconColor: AppColors.gold,
            isSelected: isExpress,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: AppConstants.paddingS),
        Expanded(
          child: _DeliveryOption(
            label: 'STANDARD',
            sublabel: '2-3 Days · ₹49',
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.textMuted,
            isSelected: !isExpress,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _DeliveryOption extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryOption({
    required this.label, required this.sublabel, required this.icon,
    required this.iconColor, required this.isSelected, required this.onTap,
  });

  @override
  State<_DeliveryOption> createState() => _DeliveryOptionState();
}

class _DeliveryOptionState extends State<_DeliveryOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.forestGreen.withValues(alpha: 0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            border: Border.all(
              color: widget.isSelected ? AppColors.forestGreen : AppColors.divider,
              width: widget.isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? AppColors.forestGreen
                    : widget.iconColor,
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: widget.isSelected
                      ? AppColors.forestGreen
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.sublabel,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payment Method ────────────────────────────────────────────────────────────
enum _PaymentMethod { razorpay, cod, upi }

class _PaymentSelector extends StatelessWidget {
  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onChanged;
  const _PaymentSelector({required this.selected, required this.onChanged});

  static const _options = [
    (_PaymentMethod.razorpay, 'Razorpay', 'Cards, NetBanking, Wallets', Icons.credit_card_outlined),
    (_PaymentMethod.upi,      'UPI',      'GPay, PhonePe, Paytm',       Icons.qr_code_outlined),
    (_PaymentMethod.cod,      'Cash on Delivery', 'Pay when delivered',  Icons.money_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((opt) {
        final isSelected = selected == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM, vertical: AppConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.06) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                color: isSelected ? AppColors.forestGreen : AppColors.divider,
                width: isSelected ? 1.5 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  opt.$4,
                  size: 20,
                  color: isSelected ? AppColors.forestGreen : AppColors.textMuted,
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.$2,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 13,
                          color: isSelected ? AppColors.forestGreen : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        opt.$3,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10, color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: AppConstants.animFast,
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.forestGreen : AppColors.divider,
                      width: isSelected ? 5 : 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Checkout Summary ──────────────────────────────────────────────────────────
class _CheckoutSummary extends StatelessWidget {
  final double subtotal;
  final double delivery;
  final double total;
  final bool isExpress;

  const _CheckoutSummary({
    required this.subtotal, required this.delivery,
    required this.total, required this.isExpress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _Row(label: 'Subtotal', value: '₹${subtotal.toInt()}'),
          const SizedBox(height: AppConstants.paddingS),
          _Row(
            label: isExpress ? 'Express Delivery' : 'Standard Delivery',
            value: delivery == 0 ? 'FREE' : '₹${delivery.toInt()}',
            valueColor: delivery == 0 ? AppColors.forestGreen : null,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Container(height: 0.5, color: AppColors.divider),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 11, letterSpacing: 2.0,
                ),
              ),
              Text(
                '₹${total.toInt()}',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 20, letterSpacing: 0,
                ),
              ),
            ],
          ),
          if (isExpress) ...[
            const SizedBox(height: AppConstants.paddingS),
            Row(
              children: [
                const Icon(Icons.bolt, size: 12, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  'Estimated delivery: within 2 hours',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.forestGreen, fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Order Confirmation Screen ─────────────────────────────────────────────────
/// Shown after successful payment. Full-screen success state.
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _tickCtrl;

  @override
  void initState() {
    super.initState();
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _tickCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final botPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingXL, topPad + AppConstants.paddingL,
            AppConstants.paddingXL, botPad + AppConstants.paddingM,
          ),
          child: Column(
            children: [
              const Spacer(),

              // ── Rive success tick ──────────────────────────────────────
              RiveSuccessTick(size: 100, fallbackController: _tickCtrl),

              const SizedBox(height: AppConstants.paddingXL),

              Text(
                'ORDER CONFIRMED!',
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 14, letterSpacing: 3.5,
                ),
              ).animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingM),

              Text(
                'Your jewelry is on its way.',
                style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingS),

              Text(
                'Our artisans are preparing your order\nwith care.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted, height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 650.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingL),

              // ── Express delivery ETA ───────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingL, vertical: AppConstants.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(
                    color: AppColors.forestGreen.withValues(alpha: 0.2), width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 16, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Express Delivery',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.forestGreen, fontSize: 13,
                          ),
                        ),
                        Text(
                          'Arriving within 2 hours',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted, fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.1, end: 0),

              // ── Order ID ───────────────────────────────────────────────
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'Order #AUR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.0,
                ),
              ).animate(delay: 900.ms).fadeIn(),

              const Spacer(),

              // ── CTAs ───────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      'CONTINUE SHOPPING',
                      style: AppTextStyles.categoryChip.copyWith(
                        color: AppColors.white, fontSize: 12, letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppConstants.paddingM),

              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider, width: 0.8),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      'VIEW MY ORDERS',
                      style: AppTextStyles.categoryChip.copyWith(
                        fontSize: 11, letterSpacing: 1.5, color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 1100.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
