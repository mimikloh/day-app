import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:day_app/core/theme/app_colors.dart';
import 'package:day_app/data/models/category.dart';
import 'package:day_app/providers/category_provider.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.grey;
  String _selectedIconPath = ''; // Initial empty

  // List of colors: 9 groups with 5 shades each
  final List<List<Color>> _colors = [
    // Red shades
    [Colors.red[900]!, Colors.red[700]!, Colors.red[500]!, Colors.red[300]!, Colors.red[100]!],
    // Orange shades
    [Colors.orange[900]!, Colors.orange[700]!, Colors.orange[500]!, Colors.orange[300]!, Colors.orange[100]!],
    // Yellow shades
    [Colors.yellow[900]!, Colors.yellow[700]!, Colors.yellow[500]!, Colors.yellow[300]!, Colors.yellow[100]!],
    // Green shades
    [Colors.green[900]!, Colors.green[700]!, Colors.green[500]!, Colors.green[300]!, Colors.green[100]!],
    // Blue shades
    [Colors.blue[900]!, Colors.blue[700]!, Colors.blue[500]!, Colors.blue[300]!, Colors.blue[100]!],
    // Indigo shades
    [Colors.indigo[900]!, Colors.indigo[700]!, Colors.indigo[500]!, Colors.indigo[300]!, Colors.indigo[100]!],
    // Purple shades
    [Colors.purple[900]!, Colors.purple[700]!, Colors.purple[500]!, Colors.purple[300]!, Colors.purple[100]!],
    // Black to gray
    [Colors.black, Colors.black87, Colors.black54, Colors.black45, Colors.black38],
    // White to gray
    [Colors.white, Colors.grey[100]!, Colors.grey[300]!, Colors.grey[500]!, Colors.grey[700]!],
  ];


  final List<String> _iconPaths = [
    'assets/icons/isometric/icons8-1-free-50.png',
    'assets/icons/isometric/default.png',
    'assets/icons/isometric/icons8-add-list-50.png',
    'assets/icons/isometric/icons8-agreement-50.png',
    'assets/icons/isometric/icons8-alphabetical-sorting-50.png',
    'assets/icons/isometric/icons8-apple-fruit-50.png',
    'assets/icons/isometric/icons8-archive-folder-50.png',
    'assets/icons/isometric/icons8-ascending-sorting-50.png',
    'assets/icons/isometric/icons8-at-sign-50.png',
    'assets/icons/isometric/icons8-baby-50.png',
    'assets/icons/isometric/icons8-bank-building-50.png',
    'assets/icons/isometric/icons8-bar-chart-50.png',
    'assets/icons/isometric/icons8-bed-50.png',
    'assets/icons/isometric/icons8-bell-curve-50.png',
    'assets/icons/isometric/icons8-billing-50.png',
    'assets/icons/isometric/icons8-binder-50.png',
    'assets/icons/isometric/icons8-birthday-cake-50.png',
    'assets/icons/isometric/icons8-book-50.png',
    'assets/icons/isometric/icons8-bookmark-50.png',
    'assets/icons/isometric/icons8-books-50.png',
    'assets/icons/isometric/icons8-bullet-list-50.png',
    'assets/icons/isometric/icons8-bus-50.png',
    'assets/icons/isometric/icons8-business-50.png',
    'assets/icons/isometric/icons8-calculator-50.png',
    'assets/icons/isometric/icons8-call-50.png',
    'assets/icons/isometric/icons8-car-50.png',
    'assets/icons/isometric/icons8-cash-50.png',
    'assets/icons/isometric/icons8-certificate-50.png',
    'assets/icons/isometric/icons8-chat-50.png',
    'assets/icons/isometric/icons8-checklist-50.png',
    'assets/icons/isometric/icons8-checkmark-50.png',
    'assets/icons/isometric/icons8-coffee-cup-50.png',
    'assets/icons/isometric/icons8-comments-50.png',
    'assets/icons/isometric/icons8-conference-50.png',
    'assets/icons/isometric/icons8-copy-50.png',
    'assets/icons/isometric/icons8-customer-support-50.png',
    'assets/icons/isometric/icons8-database-50.png',
    'assets/icons/isometric/icons8-delete-50.png',
    'assets/icons/isometric/icons8-delivery-time-50.png',
    'assets/icons/isometric/icons8-done-50.png',
    'assets/icons/isometric/icons8-download-50.png',
    'assets/icons/isometric/icons8-edit-pencil-50.png',
    'assets/icons/isometric/icons8-favorite-50.png',
    'assets/icons/isometric/icons8-file-50.png',
    'assets/icons/isometric/icons8-folder-50.png',
    'assets/icons/isometric/icons8-food-cart-50.png',
    'assets/icons/isometric/icons8-gift-50.png',
    'assets/icons/isometric/icons8-goal-50.png',
    'assets/icons/isometric/icons8-graduation-cap-50.png',
    'assets/icons/isometric/icons8-group-50.png',
    'assets/icons/isometric/icons8-heart-50.png',
    'assets/icons/isometric/icons8-home-50.png',
    'assets/icons/isometric/icons8-hourglass-50.png',
    'assets/icons/isometric/icons8-house-50.png',
    'assets/icons/isometric/icons8-info-50.png',
    'assets/icons/isometric/icons8-key-50.png',
    'assets/icons/isometric/icons8-laptop-50.png',
    'assets/icons/isometric/icons8-learning-50.png',
    'assets/icons/isometric/icons8-list-50.png',
    'assets/icons/isometric/icons8-location-50.png',
    'assets/icons/isometric/icons8-lock-50.png',
    'assets/icons/isometric/icons8-male-user-50.png',
    'assets/icons/isometric/icons8-map-50.png',
    'assets/icons/isometric/icons8-medal-50.png',
    'assets/icons/isometric/icons8-menu-50.png',
    'assets/icons/isometric/icons8-minus-50.png',
    'assets/icons/isometric/icons8-music-folder-50.png',
    'assets/icons/isometric/icons8-ok-hand-50.png',
    'assets/icons/isometric/icons8-open-book-50.png',
    'assets/icons/isometric/icons8-paper-50.png',
    'assets/icons/isometric/icons8-password-50.png',
    'assets/icons/isometric/icons8-phone-50.png',
    'assets/icons/isometric/icons8-picture-50.png',
    'assets/icons/isometric/icons8-pie-chart-50.png',
    'assets/icons/isometric/icons8-plane-50.png',
    'assets/icons/isometric/icons8-plus-50.png',
    'assets/icons/isometric/icons8-print-50.png',
    'assets/icons/isometric/icons8-product-50.png',
    'assets/icons/isometric/icons8-purchase-order-50.png',
    'assets/icons/isometric/icons8-qr-code-50.png',
    'assets/icons/isometric/icons8-reminder-50.png',
    'assets/icons/isometric/icons8-rename-50.png',
    'assets/icons/isometric/icons8-restaurant-50.png',
    'assets/icons/isometric/icons8-save-50.png',
    'assets/icons/isometric/icons8-schedule-50.png',
    'assets/icons/isometric/icons8-school-50.png',
    'assets/icons/isometric/icons8-search-50.png',
    'assets/icons/isometric/icons8-settings-50.png',
    'assets/icons/isometric/icons8-shopping-cart-50.png',
    'assets/icons/isometric/icons8-smartphone-50.png',
    'assets/icons/isometric/icons8-sms-50.png',
    'assets/icons/isometric/icons8-sort-down-50.png',
    'assets/icons/isometric/icons8-speedometer-50.png',
    'assets/icons/isometric/icons8-star-50.png',
    'assets/icons/isometric/icons8-stopwatch-50.png',
    'assets/icons/isometric/icons8-sun-50.png',
    'assets/icons/isometric/icons8-sync-50.png',
    'assets/icons/isometric/icons8-table-50.png',
    'assets/icons/isometric/icons8-tags-50.png',
    'assets/icons/isometric/icons8-taxi-50.png',
    'assets/icons/isometric/icons8-tea-cup-50.png',
    'assets/icons/isometric/icons8-tear-off-calendar-50.png',
    'assets/icons/isometric/icons8-test-passed-50.png',
    'assets/icons/isometric/icons8-ticket-50.png',
    'assets/icons/isometric/icons8-timeline-50.png',
    'assets/icons/isometric/icons8-today-50.png',
    'assets/icons/isometric/icons8-tools-50.png',
    'assets/icons/isometric/icons8-train-50.png',
    'assets/icons/isometric/icons8-training-50.png',
    'assets/icons/isometric/icons8-trash-can-50.png',
    'assets/icons/isometric/icons8-trophy-50.png',
    'assets/icons/isometric/icons8-truck-50.png',
    'assets/icons/isometric/icons8-undo-50.png',
    'assets/icons/isometric/icons8-upload-to-cloud-50.png',
    'assets/icons/isometric/icons8-user-female-50.png',
    'assets/icons/isometric/icons8-user-male-50.png',
    'assets/icons/isometric/icons8-video-playlist-50.png',
    'assets/icons/isometric/icons8-waste-separation-50.png',
    'assets/icons/isometric/icons8-water-50.png',
    'assets/icons/isometric/icons8-web-design-50.png',
    'assets/icons/isometric/icons8-wi-fi-50.png',
    'assets/icons/isometric/icons8-workflow-50.png',
    'assets/icons/isometric/icons8-world-map-50.png',
    'assets/icons/isometric/icons8-wrench-50.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: AppBar(
                title: Text(
                  'Добавить тематику',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: true,
              ),
            ),

            // ОСНОВНОЙ КОНТЕНТ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 18, color: AppColors.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'Название тематики',
                        hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                        filled: true,
                        fillColor: AppColors.card(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Выберите цвет:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary(context))),
                    const SizedBox(height: 12),

                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _colors.length * 5,
                        itemBuilder: (context, index) {
                          final group = index ~/ 5;
                          final shade = index % 5;
                          final color = _colors[group][shade];

                          final bool isDark = color.computeLuminance() < 0.5;
                          final Color checkColor = isDark ? Colors.white : Colors.black;

                          final bool isSelected = _selectedColor.value == color.value;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity: isSelected ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.check,
                                    color: checkColor,
                                    size: 32,
                                    weight: 3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text('Выберите иконку:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary(context))),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _iconPaths.length,
                        itemBuilder: (context, index) {
                          final path = _iconPaths[index];

                          return GestureDetector(
                            onTap: () => setState(() => _selectedIconPath = path),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedIconPath == path ? AppColors.accentBlue : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(path, fit: BoxFit.contain),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.isEmpty || _selectedIconPath.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните название и выберите иконку')));
                          return;
                        }

                        final category = Category.create(
                          id: const Uuid().v4(),
                          name: _nameController.text,
                          iconPath: _selectedIconPath,
                          color: _selectedColor,
                        );

                        await ref.read(categoryNotifierProvider.notifier).addCategory(category);
                        ref.refresh(categoriesProvider);

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Сохранить тематику'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}