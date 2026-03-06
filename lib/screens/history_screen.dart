import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  List<MatchResult> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final matches = await _historyService.load();
    setState(() {
      _matches = matches;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    await _historyService.clear();
    setState(() => _matches = []);
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _winner(MatchResult m) {
    if (m.blueScore > m.redScore) return m.blueName;
    if (m.redScore > m.blueScore) return m.redName;
    return 'Draw';
  }

  String _shortPrompt(String prompt) {
    if (prompt.contains(' — ')) return prompt.split(' — ')[0];
    return prompt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'History',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFE63946),
                            ),
                          ),
                          Text(
                            '${_matches.length} matches recorded',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_matches.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1A2E),
                            title: const Text('Clear History',
                                style: TextStyle(color: Colors.white)),
                            content: const Text(
                                'Delete all match history?',
                                style: TextStyle(color: Colors.white54)),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.white38)),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Clear',
                                    style: TextStyle(
                                        color: Color(0xFFE63946))),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) _clearAll();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE63946).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFE63946)
                                  .withOpacity(0.4)),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                              color: Color(0xFFE63946), fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // List
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _matches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.history,
                                    color: Colors.white12, size: 64),
                                const SizedBox(height: 16),
                                const Text(
                                  'No matches yet',
                                  style: TextStyle(
                                      color: Colors.white24,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Matches are saved when the timer runs out',
                                  style: TextStyle(
                                      color: Colors.white12,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _matches.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final m = _matches[i];
                              final winner = _winner(m);
                              final isDraw = winner == 'Draw';
                              return Dismissible(
                                key: Key('match_${m.date.toIso8601String()}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding:
                                      const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE63946)
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFE63946)
                                            .withOpacity(0.4)),
                                  ),
                                  child: const Icon(
                                      Icons.delete_outline,
                                      color: Color(0xFFE63946),
                                      size: 24),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor:
                                          const Color(0xFF1A1A2E),
                                      title: const Text('Delete Match',
                                          style: TextStyle(
                                              color: Colors.white)),
                                      content: const Text(
                                          'Remove this match from history?',
                                          style: TextStyle(
                                              color: Colors.white54)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.white38)),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete',
                                              style: TextStyle(
                                                  color:
                                                      Color(0xFFE63946))),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (_) async {
                                  await _historyService.deleteAt(i);
                                  setState(() => _matches.removeAt(i));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.white12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Names + score
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  m.blueName,
                                                  style: const TextStyle(
                                                    color:
                                                        Color(0xFF3A86FF),
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  m.redName,
                                                  style: const TextStyle(
                                                    color:
                                                        Color(0xFFE63946),
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Score
                                          Row(
                                            children: [
                                              Text(
                                                '${m.blueScore}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 28,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  color: const Color(
                                                      0xFF3A86FF),
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Text('—',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.white38,
                                                        fontSize: 20)),
                                              ),
                                              Text(
                                                '${m.redScore}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 28,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  color: const Color(
                                                      0xFFE63946),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Prompts
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '🔵 ${m.bluePrompt.isNotEmpty ? _shortPrompt(m.bluePrompt) : '—'}',
                                              style: const TextStyle(
                                                  color: Color(0xFF3A86FF),
                                                  fontSize: 11),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '🔴 ${m.redPrompt.isNotEmpty ? _shortPrompt(m.redPrompt) : '—'}',
                                              style: const TextStyle(
                                                  color: Color(0xFFE63946),
                                                  fontSize: 11),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Winner + tags
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDraw
                                                  ? Colors.white
                                                      .withOpacity(0.1)
                                                  : const Color(0xFFE63946)
                                                      .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isDraw
                                                  ? 'Draw'
                                                  : '🏆 $winner',
                                              style: TextStyle(
                                                color: isDraw
                                                    ? Colors.white38
                                                    : Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.06),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${m.belt[0].toUpperCase()}${m.belt.substring(1)} • ${m.isGi ? 'Gi' : 'No-Gi'} • ${m.promptType == 'submission' ? 'Sub Hunt' : 'Position'}',
                                              style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatDate(m.date),
                                        style: const TextStyle(
                                            color: Colors.white24,
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}