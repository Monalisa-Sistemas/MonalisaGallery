import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MTabWidgetItem {
  const MTabWidgetItem({
    required this.label,
    required this.icon,
    required this.child,
    this.activeBackgroundColor = const Color(0xFF155AA8),
    this.activeForegroundColor = Colors.white,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final Color activeBackgroundColor;
  final Color activeForegroundColor;
}

class MTabWidget extends StatelessWidget {
  const MTabWidget({
    super.key,
    required this.items,
    this.contentHeight = 320,
    this.initialIndex = 0,
    this.padding = EdgeInsets.zero,
  });

  final List<MTabWidgetItem> items;
  final double contentHeight;
  final int initialIndex;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    assert(items.isNotEmpty, 'MTabWidget needs at least one tab.');

    return DefaultTabController(
      length: items.length,
      initialIndex: initialIndex.clamp(0, items.length - 1).toInt(),
      child: Padding(
        padding: padding,
        child: Builder(
          builder: (context) {
            final controller = DefaultTabController.of(context);

            return AnimatedBuilder(
              animation: controller.animation ?? controller,
              builder: (context, _) {
                final selectedIndex =
                    controller.index.clamp(0, items.length - 1).toInt();
                final activeItem = items[selectedIndex];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDDE5EE)),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        labelColor: activeItem.activeForegroundColor,
                        unselectedLabelColor: const Color(0xFF64748B),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: activeItem.activeBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD7E0EA)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                        unselectedLabelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                        tabs: [
                          for (final item in items)
                            Tab(
                              height: 32,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(item.icon, size: 16),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      item.label.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: contentHeight,
                      child: TabBarView(
                        children: [for (final item in items) item.child],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
