import 'package:flutter/material.dart';
import '../../models/professional.dart';
import '../../services/professional_service.dart';

class JobDetailPage extends StatefulWidget {
  final JobPosting job;

  const JobDetailPage({super.key, required this.job});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  late JobPosting _job;
  bool _isSaved = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _isSaved = false; // Track save state locally
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleSave,
            color: _isSaved ? const Color(0xFF0077B5) : null,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareJob,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Company logo and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _job.companyName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _job.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _job.companyName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _job.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Job type, level, salary chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.work_outline, _job.jobType),
                    _buildInfoChip(Icons.trending_up, _job.experienceLevel),
                    if (_job.salaryMin != null && _job.salaryMax != null)
                      _buildInfoChip(Icons.attach_money, '\$${_job.salaryMin!.toInt()}k - \$${_job.salaryMax!.toInt()}k'),
                    _buildInfoChip(
                      Icons.calendar_today,
                      'Posted ${_formatPostedTime(_job.postedDate)}',
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                
                // Job description
                _buildSection(
                  'Job Description',
                  _job.description,
                ),
                
                const SizedBox(height: 24),
                
                // Responsibilities
                _buildSection(
                  'Responsibilities',
                  null,
                  bulletPoints: [
                    'Lead and manage development team',
                    'Design and implement scalable solutions',
                    'Collaborate with cross-functional teams',
                    'Mentor junior developers',
                    'Code review and quality assurance',
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Requirements
                _buildSection(
                  'Requirements',
                  null,
                  bulletPoints: _job.requirements,
                ),
                
                const SizedBox(height: 24),
                
                // Skills
                const Text(
                  'Required Skills',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _job.requirements.map((skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.blue[50],
                    labelStyle: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  )).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Benefits
                _buildSection(
                  'Benefits',
                  null,
                  bulletPoints: [
                    'Competitive salary and equity',
                    'Health, dental, and vision insurance',
                    'Flexible working hours',
                    'Remote work options',
                    'Professional development budget',
                    '401(k) matching',
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Company info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About the Company',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Leading technology company specializing in innovative solutions. We are committed to building a diverse and inclusive workplace.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _viewCompanyProfile,
                        icon: const Icon(Icons.business),
                        label: const Text('View Company Profile'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
          
          // Apply button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isApplying ? null : _applyForJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isApplying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Apply Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String? content, {List<String>? bulletPoints}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (content != null)
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        if (bulletPoints != null)
          ...bulletPoints.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0077B5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }

  String _formatPostedTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    
    ProfessionalService.toggleSaveJob(_job.id, 'demo_user_1');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Job saved' : 'Job unsaved'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareJob() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to...'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyForJob() async {
    // Show application dialog
    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for this job?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Position: ${_job.title}'),
            Text('Company: ${_job.companyName}'),
            const SizedBox(height: 16),
            const Text('Your resume and profile will be sent to the employer.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077B5),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (apply != true) return;

    setState(() => _isApplying = true);

    try {
      await ProfessionalService.applyForJob(_job.id, 'demo_user_1');
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Color(0xFF0077B5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  void _viewCompanyProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening company profile...')),
    );
  }
}
