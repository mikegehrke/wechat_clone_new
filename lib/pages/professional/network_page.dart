import 'package:flutter/material.dart';
import '../../models/professional.dart';
import '../../services/professional_service.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProfessionalProfile> _connections = [];
  List<ProfessionalProfile> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNetwork();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNetwork() async {
    setState(() => _isLoading = true);
    
    try {
      final connections = await ProfessionalService.getConnections('demo_user_1');
      final suggestions = await ProfessionalService.getConnectionSuggestions('demo_user_1');
      
      setState(() {
        _connections = connections;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Network'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0077B5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0077B5),
          tabs: [
            Tab(text: 'Connections (${_connections.length})'),
            Tab(text: 'Suggestions (${_suggestions.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConnectionsList(),
                _buildSuggestionsList(),
              ],
            ),
    );
  }

  Widget _buildConnectionsList() {
    if (_connections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No connections yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _connections.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final profile = _connections[index];
        return _buildConnectionCard(profile, isConnected: true);
      },
    );
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No suggestions available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final profile = _suggestions[index];
        return _buildConnectionCard(profile, isConnected: false);
      },
    );
  }

  Widget _buildConnectionCard(ProfessionalProfile profile, {required bool isConnected}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Text(
                profile.firstName[0],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.firstName} ${profile.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile.headline,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    profile.currentCompany,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            isConnected
                ? IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () {},
                    color: const Color(0xFF0077B5),
                  )
                : ElevatedButton(
                    onPressed: () => _connect(profile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B5),
                    ),
                    child: const Text('Connect'),
                  ),
          ],
        ),
      ),
    );
  }

  void _connect(ProfessionalProfile profile) {
    // Add connection logic
    setState(() {
      _suggestions.remove(profile);
      _connections.add(profile);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connected with ${profile.firstName} ${profile.lastName}')),
    );
  }
}
