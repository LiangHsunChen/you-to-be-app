import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/milestone_item.dart';
import '../services/youtube_service.dart';


class InspirationScreen extends StatefulWidget {
  final List<MilestoneItem> milestoneItems;
  final String apiKey;
  const InspirationScreen({super.key, required this.milestoneItems, required this.apiKey});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> with AutomaticKeepAliveClientMixin<InspirationScreen> {
  @override
  bool get wantKeepAlive => true;
  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTube Link'),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  final Map<String, List<YoutubeVideo>> _milestoneVideos = {};
  bool _loading = false;
  String? _error;
  bool _mixedMode = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final service = YoutubeService(widget.apiKey);
    try {
      for (final milestone in widget.milestoneItems) {
  final videos = await service.searchVideos(milestone.title, maxResults: 10);
        _milestoneVideos[milestone.title] = videos;
      }
    } catch (e) {
      _error = e.toString();
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
  super.build(context);
    if (widget.milestoneItems.isEmpty) {
      return const Center(
        child: Text(
          'Add some milestones to see related videos here!',
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_milestoneVideos.isEmpty) {
      // Fetch videos if not already fetched
      _fetchVideos();
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspiration'),
        actions: [
          IconButton(
            icon: Icon(_mixedMode ? Icons.list : Icons.shuffle),
            tooltip: _mixedMode ? 'Group by Milestone' : 'Mix All Videos',
            onPressed: () {
              setState(() {
                _mixedMode = !_mixedMode;
              });
            },
          ),
        ],
      ),
      body: _mixedMode ? _buildMixedList() : _buildGroupedList(),
    );

  }

  Widget _buildGroupedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.milestoneItems.length,
      itemBuilder: (context, index) {
        final milestone = widget.milestoneItems[index];
        final videos = _milestoneVideos[milestone.title] ?? [];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: ExpansionTile(
            title: Text(
              milestone.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            children: videos.map((video) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Card(
                elevation: 2,
                child: InkWell(
                  onTap: () async {
                    final url = Uri.parse('https://www.youtube.com/watch?v=${video.videoId}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      _showUrlDialog(url.toString());
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        child: Image.network(
                          video.thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (video.formattedDuration.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Duration: ${video.formattedDuration}', style: const TextStyle(color: Colors.white70)),
                              ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                tooltip: 'Play Video',
                                onPressed: () async {
                                  final url = Uri.parse('https://www.youtube.com/watch?v=${video.videoId}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    _showUrlDialog(url.toString());
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMixedList() {
    // Combine all videos and shuffle
    final allVideos = _milestoneVideos.values.expand((v) => v).toList();
    allVideos.shuffle();
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: allVideos.length,
      itemBuilder: (context, index) {
        final video = allVideos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          elevation: 2,
          child: InkWell(
            onTap: () async {
              final url = Uri.parse('https://www.youtube.com/watch?v=${video.videoId}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                _showUrlDialog(url.toString());
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.network(
                    video.thumbnailUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (video.formattedDuration.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Duration: ${video.formattedDuration}', style: const TextStyle(color: Colors.white70)),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          tooltip: 'Play Video',
                          onPressed: () async {
                            final url = Uri.parse('https://www.youtube.com/watch?v=${video.videoId}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              _showUrlDialog(url.toString());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
