import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';
import 'package:airship_example/screens/message_view.dart';
import 'package:intl/intl.dart';

class MessageCenter extends StatefulWidget {
  const MessageCenter({super.key});

  @override
  MessageCenterState createState() => MessageCenterState();
}

class MessageCenterState extends State<MessageCenter> {
  @override
  void initState() {
    super.initState();
    _initAirshipListeners();
    Airship.analytics.trackScreen('Message Center');
  }

  Future<void> _initAirshipListeners() async {
    Airship.messageCenter.onInboxUpdated.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<bool?> _onRefresh() async {
    return await Airship.messageCenter.refreshInbox();
  }

  Future<void> _deleteMessage(InboxMessage message) async {
    await Airship.messageCenter.deleteMessage(message.messageId);
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDate(int sentDateMillis) {
    final date = DateTime.fromMillisecondsSinceEpoch(sentDateMillis);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.EEEE().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Center'),
        actions: [
          FutureBuilder<List<InboxMessage>>(
            future: Airship.messageCenter.messages,
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];
              final unreadCount = messages.where((m) => !m.isRead).length;
              
              if (unreadCount == 0) return const SizedBox.shrink();
              
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount unread',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<InboxMessage>>(
        future: Airship.messageCenter.messages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return _EmptyState(colorScheme: colorScheme);
          }

          return RefreshIndicator(
            onRefresh: () async => await _onRefresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _MessageCard(
                  message: message,
                  formattedDate: _formatDate(message.sentDate),
                  onTap: () => _openMessage(message),
                  onDelete: () => _deleteMessage(message),
                  colorScheme: colorScheme,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openMessage(InboxMessage message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageView(messageId: message.messageId),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final InboxMessage message;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;

  const _MessageCard({
    required this.message,
    required this.formattedDate,
    required this.onTap,
    required this.onDelete,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(message.messageId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: colorScheme.error,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Message'),
              content: const Text('Are you sure you want to delete this message?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) {
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: message.isRead 
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    message.isRead 
                        ? Icons.mark_email_read_outlined 
                        : Icons.mark_email_unread,
                    color: message.isRead 
                        ? colorScheme.onSurfaceVariant 
                        : colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: message.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!message.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;

  const _EmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your inbox is empty',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await Airship.messageCenter.refreshInbox();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
