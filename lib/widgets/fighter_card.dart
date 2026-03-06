import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FighterCard extends StatelessWidget {
  final String name;
  final String prompt;
  final String subtitle;
  final Color cornerColor;
  final String cornerLabel;
  final String belt;
  final VoidCallback onReroll;
  final String? demoUrl;
  final bool locked;

  const FighterCard({
    super.key,
    required this.name,
    required this.prompt,
    required this.subtitle,
    required this.cornerColor,
    required this.cornerLabel,
    required this.belt,
    required this.onReroll,
    this.demoUrl,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cornerColor.withOpacity(0.12),
            const Color(0xFF1A1A2E),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cornerColor.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cornerColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cornerLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: locked ? null : onReroll,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: locked
                        ? Colors.white.withOpacity(0.05)
                        : cornerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: locked
                          ? Colors.white12
                          : cornerColor.withOpacity(0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: locked ? Colors.white24 : cornerColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prompt,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0x73FFFFFF),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Demo badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: demoUrl != null ? Colors.white38 : Colors.white12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 13,
                  color: demoUrl != null ? Colors.white60 : Colors.white24,
                ),
                const SizedBox(width: 5),
                Text(
                  demoUrl != null ? 'Watch Demo' : 'Demo Coming Soon',
                  style: TextStyle(
                    color:
                        demoUrl != null ? Colors.white60 : Colors.white24,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${belt[0].toUpperCase()}${belt.substring(1)} belt',
              style:
                  const TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}