import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/app_localization.dart';
import '../providers/farm_provider.dart';
import '../widgets/language_toggle_chip.dart';
import '../widgets/animated_farming_video.dart';

class EducationPortalScreen extends StatefulWidget {
  final String? recommendedTopic;
  final String? cropName;

  const EducationPortalScreen({
    super.key,
    this.recommendedTopic,
    this.cropName,
  });

  @override
  State<EducationPortalScreen> createState() => _EducationPortalScreenState();
}

class _EducationPortalScreenState extends State<EducationPortalScreen> {
  // Video Tutorials Database (Simple Language + Practical Video Content)
  final List<Map<String, dynamic>> _videos = [
    {
      'id': 'v1',
      'title': 'How to Treat Tomato Leaf Spot & Early Blight Naturally',
      'topic': 'Tomato Disease Control',
      'duration': '3:15 min',
      'category': 'Leaf Spot',
      'thumbnailColor': const Color(0xFF2A9D8F),
      'icon': Icons.play_circle_fill,
      'summary': 'Learn how to identify brown target-ring spots on lower tomato leaves, prune diseased stems safely, and apply organic Neem oil spray to save your harvest.',
      'steps': [
        '1. Pluck off spotted lower leaves closest to the ground.',
        '2. Mix 5ml Neem oil + 1ml mild soap in 1 liter water.',
        '3. Spray early in the morning every 7 days.',
        '4. Water only near the root base (avoid splashing leaves).'
      ],
      'views': '14.2K views'
    },
    {
      'id': 'v2',
      'title': 'Controlling Tomato & Potato Wet Rot in Damp Weather',
      'topic': 'Fungal Rot Prevention',
      'duration': '4:10 min',
      'category': 'Late Blight',
      'thumbnailColor': const Color(0xFFE76F51),
      'icon': Icons.play_circle_fill,
      'summary': 'Understand why dark wet patches appear on leaf tips during rainy or cloudy weather and how copper spray creates a protective shield.',
      'steps': [
        '1. Stop overhead sprinkler watering immediately.',
        '2. Heap soil 15cm high around root bases (earthing up).',
        '3. Apply Copper Oxychloride (2g/liter water) before heavy rain.',
        '4. Bury rotten plants deep in soil outside your field.'
      ],
      'views': '21.5K views'
    },
    {
      'id': 'v3',
      'title': 'Corn Red Rust Spotting & Simple Sulfur Spray',
      'topic': 'Corn Pest & Rust Control',
      'duration': '2:50 min',
      'category': 'Common Rust',
      'thumbnailColor': const Color(0xFFF4A261),
      'icon': Icons.play_circle_fill,
      'summary': 'Recognize small rusty powder spots on corn leaves and use simple wettable sulfur to stop the infection before tasseling.',
      'steps': [
        '1. Inspect lower leaves when humidity is above 80%.',
        '2. Mix 2.5g Wettable Sulfur powder per liter of clean water.',
        '3. Spray both leaf tops and undersides.',
        '4. Maintain 30cm spacing between corn rows for air circulation.'
      ],
      'views': '18.9K views'
    },
    {
      'id': 'v4',
      'title': 'Snail, Slug & Caterpillar Defense Without Poison',
      'topic': 'Biological Pest Control',
      'duration': '3:45 min',
      'category': 'Pest Defense',
      'thumbnailColor': const Color(0xFF264653),
      'icon': Icons.play_circle_fill,
      'summary': 'Protect vegetable seedlings from nocturnal snails, armyworms, and stem borers using ash barriers and pheromone lures.',
      'steps': [
        '1. Scatter wood ash or coarse sand rings around seedling beds.',
        '2. Set up yellow sticky traps (10 per acre) for flying whiteflies.',
        '3. Place pheromone traps 1 meter above crop canopy.',
        '4. Encourage frogs and ladybug beetles in your field edges.'
      ],
      'views': '32.1K views'
    },
    {
      'id': 'v5',
      'title': 'Drip Irrigation Maintenance & Saving 50% Water',
      'topic': 'Water & Irrigation',
      'duration': '4:30 min',
      'category': 'Irrigation',
      'thumbnailColor': const Color(0xFF1D3557),
      'icon': Icons.play_circle_fill,
      'summary': 'Keep drip emitters from clogging, clean disc filters, and apply organic straw mulch to keep root soil moist during hot summer days.',
      'steps': [
        '1. Flush lateral drip pipes once every week.',
        '2. Clean main disc filter after every fertilizer feeding.',
        '3. Lay 5-8cm straw mulch around plant root base.',
        '4. Apply for Govt PMKSY Drip Subsidy (up to 55% discount).'
      ],
      'views': '27.4K views'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isTamil = context.watch<FarmProvider>().isTamil;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isTamil ? 'விவசாயக் கற்றல் தளம்' : 'Farmer Education Portal'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: LanguageToggleChip(isCompact: true),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: const Color(0xFF72796F),
            tabs: [
              Tab(icon: const Icon(Icons.play_circle_outline), text: isTamil ? '🎥 வீடியோ வழிகாட்டல்' : '🎥 Video Tutorials'),
              Tab(icon: const Icon(Icons.menu_book_outlined), text: isTamil ? 'சிறந்த நடைமுறைகள்' : 'Best Practices'),
              Tab(icon: const Icon(Icons.bug_report_outlined), text: isTamil ? 'பூச்சி மேலாண்மை' : 'Pest Management'),
              Tab(icon: const Icon(Icons.science_outlined), text: isTamil ? 'மண் & ஊட்டச்சத்து' : 'Soil & Nutrients'),
              Tab(icon: const Icon(Icons.water_drop_outlined), text: isTamil ? 'பாசனம் & திட்டங்கள்' : 'Water & Schemes'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Dynamic Recommended Topic Banner when opened from a Scan
            if (widget.recommendedTopic != null) _buildRecommendedBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildVideosTab(),
                  _buildBestPracticesTab(),
                  _buildPestManagementTab(),
                  _buildSoilNutrientsTab(),
                  _buildWaterAndSchemesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        border: Border(bottom: BorderSide(color: AppTheme.primaryGreen, width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_display, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECOMMENDED FOR YOUR RECENT SCAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.cleanLabel(widget.recommendedTopic ?? 'Crop Care Guide'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (ctx, i) {
        final video = _videos[i];
        final isHighlighted = widget.recommendedTopic != null &&
            (video['title'].toString().toLowerCase().contains(widget.recommendedTopic!.toLowerCase()) ||
                video['category'].toString().toLowerCase().contains(widget.recommendedTopic!.toLowerCase()));

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isHighlighted
                ? const BorderSide(color: AppTheme.primaryGreen, width: 2)
                : BorderSide.none,
          ),
          elevation: isHighlighted ? 4 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Thumbnail Banner
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: video['thumbnailColor'] as Color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(video['icon'] as IconData, size: 48, color: Colors.white),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Tap to Watch Video • ${video['duration']}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isHighlighted)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'RECOMMENDED MATCH',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            video['topic'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          video['views'] as String,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF72796F)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video['title'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.25),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video['summary'] as String,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF434940), height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openVideoModal(video),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Watch Video & Practical Steps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openVideoModal(Map<String, dynamic> video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Animated Farming Video Player
              AnimatedFarmingVideo(
                title: video['title'] as String,
                topic: video['topic'] as String,
                category: video['category'] as String,
                steps: (video['steps'] as List<String>),
                themeColor: video['thumbnailColor'] as Color,
              ),
              const SizedBox(height: 16),

              Text(
                video['title'] as String,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Target Topic: ${video['topic']}',
                style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 20),

              // 1. Simple Explanation
              const Text(
                '💡 SIMPLE EXPLANATION:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), letterSpacing: 0.4),
              ),
              const SizedBox(height: 4),
              Text(
                video['summary'] as String,
                style: const TextStyle(fontSize: 13, color: Color(0xFF2C3E33), height: 1.35),
              ),
              const SizedBox(height: 14),

              // 2. Why It Matters
              const Text(
                '🌱 WHY IT MATTERS TO YOUR HARVEST:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B4332), letterSpacing: 0.4),
              ),
              const SizedBox(height: 4),
              const Text(
                'Early intervention prevents pathogen spread to adjacent rows, preserves green leaf canopy area, and prevents severe yield reduction.',
                style: TextStyle(fontSize: 13, color: Color(0xFF2C3E33), height: 1.35),
              ),
              const SizedBox(height: 14),

              // 3. Step-by-Step Prevention & Action
              const Text(
                '📋 STEP-BY-STEP ACTION PROTOCOL:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF72796F), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...((video['steps'] as List<String>).map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF264653), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ))),
              const SizedBox(height: 14),

              // 4. Do's and Don'ts
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAF9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5EAE5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('DO\'S & DON\'TS:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF141F17))),
                    SizedBox(height: 6),
                    Text('✓ DO prune diseased leaves early in the morning when canopy is dry.', style: TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                    SizedBox(height: 3),
                    Text('✓ DO use drip or root-zone watering to keep foliage moisture low.', style: TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                    SizedBox(height: 3),
                    Text('✗ DON\'T splash muddy water or flood overhead during humid evenings.', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
                    SizedBox(height: 3),
                    Text('✗ DON\'T leave plucked diseased stems rotting inside the crop bed.', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. When to Seek Expert Help
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.phone_in_talk, color: Color(0xFFB45309), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WHEN TO SEEK EXPERT HELP: If symptoms spread rapidly across more than 20% of your crop canopy within 48 hours despite bio-sprays, call Kisan Helpline 1800-180-1551 or visit your nearest Krishi Vigyan Kendra (KVK).',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close Guide'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestPracticesTab() {
    final practices = [
      {
        'title': 'Simple Crop Rotation',
        'desc': 'Switch crops every season (e.g. Tomato -> Beans -> Corn). This starves soil pests and naturally keeps soil fertile without costly chemicals.',
        'icon': Icons.sync,
        'tag': 'SOIL HEALTH'
      },
      {
        'title': 'Summer Deep Plowing',
        'desc': 'Plow soil 25cm deep during hot summer months. Hot sunlight kills hidden weed seeds and pest eggs naturally.',
        'icon': Icons.wb_sunny,
        'tag': 'PREVENTIVE'
      },
      {
        'title': 'Certified Seed Care',
        'desc': 'Treat seeds with Trichoderma (10g per kg seed) before sowing to protect young sprouts from root rot.',
        'icon': Icons.verified,
        'tag': 'SEED CARE'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: practices.length,
      itemBuilder: (ctx, i) => _buildArticleCard(practices[i]),
    );
  }

  Widget _buildPestManagementTab() {
    final pests = [
      {
        'title': 'Homemade Organic Neem Spray',
        'desc': 'Mix 5ml Neem Oil + 1ml liquid soap in 1 liter water. Spray early morning to stop aphids, whiteflies, and caterpillars naturally.',
        'icon': Icons.eco,
        'tag': 'ORGANIC SPRAY'
      },
      {
        'title': 'Yellow Sticky Traps',
        'desc': 'Place yellow sticky boards across your field at crop height to catch whiteflies and flying pests before they multiply.',
        'icon': Icons.flag_outlined,
        'tag': 'SIMPLE TRAP'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pests.length,
      itemBuilder: (ctx, i) => _buildArticleCard(pests[i]),
    );
  }

  Widget _buildSoilNutrientsTab() {
    final nutrients = [
      {
        'title': 'Fixing Yellow Leaves (Lack of Nitrogen)',
        'desc': 'If bottom leaves turn yellow, your crop needs Nitrogen. Add organic compost or spray 1% Urea solution.',
        'icon': Icons.grass,
        'tag': 'NUTRIENT CARE'
      },
      {
        'title': 'Fixing Burnt Leaf Edges (Lack of Potassium)',
        'desc': 'If outer leaf edges look burnt or brown, apply Sulfate of Potash or organic ash around root bases.',
        'icon': Icons.flare,
        'tag': 'LEAF STRESS'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nutrients.length,
      itemBuilder: (ctx, i) => _buildArticleCard(nutrients[i]),
    );
  }

  Widget _buildWaterAndSchemesTab() {
    final items = [
      {
        'title': 'Drip Irrigation Tips',
        'desc': 'Drip watering saves 50% water and keeps leaves dry, preventing leaf spot fungal diseases.',
        'icon': Icons.water_drop,
        'tag': 'SAVE WATER'
      },
      {
        'title': 'Government PMKSY Drip Subsidy',
        'desc': 'Get up to 55% government financial subsidy for installing drip & sprinkler systems in your field.',
        'icon': Icons.account_balance,
        'tag': 'GOVT SCHEME'
      },
      {
        'title': 'Free Kisan Helpline Number',
        'desc': 'Call toll-free 1800-180-1551 (6:00 AM to 10:00 PM) to speak with agricultural officers in your language.',
        'icon': Icons.phone_in_talk,
        'tag': 'FREE HELPLINE'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildArticleCard(items[i]),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.lightSage,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppTheme.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['tag'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item['desc'] as String,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF434940),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
