import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../widgets/fighter_card.dart';
import '../services/history_service.dart';

class ResultScreen extends StatefulWidget {
  final String blueName;
  final String redName;
  final String belt;
  final String promptType;
  final bool isGi;

  const ResultScreen({
    super.key,
    required this.blueName,
    required this.redName,
    required this.belt,
    required this.promptType,
    required this.isGi,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _bluePrompt = '';
  String _redPrompt = '';
  String _blueSubtitle = '';
  String _redSubtitle = '';

  int _blueScore = 0;
  int _redScore = 0;

  int _roundSeconds = 0;
  int _remainingSeconds = 0;
  bool _timerRunning = false;
  Timer? _timer;

  final _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

void _generate() {
  if (_timerRunning) return;
  _timer?.cancel();
  final minutes = movesService.randomRoundTime();
  setState(() {
    _roundSeconds = minutes * 60;
    _remainingSeconds = _roundSeconds;
    _timerRunning = false;
    _blueScore = 0;
    _redScore = 0;
  });

    if (widget.promptType == 'submission') {
      final pair =
          movesService.randomSubmissionPair(widget.belt, widget.isGi);
      setState(() {
        _bluePrompt = pair[0]?.name ?? 'None found';
        _redPrompt = pair[1]?.name ?? 'None found';
        _blueSubtitle = pair[0]?.description ?? '';
        _redSubtitle = pair[1]?.description ?? '';
      });
    } else {
      final pair =
          movesService.randomPositionPair(widget.belt, widget.isGi);
      setState(() {
        _bluePrompt = pair?.blueRole ?? 'None found';
        _redPrompt = pair?.redRole ?? 'None found';
        _blueSubtitle = pair?.name ?? '';
        _redSubtitle = pair?.name ?? '';
      });
    }
  }

  void _rerollBlue() {
    if (_timerRunning) return;
    if (widget.promptType == 'submission') {
      final s = movesService.randomSubmission(widget.belt, widget.isGi);
      setState(() {
        _bluePrompt = s?.name ?? _bluePrompt;
        _blueSubtitle = s?.description ?? '';
      });
    } else {
      final p = movesService.randomPositionPair(widget.belt, widget.isGi);
      setState(() {
        _bluePrompt = p?.blueRole ?? _bluePrompt;
        _redPrompt = p?.redRole ?? _redPrompt;
        _blueSubtitle = p?.name ?? '';
        _redSubtitle = p?.name ?? '';
      });
    }
  }

  void _rerollRed() {
    if (_timerRunning) return;
    if (widget.promptType == 'submission') {
      final s = movesService.randomSubmission(widget.belt, widget.isGi);
      setState(() {
        _redPrompt = s?.name ?? _redPrompt;
        _redSubtitle = s?.description ?? '';
      });
    } else {
      final p = movesService.randomPositionPair(widget.belt, widget.isGi);
      setState(() {
        _bluePrompt = p?.blueRole ?? _bluePrompt;
        _redPrompt = p?.redRole ?? _redPrompt;
        _blueSubtitle = p?.name ?? '';
        _redSubtitle = p?.name ?? '';
      });
    }
  }

  Future<void> _playBuzzer() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/buzzer.wav'));
    } catch (_) {}
  }

  Future<void> _saveMatch() async {
    await _historyService.save(MatchResult(
      blueName: widget.blueName,
      redName: widget.redName,
      blueScore: _blueScore,
      redScore: _redScore,
      bluePrompt: _bluePrompt,
      redPrompt: _redPrompt,
      belt: widget.belt,
      isGi: widget.isGi,
      promptType: widget.promptType,
      date: DateTime.now(),
    ));
  }

  void _showWinnerDialog() {
    final blueWins = _blueScore > _redScore;
    final redWins = _redScore > _blueScore;
    final isDraw = _blueScore == _redScore;
    final winner = blueWins
        ? widget.blueName
        : redWins
            ? widget.redName
            : null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDraw ? '🤝' : '🏆',
                style: const TextStyle(fontSize: 52),
              ),
              const SizedBox(height: 16),
              Text(
                isDraw ? 'It\'s a Draw!' : 'Well done, $winner!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.blueName}  $_blueScore — $_redScore  ${widget.redName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.history,
                        color: Colors.white38, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Match saved to History',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTimer() {
    if (_timerRunning) {
      _timer?.cancel();
      setState(() => _timerRunning = false);
    } else {
      if (_remainingSeconds == 0) return;
      setState(() => _timerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (_remainingSeconds <= 1) {
          _timer?.cancel();
          setState(() {
            _remainingSeconds = 0;
            _timerRunning = false;
          });
          await _playBuzzer();
          await _saveMatch();
          if (mounted) _showWinnerDialog();
        } else {
          setState(() => _remainingSeconds--);
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _roundSeconds;
      _timerRunning = false;
      _blueScore = 0;
      _redScore = 0;
    });
  }

  String get _timerDisplay {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _remainingSeconds < 30
        ? const Color(0xFFE63946)
        : _remainingSeconds < 60
            ? const Color(0xFFFFB347)
            : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RanJitzu',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFE63946),
                          )),
                      Text(
                        '${widget.promptType == 'submission' ? 'SUBMISSION HUNT' : 'STARTING POSITION'} • ${widget.isGi ? 'GI' : 'NO-GI'}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Scoreboard
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    // Blue score
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.blueName,
                            style: const TextStyle(
                                color: Color(0xFF3A86FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                          Text(
                            '$_blueScore',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF3A86FF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timer
                    Column(
                      children: [
                        Text(
                          _timerDisplay,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: timerColor,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleTimer,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _timerRunning
                                      ? Colors.orange.withOpacity(0.2)
                                      : const Color(0xFFE63946)
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _timerRunning
                                        ? Colors.orange
                                        : const Color(0xFFE63946),
                                  ),
                                ),
                                child: Icon(
                                  _timerRunning
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: _timerRunning
                                      ? Colors.orange
                                      : const Color(0xFFE63946),
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _resetTimer,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.white24),
                                ),
                                child: const Icon(Icons.refresh,
                                    color: Colors.white54, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Red score
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.redName,
                            style: const TextStyle(
                                color: Color(0xFFE63946),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                          Text(
                            '$_redScore',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFE63946),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scoring buttons
              Row(
                children: [
                  Expanded(
                    child: _ScoreButtons(
                      isBlue: true,
                      onScore: (b) => setState(() => _blueScore++),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreButtons(
                      isBlue: false,
                      onScore: (b) => setState(() => _redScore++),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Blue card
              FighterCard(
                name: widget.blueName,
                prompt: _bluePrompt,
                subtitle: _blueSubtitle,
                cornerColor: const Color(0xFF3A86FF),
                cornerLabel: 'BLUE',
                belt: widget.belt,
                onReroll: _rerollBlue,
                demoUrl: null,
                locked: _timerRunning,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: const [
                    Expanded(
                        child: Divider(
                            color: Colors.white12, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('VS',
                          style: TextStyle(
                            color: Colors.white24,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 4,
                          )),
                    ),
                    Expanded(
                        child: Divider(
                            color: Colors.white12, thickness: 1)),
                  ],
                ),
              ),

              // Red card
              FighterCard(
                name: widget.redName,
                prompt: _redPrompt,
                subtitle: _redSubtitle,
                cornerColor: const Color(0xFFE63946),
                cornerLabel: 'RED',
                belt: widget.belt,
                onReroll: _rerollRed,
                demoUrl: null,
                locked: _timerRunning,
              ),

              const SizedBox(height: 20),

              // Generate Again
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                onPressed: _timerRunning ? null : _generate,
                icon: Icon(Icons.refresh,
                    color: _timerRunning ? Colors.white24 : Colors.white),
                label: Text('GENERATE AGAIN',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: _timerRunning ? Colors.white24 : Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _timerRunning
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFE63946),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: _timerRunning ? 0 : 8,
                  shadowColor: const Color(0xFFE63946).withOpacity(0.4),
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

class _ScoreButtons extends StatelessWidget {
  final bool isBlue;
  final Function(bool isBlue) onScore;

  const _ScoreButtons({
    required this.isBlue,
    required this.onScore,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isBlue ? const Color(0xFF3A86FF) : const Color(0xFFE63946);

    return GestureDetector(
      onTap: () => onScore(isBlue),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              '+1 Point',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}