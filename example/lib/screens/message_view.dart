import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class MessageView extends StatefulWidget {
  final String messageId;

  const MessageView({super.key, required this.messageId});

  @override
  MessageViewState createState() => MessageViewState();
}

class MessageViewState extends State<MessageView> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Airship.analytics.trackScreen('Message View');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<InboxMessage>>(
      future: Airship.messageCenter.messages,
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        
        final message = messages.firstWhereOrNull(
          (thisMessage) => widget.messageId == thisMessage.messageId,
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            title: Text(
              message?.title ?? 'Message',
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (message != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'delete':
                        _confirmDelete(context, message);
                        break;
                      case 'mark_unread':
                        Airship.messageCenter.markRead(
                          widget.messageId,
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_unread',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_unread_outlined),
                          SizedBox(width: 12),
                          Text('Mark as unread'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: colorScheme.error),
                          const SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: Stack(
            children: [
              if (_hasError)
                _ErrorView(
                  errorMessage: _errorMessage,
                  onRetry: () {
                    setState(() {
                      _hasError = false;
                      _isLoading = true;
                    });
                  },
                  colorScheme: colorScheme,
                )
              else
                InboxMessageView(
                  messageId: widget.messageId,
                  onLoadStarted: _handleLoadStarted,
                  onLoadFinished: _handleLoadFinished,
                  onLoadError: _handleLoadError,
                  onClose: _handleClose,
                ),
              if (_isLoading && !_hasError)
                Container(
                  color: colorScheme.surface.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading message...',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleLoadStarted() {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
  }

  void _handleLoadFinished() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLoadError(PlatformException e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.message ?? "Unable to load message";
      });
    }
  }

  void _handleClose() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete(BuildContext context, InboxMessage message) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (confirmed == true && mounted) {
      await Airship.messageCenter.deleteMessage(message.messageId);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted')),
      );
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final ColorScheme colorScheme;

  const _ErrorView({
    this.errorMessage,
    required this.onRetry,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An error occurred',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
