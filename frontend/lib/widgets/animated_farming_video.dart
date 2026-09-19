import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class AnimatedFarmingVideo extends StatefulWidget {
  final String title;
  final String topic;
  final String category;
  final List<String> steps;
  final Color themeColor;

  const AnimatedFarmingVideo({
    super.key,
    required this.title,
    required this.topic,
    required this.category,
    required this.steps,
    this.themeColor = AppTheme.primaryGreen,
  });

  @override
  State<AnimatedFarmingVideo> createState() => _AnimatedFarmingVideoState();
}

class _AnimatedFarmingVideoState extends State<AnimatedFarmingVideo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;
  int _currentSceneIndex = 0;

  final List<Map<String, dynamic>> _scenes = [
    {
      'title': '1. Spotting the Disease / Pest',
      'subtitle': 'Scanning lower canopy leaves for fungal spot rings & insect signs.',
      'badge': 'DIAGNOSIS',
      'icon': Icons.search_rounded,
      'color': Color(0xFFE76F51),
    },
    {
      'title': '2. Pruning Infected Foliage',
      'subtitle': 'Cutting spotted leaves 15cm from ground to stop spores spreading.',
      'badge': 'PRUNING',
      'icon': Icons.content_cut_rounded,
      'color': Color(0xFFF4A261),
    },
    {
      'title': '3. Organic Neem Spray Mist',
      'subtitle': 'Spraying 5ml organic Neem oil + soap mist to form protective shield.',
      'badge': 'TREATMENT',
      'icon': Icons.opacity_rounded,
      'color': Color(0xFF2A9D8F),
    },
    {
      'title': '4. Root-Zone Drip Watering',
      'subtitle': 'Watering roots directly to keep leaves completely dry and mold-free.',
      'badge': 'IRRIGATION',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'title': '5. Restored Healthy Harvest',
      'subtitle': 'Foliage recovers healthy green color with strong crop growth.',
      'badge': 'RECOVERY',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF059669),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(() {
        final progress = _controller.value;
        final sceneIdx = (progress * _scenes.length).floor().clamp(0, _scenes.length - 1);
        if (sceneIdx != _currentSceneIndex) {
          setState(() {
            _currentSceneIndex = sceneIdx;
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.isCompleted) {
        _controller.reset();
        _controller.forward();
        _isPlaying = true;
      } else if (_isPlaying) {
        _controller.stop();
        _isPlaying = false;
      } else {
        _controller.forward();
        _isPlaying = true;
      }
    });
  }

  void _jumpToScene(int idx) {
    setState(() {
      _currentSceneIndex = idx;
      _controller.value = idx / _scenes.length;
      if (!_isPlaying) {
        _controller.forward();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentScene = _scenes[_currentSceneIndex];
    final totalSeconds = 18;
    final currentSec = (_controller.value * totalSeconds).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Video Animation Screen Stage
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0C1F16),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Animated Custom Canvas Visual Scene
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: FarmingScenePainter(
                          sceneIndex: _currentSceneIndex,
                          progress: (_controller.value * _scenes.length) - _currentSceneIndex,
                          globalProgress: _controller.value,
                        ),
                      );
                    },
                  ),
                ),

                // Top Header Badge Overlay
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (currentScene['color'] as Color).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(currentScene['icon'] as IconData, color: Colors.white, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '${currentScene['badge']} • SCENE ${_currentSceneIndex + 1}/5',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '00:${currentSec.toString().padLeft(2, '0')} / 00:$totalSeconds',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Subtitle & Animation Caption Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentScene['title'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          currentScene['subtitle'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFFD8F3DC),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Scrubber Progress Bar
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _controller.value,
                                minHeight: 3.5,
                                backgroundColor: Colors.white24,
                                color: const Color(0xFF10B981),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Play/Pause Floating Overlay
                Center(
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          _controller.isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                          color: AppTheme.primaryGreen,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Playback Control Bar & Quick Scene Skip Chips
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _togglePlay,
              icon: Icon(_isPlaying ? Icons.pause_rounded : (_controller.isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded), size: 16),
              label: Text(_isPlaying ? 'Pause Animation' : (_controller.isCompleted ? 'Replay Video' : 'Play Animation')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_scenes.length, (i) {
                final isSelected = i == _currentSceneIndex;
                return GestureDetector(
                  onTap: () => _jumpToScene(i),
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryGreen : const Color(0xFFE5EAE5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF4B5E52),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom Dynamic Canvas Painter for 5 Farming Scenes
class FarmingScenePainter extends CustomPainter {
  final int sceneIndex;
  final double progress; // 0.0 to 1.0 within current scene
  final double globalProgress;

  FarmingScenePainter({
    required this.sceneIndex,
    required this.progress,
    required this.globalProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Sky / Soil
    final skyPaint = Paint()..color = const Color(0xFF0F2D1F);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    final groundPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), groundPaint);

    final grassPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.76, w, h * 0.03), grassPaint);

    // Draw Plant Stems
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = w * 0.5;
    final baseY = h * 0.77;
    final topY = h * 0.35;

    // Main Stem
    final stemPath = Path()
      ..moveTo(centerX, baseY)
      ..quadraticBezierTo(centerX - 10, h * 0.55, centerX, topY);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves
    _drawLeaf(canvas, centerX - 40, h * 0.58, -0.4, sceneIndex >= 4 ? const Color(0xFF4CAF50) : const Color(0xFF388E3C));
    _drawLeaf(canvas, centerX + 40, h * 0.52, 0.4, sceneIndex >= 4 ? const Color(0xFF4CAF50) : const Color(0xFF388E3C));
    _drawLeaf(canvas, centerX - 35, h * 0.40, -0.3, sceneIndex >= 4 ? const Color(0xFF81C784) : const Color(0xFF4CAF50));
    _drawLeaf(canvas, centerX + 35, h * 0.36, 0.3, sceneIndex >= 4 ? const Color(0xFF81C784) : const Color(0xFF4CAF50));

    // Scene Specific Animations
    if (sceneIndex == 0) {
      // Scene 1: Disease Spot Scanning
      final spotPaint = Paint()..color = const Color(0xFFD32F2F);
      canvas.drawCircle(Offset(centerX - 40, h * 0.58), 6 + math.sin(progress * math.pi * 4) * 2, spotPaint);
      canvas.drawCircle(Offset(centerX - 35, h * 0.62), 4, spotPaint);
      canvas.drawCircle(Offset(centerX + 35, h * 0.54), 5, spotPaint);

      // Magnifier ring scanning
      final scanX = centerX - 40 + (progress * 80);
      final scanY = h * 0.55 + math.sin(progress * math.pi * 2) * 10;
      final scanPaint = Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(scanX, scanY), 18, scanPaint);
    } else if (sceneIndex == 1) {
      // Scene 2: Shears Pruning
      final cutProgress = progress.clamp(0.0, 1.0);
      final cutX = centerX - 30;
      final cutY = h * 0.60;

      // Draw Cut Shears
      final shearPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cutX - 15, cutY - 10), Offset(cutX + 10, cutY + 5), shearPaint);
      canvas.drawLine(Offset(cutX - 15, cutY + 10), Offset(cutX + 10, cutY - 5), shearPaint);

      // Falling diseased leaf
      final fallY = cutY + (cutProgress * 30);
      _drawLeaf(canvas, cutX - 20, fallY, -0.6 + cutProgress * 0.5, const Color(0xFF8D6E63));
    } else if (sceneIndex == 2) {
      // Scene 3: Organic Mist Spraying
      final mistPaint = Paint()..color = const Color(0x994DD0E1);
      final nozzleX = centerX - 90;
      final nozzleY = h * 0.30;

      // Draw Nozzle
      final nozzlePaint = Paint()..color = Colors.white70..strokeWidth = 4;
      canvas.drawLine(Offset(nozzleX - 20, nozzleY - 10), Offset(nozzleX, nozzleY), nozzlePaint);

      // Disperse mist droplets
      for (int i = 0; i < 18; i++) {
        final dropX = nozzleX + 15 + (i * 7) + math.sin(progress * 10 + i) * 10;
        final dropY = nozzleY + (i * 3) + math.cos(progress * 8 + i) * 15;
        canvas.drawCircle(Offset(dropX, dropY), 3.0, mistPaint);
      }

      // Protective glowing aura
      final auraPaint = Paint()
        ..color = const Color(0x4481C784)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(Offset(centerX, h * 0.50), 55 + math.sin(progress * math.pi * 2) * 5, auraPaint);
    } else if (sceneIndex == 3) {
      // Scene 4: Root Drip Irrigation
      final dripPaint = Paint()..color = const Color(0xFF29B6F6);
      final dripY = baseY + 4 + (progress * 20) % 25;
      canvas.drawCircle(Offset(centerX - 10, dripY), 4.5, dripPaint);
      canvas.drawCircle(Offset(centerX + 15, dripY + 4), 4.0, dripPaint);

      // Root moisture glow
      final rootPaint = Paint()..color = const Color(0x550288D1);
      canvas.drawOval(Rect.fromCenter(center: Offset(centerX, baseY + 15), width: 90, height: 25), rootPaint);
    } else if (sceneIndex == 4) {
      // Scene 5: Restored Healthy Plant & Sparkles
      final flowerPaint = Paint()..color = const Color(0xFFFFEB3B);
      canvas.drawCircle(Offset(centerX, topY - 8), 7, flowerPaint);

      // Sparkles
      final sparklePaint = Paint()..color = Colors.white;
      for (int i = 0; i < 4; i++) {
        final angle = (progress * math.pi * 2) + (i * math.pi / 2);
        final sx = centerX + math.cos(angle) * 45;
        final sy = h * 0.45 + math.sin(angle) * 35;
        canvas.drawCircle(Offset(sx, sy), 2.5, sparklePaint);
      }
    }
  }

  void _drawLeaf(Canvas canvas, double x, double y, double rotation, Color color) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);

    final leafPaint = Paint()..color = color;
    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(20, -12, 40, 0)
      ..quadraticBezierTo(20, 12, 0, 0);

    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FarmingScenePainter oldDelegate) {
    return oldDelegate.sceneIndex != sceneIndex ||
        oldDelegate.progress != progress ||
        oldDelegate.globalProgress != globalProgress;
  }
}
