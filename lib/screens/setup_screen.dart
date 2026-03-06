import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_native_splash/flutter_native_splash.dart';


const belts = ['white', 'blue', 'purple', 'brown', 'black'];

const beltColors = {
  'white': Color(0xFFEEEEEE),
  'blue': Color(0xFF3A86FF),
  'purple': Color(0xFF9B5DE5),
  'brown': Color(0xFF8B4513),
  'black': Color(0xFF555555),
};

const beltDotColors = [
  Color(0xFFEEEEEE),
  Color(0xFF3A86FF),
  Color(0xFF9B5DE5),
  Color(0xFF8B4513),
  Color(0x3E2A2A3E),
];

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  final _blueController = TextEditingController();
  final _redController = TextEditingController();
  String _selectedBelt = 'white';
  String _promptType = 'submission';
  bool _isGi = true;
  bool _loading = false;

  late AnimationController _diceController;
  late Animation<double> _diceAnim;

  @override
  void initState() {
    super.initState();
    _loadData();
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _diceAnim = CurvedAnimation(
        parent: _diceController, curve: Curves.easeInOutBack);
    _diceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _diceController.reset();
      }
    });
  }

  @override
  void dispose() {
    _diceController.dispose();
    _blueController.dispose();
    _redController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await movesService.load();
    FlutterNativeSplash.remove(); // splash disappears once data is ready
    setState(() => _loading = false);
  }

  void _rollDice() {
    if (_diceController.isAnimating) return;
    _diceController.forward();
  }

  void _openFeedback() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Feedback',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Got a suggestion or found a bug? Let us know!',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your feedback here...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE63946), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              // Capture messenger BEFORE closing dialog
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                await http.post(
                  Uri.parse('https://formspree.io/f/xgolgrje'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'message': text,
                    'subject': 'RanJitzu Feedback',
                  }),
                );
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🥋 Thanks for your feedback!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    backgroundColor: Color(0xFF2A2A3E),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (_) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      '❌ Failed to send — check connection',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    backgroundColor: Color(0xFF2A2A3E),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Send',
                style: TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _generate() {
    _rollDice();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final blueName = _blueController.text.trim().isEmpty
          ? 'Blue'
          : _blueController.text.trim();
      final redName = _redController.text.trim().isEmpty
          ? 'Red'
          : _redController.text.trim();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            blueName: blueName,
            redName: redName,
            belt: _selectedBelt,
            promptType: _promptType,
            isGi: _isGi,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Bottom Nav Bar ──
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121F),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HistoryScreen()),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.history, color: Colors.white38, size: 22),
                      SizedBox(height: 4),
                      Text('History',
                          style: TextStyle(
                              color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _openFeedback,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.feedback_outlined,
                          color: Colors.white38, size: 22),
                      SizedBox(height: 4),
                      Text('Feedback',
                          style: TextStyle(
                              color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo + Title ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _rollDice,
                          child: MouseRegion(
                            onEnter: (_) => _rollDice(),
                            cursor: SystemMouseCursors.click,
                            child: AnimatedBuilder(
                              animation: _diceAnim,
                              builder: (_, __) {
                                final angle = _diceAnim.value * 2 * pi;
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationZ(angle),
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: CustomPaint(
                                      painter: _DicePainter(
                                        beltIndex:
                                            belts.indexOf(_selectedBelt),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RanJitzu',
                              style: GoogleFonts.inter(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFE63946),
                                letterSpacing: -2,
                              ),
                            ),
                            const Text(
                              'Random BJJ Position Generator',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // ── Fighters ──
                    const _Label('FIGHTERS'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _NameField(
                            controller: _blueController,
                            label: 'Blue Corner',
                            accentColor: const Color(0xFF3A86FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NameField(
                            controller: _redController,
                            label: 'Red Corner',
                            accentColor: const Color(0xFFE63946),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Belt ──
                    const _Label('BELT LEVEL'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: belts.map((belt) {
                        final selected = _selectedBelt == belt;
                        final color = beltColors[belt]!;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedBelt = belt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? color
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 26,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  belt[0].toUpperCase() +
                                      belt.substring(1),
                                  style: TextStyle(
                                    color: selected
                                        ? color
                                        : Colors.white30,
                                    fontSize: 10,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // ── Format ──
                    const _Label('FORMAT'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeButton(
                            label: 'Gi',
                            iconWidget: const _GiIcon(
                                color: Color(0xFFE63946), size: 32),
                            selected: _isGi,
                            onTap: () => setState(() => _isGi = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TypeButton(
                            label: 'No-Gi',
                            iconWidget: const _NoGiIcon(
                                color: Color(0xFFE63946), size: 32),
                            selected: !_isGi,
                            onTap: () => setState(() => _isGi = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Prompt Type ──
                    const _Label('GAME TYPE'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeButton(
                            label: 'Submission Hunt',
                            iconWidget: const _SubmissionIcon(
                                color: Color(0xFFE63946), size: 32),
                            selected: _promptType == 'submission',
                            onTap: () => setState(
                                () => _promptType = 'submission'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TypeButton(
                            label: 'Starting Position',
                            iconWidget: const _GrappleIcon(
                                color: Color(0xFFE63946), size: 32),
                            selected: _promptType == 'position',
                            onTap: () =>
                                setState(() => _promptType = 'position'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),

                    // ── Generate ──
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _generate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE63946),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          shadowColor:
                              const Color(0xFFE63946).withOpacity(0.5),
                        ),
                        child: Text(
                          'GENERATE',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Dice ───────────────────────────────────────────────────
class _DicePainter extends CustomPainter {
  final int beltIndex;
  _DicePainter({required this.beltIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.05,
          size.width * 0.9, size.height * 0.9),
      Radius.circular(size.width * 0.2),
    );
    paintFill.color = const Color(0xFFE63946);
    canvas.drawRRect(rect, paintFill);
    canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.04
          ..color = const Color(0xFF9B1D24));

    final dotPositions = [
      Offset(size.width * 0.28, size.height * 0.27),
      Offset(size.width * 0.72, size.height * 0.27),
      Offset(size.width * 0.50, size.height * 0.50),
      Offset(size.width * 0.28, size.height * 0.73),
      Offset(size.width * 0.72, size.height * 0.73),
    ];

    for (int i = 0; i < dotPositions.length; i++) {
      final isActive = i == beltIndex;
      paintFill.color = isActive
          ? beltDotColors[i]
          : beltDotColors[i].withOpacity(0.3);
      canvas.drawCircle(dotPositions[i],
          size.width * (isActive ? 0.115 : 0.075), paintFill);
    }
  }

  @override
  bool shouldRepaint(_DicePainter old) => old.beltIndex != beltIndex;
}

// ── Gi Icon ────────────────────────────────────────────────
class _GiIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _GiIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GiPainter(color: color)),
    );
  }
}

class _GiPainter extends CustomPainter {
  final Color color;
  _GiPainter({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(s.width * 0.15, s.height * 0.25);
    path.lineTo(s.width * 0.02, s.height * 0.38);
    path.lineTo(s.width * 0.02, s.height * 0.58);
    path.lineTo(s.width * 0.22, s.height * 0.52);
    path.lineTo(s.width * 0.22, s.height * 0.95);
    path.lineTo(s.width * 0.78, s.height * 0.95);
    path.lineTo(s.width * 0.78, s.height * 0.52);
    path.lineTo(s.width * 0.98, s.height * 0.58);
    path.lineTo(s.width * 0.98, s.height * 0.38);
    path.lineTo(s.width * 0.85, s.height * 0.25);
    path.quadraticBezierTo(s.width * 0.75, s.height * 0.1,
        s.width * 0.5, s.height * 0.18);
    path.quadraticBezierTo(s.width * 0.25, s.height * 0.1,
        s.width * 0.15, s.height * 0.25);
    path.moveTo(s.width * 0.35, s.height * 0.28);
    path.lineTo(s.width * 0.42, s.height * 0.95);
    path.moveTo(s.width * 0.65, s.height * 0.28);
    path.lineTo(s.width * 0.58, s.height * 0.95);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_GiPainter old) => old.color != color;
}

// ── No-Gi Icon ─────────────────────────────────────────────
class _NoGiIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _NoGiIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _NoGiPainter(color: color)),
    );
  }
}

class _NoGiPainter extends CustomPainter {
  final Color color;
  _NoGiPainter({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(s.width * 0.02, s.height * 0.35);
    path.lineTo(s.width * 0.22, s.height * 0.18);
    path.lineTo(s.width * 0.35, s.height * 0.12);
    path.quadraticBezierTo(s.width * 0.5, s.height * 0.22,
        s.width * 0.65, s.height * 0.12);
    path.lineTo(s.width * 0.78, s.height * 0.18);
    path.lineTo(s.width * 0.98, s.height * 0.35);
    path.lineTo(s.width * 0.82, s.height * 0.42);
    path.lineTo(s.width * 0.82, s.height * 0.95);
    path.lineTo(s.width * 0.18, s.height * 0.95);
    path.lineTo(s.width * 0.18, s.height * 0.42);
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_NoGiPainter old) => old.color != color;
}

// ── Submission Icon ────────────────────────────────────────
class _SubmissionIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _SubmissionIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SubmissionPainter(color: color)),
    );
  }
}

class _SubmissionPainter extends CustomPainter {
  final Color color;
  _SubmissionPainter({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.08
      ..strokeCap = StrokeCap.round;

    final cx = s.width * 0.5;
    final cy = s.height * 0.5;
    final outerR = s.width * 0.44;
    final innerR = s.width * 0.22;

    canvas.drawCircle(Offset(cx, cy), outerR, stroke);
    canvas.drawCircle(Offset(cx, cy), innerR, stroke);
    canvas.drawLine(Offset(cx, cy - outerR), Offset(cx, cy - innerR), stroke);
    canvas.drawLine(Offset(cx, cy + innerR), Offset(cx, cy + outerR), stroke);
    canvas.drawLine(Offset(cx - outerR, cy), Offset(cx - innerR, cy), stroke);
    canvas.drawLine(Offset(cx + innerR, cy), Offset(cx + outerR, cy), stroke);
    canvas.drawCircle(Offset(cx, cy), s.width * 0.06,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_SubmissionPainter old) => old.color != color;
}

// ── Grapple Icon ───────────────────────────────────────────
class _GrappleIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _GrappleIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GrapplePainter(color: color)),
    );
  }
}

class _GrapplePainter extends CustomPainter {
  final Color color;
  _GrapplePainter({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(
        Offset(s.width * 0.2, s.height * 0.16), s.width * 0.09, fill);
    canvas.drawLine(Offset(s.width * 0.2, s.height * 0.25),
        Offset(s.width * 0.28, s.height * 0.55), stroke);
    canvas.drawLine(Offset(s.width * 0.2, s.height * 0.35),
        Offset(s.width * 0.5, s.height * 0.40), stroke);
    canvas.drawLine(Offset(s.width * 0.28, s.height * 0.55),
        Offset(s.width * 0.38, s.height * 0.92), stroke);
    canvas.drawLine(Offset(s.width * 0.28, s.height * 0.55),
        Offset(s.width * 0.10, s.height * 0.88), stroke);

    canvas.drawCircle(
        Offset(s.width * 0.80, s.height * 0.16), s.width * 0.09, fill);
    canvas.drawLine(Offset(s.width * 0.80, s.height * 0.25),
        Offset(s.width * 0.75, s.height * 0.55), stroke);
    canvas.drawLine(Offset(s.width * 0.80, s.height * 0.35),
        Offset(s.width * 0.5, s.height * 0.40), stroke);
    canvas.drawLine(Offset(s.width * 0.75, s.height * 0.55),
        Offset(s.width * 0.62, s.height * 0.92), stroke);
    canvas.drawLine(Offset(s.width * 0.75, s.height * 0.55),
        Offset(s.width * 0.90, s.height * 0.88), stroke);

    canvas.drawCircle(
        Offset(s.width * 0.5, s.height * 0.40), s.width * 0.07, fill);
  }

  @override
  bool shouldRepaint(_GrapplePainter old) => old.color != color;
}

// ── Helpers ────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.5,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color accentColor;
  const _NameField({
    required this.controller,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentColor.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final bool selected;
  final VoidCallback onTap;
  const _TypeButton({
    required this.label,
    required this.iconWidget,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE63946).withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                selected ? const Color(0xFFE63946) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                selected ? const Color(0xFFE63946) : Colors.white30,
                BlendMode.srcIn,
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white30,
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}