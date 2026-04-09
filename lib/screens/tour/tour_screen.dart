import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../theme/theme.dart';

const List<List<Color>> _kGradients = [
  [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  [Color(0xFF3B82F6), Color(0xFF06B6D4)],
  [Color(0xFF10B981), Color(0xFF3B82F6)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
  [Color(0xFFEC4899), Color(0xFF8B5CF6)],
];

class TourScreen extends StatefulWidget {
  final Property property;
  const TourScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  static const _totalPhotos = 5;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.title, style: const TextStyle(fontSize: 16)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(text: 'Gallery'),
            Tab(text: 'Floor Plan'),
            Tab(text: '360° View'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Property highlights strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.bg1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (p.beds > 0) _highlight(Icons.bed_outlined, '${p.beds} Beds'),
                if (p.baths > 0)
                  _highlight(Icons.bathtub_outlined, '${p.baths} Baths'),
                if (p.sqft > 0)
                  _highlight(Icons.square_foot_outlined,
                      '${p.sqft.toString()} sqft'),
                if (p.yearBuilt > 0)
                  _highlight(Icons.calendar_today_outlined,
                      'Built ${p.yearBuilt}'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _galleryTab(),
                _floorPlanTab(),
                _virtualTourTab(),
              ],
            ),
          ),
          // Schedule Tour button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _scheduleTour,
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Schedule In-Person Tour'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryTab() {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _pageCtrl,
          itemCount: _totalPhotos,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (_, i) {
            final colors = _kGradients[i % _kGradients.length];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_outlined,
                        size: 80,
                        color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Photo ${i + 1} of $_totalPhotos',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Left arrow
        Positioned(
          left: 8,
          child: _navArrow(Icons.chevron_left_rounded, () {
            if (_currentPage > 0) {
              _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            }
          }),
        ),
        // Right arrow
        Positioned(
          right: 8,
          child: _navArrow(Icons.chevron_right_rounded, () {
            if (_currentPage < _totalPhotos - 1) {
              _pageCtrl.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            }
          }),
        ),
        // Dot indicators
        Positioned(
          bottom: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_totalPhotos, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 14 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _floorPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Floor Plan',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Container(
            height: 340,
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: _FloorPlanPainter(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '* Floor plan is illustrative. Dimensions approximate.',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _virtualTourTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.5),
                    AppColors.accent2.withOpacity(0.2),
                    AppColors.bg1,
                  ],
                ),
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.4), width: 2),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_in_ar_outlined,
                        color: AppColors.accent, size: 48),
                    SizedBox(height: 8),
                    Text('360° Tour',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Virtual 360° Tour',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Immersive virtual tours available in Premium plan.',
              style: TextStyle(
                  color: AppColors.muted, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warn.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.warn.withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium,
                      color: AppColors.warn, size: 16),
                  SizedBox(width: 6),
                  Text('Available in Premium Plan',
                      style: TextStyle(
                          color: AppColors.warn,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _highlight(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      ],
    );
  }

  Future<void> _scheduleTour() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.bg1,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tour scheduled for ${date.month}/${date.day}/${date.year} at ${widget.property.title}!',
          ),
          backgroundColor: AppColors.good,
        ),
      );
    }
  }
}

class _FloorPlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    void drawRoom(Rect rect, String label) {
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, paint);
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(color: AppColors.muted, fontSize: 10),
      );
      textPainter.layout(maxWidth: rect.width - 8);
      textPainter.paint(
        canvas,
        Offset(
          rect.left + (rect.width - textPainter.width) / 2,
          rect.top + (rect.height - textPainter.height) / 2,
        ),
      );
    }

    final w = size.width;
    final h = size.height;
    final pad = 20.0;

    // Living Room
    drawRoom(Rect.fromLTWH(pad, pad, w * 0.5, h * 0.35), 'Living Room');
    // Kitchen
    drawRoom(
        Rect.fromLTWH(pad + w * 0.5, pad, w * 0.3 - pad, h * 0.35), 'Kitchen');
    // Bedroom 1
    drawRoom(
        Rect.fromLTWH(pad, pad + h * 0.35, w * 0.35, h * 0.35), 'Bedroom 1');
    // Bedroom 2
    drawRoom(
        Rect.fromLTWH(pad + w * 0.35, pad + h * 0.35, w * 0.35, h * 0.35),
        'Bedroom 2');
    // Bathroom
    drawRoom(
        Rect.fromLTWH(pad + w * 0.7, pad + h * 0.35, w * 0.1, h * 0.35),
        'Bath');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
