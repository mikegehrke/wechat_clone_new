import 'package:flutter/material.dart';
import 'video_editor_page.dart';
import 'video_editor_advanced_page.dart';
import 'tiktok_feed_page.dart';
import 'stories_page.dart';
import 'dating_page.dart';
import 'shopping_page.dart';
import 'delivery_page.dart';
import 'games_page.dart';
import 'professional_page.dart';
import 'streaming_page.dart';
import 'payment_page.dart';
import 'social_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Social',
            items: [
              _buildDiscoverItem(
                icon: Icons.camera_alt,
                title: 'Stories',
                subtitle: 'Instagram-style stories',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StoriesPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.qr_code_scanner,
                title: 'Scan',
                subtitle: 'Scan QR codes and barcodes',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR scanner feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.vibration,
                title: 'Shake',
                subtitle: 'Shake to find people nearby',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shake feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.edit,
                title: 'Video Editor',
                subtitle: 'Simple video editing',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoEditorPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.auto_awesome,
                title: 'Video Editor Pro',
                subtitle: 'Professional editing (Bearbeiter weit)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoEditorAdvancedPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.play_circle_outline,
                title: 'TikTok Feed',
                subtitle: 'Short videos like TikTok',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TikTokFeedPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.favorite,
                title: 'Dating',
                subtitle: 'Tinder-style dating app',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DatingPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Services',
            items: [
              _buildDiscoverItem(
                icon: Icons.shopping_cart,
                title: 'Shopping',
                subtitle: 'Amazon/eBay style shopping',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShoppingPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.games,
                title: 'Games',
                subtitle: 'Mobile games platform',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamesPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.restaurant,
                title: 'Food Delivery',
                subtitle: 'Uber Eats style delivery',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeliveryPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Utilities',
            items: [
              _buildDiscoverItem(
                icon: Icons.payment,
                title: 'Payments',
                subtitle: 'Send and receive money',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payments feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.location_on,
                title: 'Location',
                subtitle: 'Share your location',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location sharing feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.translate,
                title: 'Translate',
                subtitle: 'Translate messages instantly',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Translation feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.business,
                title: 'Professional',
                subtitle: 'LinkedIn-style networking',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfessionalPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.play_circle,
                title: 'Streaming',
                subtitle: 'YouTube/Netflix style streaming',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StreamingPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.payment,
                title: 'Universal Payments',
                subtitle: 'PayPal/Stripe - Pay everywhere',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentPage(),
                    ),
                  );
                },
              ),
              _buildDiscoverItem(
                icon: Icons.groups,
                title: 'Social Network',
                subtitle: 'Facebook/Snapchat style social',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SocialPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDiscoverItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF07C160).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF07C160),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}