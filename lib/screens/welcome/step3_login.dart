import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';

class Step3Login extends StatefulWidget {
  final AppLocalizations l;
  final bool isDark;

  const Step3Login({super.key, required this.l, required this.isDark});

  @override
  State<Step3Login> createState() => _Step3LoginState();
}

class _Step3LoginState extends State<Step3Login> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    await provider.setLoggedIn(
      name: 'Demo User',
      email: 'demo@gmail.com',
      photo: null,
    );
    await provider.setOnboarded();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: EdgeInsets.fromLTRB(isWide ? 40 : 24, 24, isWide ? 40 : 24, 24),
            children: [
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C2FF), Color(0xFF0070FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C2FF).withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, size: 56, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                widget.l.get('login_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.l.get('login_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: widget.isDark ? Colors.white54 : Colors.black54,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.l.get('login_required'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDark ? const Color(0xFF252538) : Colors.white,
                    foregroundColor: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: widget.isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const _GoogleIcon(),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.l.get('btn_google'),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
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

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r * 0.85), -0.45, 1.8, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r * 0.85), -1.8, 1.0, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r * 0.85), 2.8, 0.9, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r * 0.85), 1.35, 1.0, false, paint);
    paint
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - size.height * 0.1, r * 0.85, size.height * 0.18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
