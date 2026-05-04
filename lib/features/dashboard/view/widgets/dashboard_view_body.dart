import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/localization/app_localizations.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/core/widgets/language_toggle_button.dart';
import 'package:xspire_dashboard/core/widgets/special_logout_button.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/add_product_view.dart';
import 'package:xspire_dashboard/features/auth/presentation/manager/Login_cubit/login_cubit.dart';
import 'package:xspire_dashboard/features/auth/presentation/manager/Login_cubit/login_state.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/manage_data_view.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/add_restaurant_simple.dart';

class DashboardViewBody extends StatelessWidget {
  const DashboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          Navigator.pushNamedAndRemoveUntil(
              context, 'LoginView', (route) => false);
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            actions: const [
              LanguageToggleButton(),
              SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50, right: -50,
                      child: Container(
                        width: 200, height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30, left: -40,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                    Icons.restaurant_rounded,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context).appTitle,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(AppLocalizations.of(context).foodOutletManagement,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context).quickActions,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 16),

                // ── Three action cards (2x2 grid) ──────────────────────
                Row(
                  children: [
                    // Add Bag Item
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.shopping_bag_outlined,
                        label: AppLocalizations.of(context).addBagItemLabel,
                        subtitle: AppLocalizations.of(context).scanAddBags,
                        gradient: AppColors.primaryGradient,
                        onTap: () => Navigator.pushNamed(
                            context, AddProductView.routeName),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Add Restaurant
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.add_business_outlined,
                        label: AppLocalizations.of(context).addRestaurantLabel,
                        subtitle: AppLocalizations.of(context).createNewRestaurant,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.pushNamed(
                            context, AddRestaurantSimple.routeName),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Manage Restaurants
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.manage_search_rounded,
                        label: AppLocalizations.of(context).manageRestaurantsLabel,
                        subtitle: AppLocalizations.of(context).viewEditDelete,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.pushNamed(
                            context, ManageDataView.routeName),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Placeholder for symmetry (or can add 4th action)
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.analytics_outlined,
                        label: AppLocalizations.of(context).analyticsStatsLabel,
                        subtitle: AppLocalizations.of(context).comingSoon,
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade600, Colors.grey.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context).comingSoon)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Logout ──────────────────────────────────────────────
                SpecialLogoutButton(
                  onPressed: () {
                    context.read<LoginCubit>().logout();
                  },
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Action Card ───────────────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18, bottom: -18,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.2)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}