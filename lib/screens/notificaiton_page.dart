import 'package:flutter/material.dart';
import '/widgets/manga_card.dart';

class NotificationModel {
  final String id;
  final String title;
  final String author;
  final double rating;
  final int chapters;
  final String thumbnail;
  final DateTime time;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.chapters,
    required this.thumbnail,
    required this.time,
    this.isRead = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Solo Leveling',
      author: '',
      rating: 9.2,
      chapters: 187,
      thumbnail: 'https://via.placeholder.com/120x160.png?text=Solo+Leveling',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationModel(
      id: '2',
      title: 'Kaiju No. 8',
      author: '',
      rating: 9.2,
      chapters: 85,
      thumbnail: 'https://via.placeholder.com/120x160.png?text=Kaiju+No.+8',
      time: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: '3',
      title: 'One Piece',
      author: '',
      rating: 9.2,
      chapters: 1092,
      thumbnail: 'https://via.placeholder.com/120x160.png?text=One+Piece',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark all read',
            onPressed: _markAllRead,
          )
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = _notifications[index];

                return Dismissible(
                  key: ValueKey(notif.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeNotification(notif.id),
                  child: Stack(
                    children: [
                      // Using the existing MangaCard widget for visual display.
                      // Expected MangaCard signature: MangaCard({title, imageUrl, subtitle, onTap})
                      MangaCard(
                        title: notif.title,
                        imageUrl: notif.thumbnail,
                        author: notif.author ,
                        chapters: notif.chapters,
                        rating:notif.rating,
                        // onTap: () {
                        //   setState(() => notif.isRead = true);
                        //   // TODO: Navigate to chapter reader page
                        //   // Navigator.pushNamed(context, '/reader', arguments: {...});
                        // },
                      ),
                      // Unread badge
                      if (!notif.isRead)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox.shrink(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}