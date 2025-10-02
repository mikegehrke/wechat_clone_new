import 'package:flutter/material.dart';
import '../../models/professional.dart';
import '../../services/professional_service.dart';

class ProfessionalProfilePage extends StatefulWidget {
  final ProfessionalProfile profile;

  const ProfessionalProfilePage({super.key, required this.profile});

  @override
  State<ProfessionalProfilePage> createState() => _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfessionalProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0077B5),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showMoreOptions,
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF0077B5),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF0077B5),
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Experience'),
                    Tab(text: 'Skills'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(),
            _buildExperienceTab(),
            _buildSkillsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0077B5), Color(0xFF005885)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  _profile.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0077B5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_profile.firstName} ${_profile.lastName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _profile.headline,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profile.currentCompany,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatButton(
                    '${_profile.connectionsCount}',
                    'Connections',
                    () {},
                  ),
                  const SizedBox(width: 24),
                  _buildStatButton(
                    '0', // Posts count not in model
                    'Posts',
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0077B5),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Connect'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _sendMessage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatButton(String value, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _profile.summary,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.location_on, 'Location', _profile.location),
        _buildInfoRow(Icons.email, 'Email', 'contact@example.com'),
        _buildInfoRow(Icons.phone, 'Phone', '+1 (555) 123-4567'),
        _buildInfoRow(Icons.link, 'Website', 'www.example.com'),
      ],
    );
  }

  Widget _buildExperienceTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Work Experience',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildExperienceItem(
          'Senior Software Engineer',
          _profile.currentCompany,
          'Jan 2022 - Present',
          'Leading development of mobile applications and mentoring junior developers.',
        ),
        _buildExperienceItem(
          'Software Engineer',
          'Previous Company Inc.',
          'Jan 2019 - Dec 2021',
          'Developed and maintained web applications using React and Node.js.',
        ),
        _buildExperienceItem(
          'Junior Developer',
          'Startup Co.',
          'Jun 2017 - Dec 2018',
          'Built features for the main product and learned modern development practices.',
        ),
      ],
    );
  }

  Widget _buildSkillsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Skills & Endorsements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ..._profile.skills.map((skill) => _buildSkillItem(skill)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String duration, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillItem(String skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              skill,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Endorse'),
          ),
        ],
      ),
    );
  }

  void _connect() {
    // In real app, would update connection status
    ProfessionalService.toggleConnect(_profile.id, 'demo_user_1');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Connection request sent'),
      ),
    );
  }

  void _sendMessage() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening chat...')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
