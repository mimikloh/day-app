import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:day_app/core/theme/app_colors.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> _icons = const [
    'assets/icons/sf/Home Page.png',
    'assets/icons/sf/Calendar.png',
    'assets/icons/sf/Eye Shadows.png',
    'assets/icons/sf/Automatic.png',
  ];

  final List<String> _labels = const [
    'Главная',
    'Расписание',
    'Моя тема',
    'Настройки',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Основная панель
        Container(
          height: 105,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 20,
                spreadRadius: -5,
                color: Colors.black.withOpacity(0.15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Container(
              color: AppColors.card(context).withOpacity(0.96),
              child: Stack(
                children: [
                  _buildTabContainer(context: context, index: 0, left: 8),
                  _buildTabContainer(context: context, index: 1, left: screenWidth * 0.2),
                  _buildTabContainer(context: context, index: 2, right: screenWidth * 0.2),
                  _buildTabContainer(context: context, index: 3, right: 8),
                ],
              ),
            ),
          ),
        ),

        // Кнопка +
        Positioned(
          bottom: 52,
          child: GestureDetector(
            onTap: () {
              final currentPath = GoRouterState.of(context).uri.toString();
              context.push(
                '/add-task',
                extra: currentPath,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    spreadRadius: 0,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
              child: const ThickPlusIcon(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContainer({
    required BuildContext context,
    required int index,
    double? left,
    double? right,
  }) {
    final bool isActive = currentIndex == index;

    return Positioned(
      left: left,
      right: right,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 80,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _icons[index],
                width: 44,
                height: 44,
                color: isActive
                    ? AppColors.accentBlue
                    : AppColors.textSecondary(context).withOpacity(0.7),
                colorBlendMode: BlendMode.srcIn,
              ),
              Text(
                _labels[index],
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? AppColors.accentBlue : AppColors.textSecondary(context).withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThickPlusIcon extends StatelessWidget {
  const ThickPlusIcon({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(80, 80),
    painter: _ThickPlusPainter(),
  );
}

class _ThickPlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(center.dx - 18, center.dy), Offset(center.dx + 18, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - 18), Offset(center.dx, center.dy + 18), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}