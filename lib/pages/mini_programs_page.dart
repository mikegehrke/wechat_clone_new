import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/mini_programs_service.dart';

class MiniProgramsPage extends StatefulWidget {
  const MiniProgramsPage({super.key});

  @override
  State<MiniProgramsPage> createState() => _MiniProgramsPageState();
}

class _MiniProgramsPageState extends State<MiniProgramsPage> {
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> _allPrograms = [];
  List<Map<String, dynamic>> _recentPrograms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final all = await MiniProgramsService.getMiniPrograms();
      final recent = await MiniProgramsService.getRecentMiniPrograms(_currentUserId);
      
      setState(() {
        _allPrograms = all;
        _recentPrograms = recent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchProgram(String programId, String name) async {
    await MiniProgramsService.launchMiniProgram(
      programId: programId,
      userId: _currentUserId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Launched: $name')),
      );
    }

    await _loadPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Programs'),
        actions: [
          IconButton(
            onPressed: () {
              // Search
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent
                  if (_recentPrograms.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Recently Used',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recentPrograms.length,
                        itemBuilder: (context, index) {
                          final program = _recentPrograms[index];
                          return _buildProgramCard(program, isHorizontal: true);
                        },
                      ),
                    ),
                  ],

                  // All Programs
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'All Mini Programs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _allPrograms.length,
                    itemBuilder: (context, index) {
                      final program = _allPrograms[index];
                      return _buildProgramCard(program);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program, {bool isHorizontal = false}) {
    return InkWell(
      onTap: () => _launchProgram(program['id'], program['name']),
      child: Container(
        width: isHorizontal ? 100 : null,
        margin: isHorizontal ? const EdgeInsets.only(left: 16) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  program['icon'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              program['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
