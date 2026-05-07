import 'package:flutter/material.dart';

typedef TapCallback = void Function(String text);

class TextAddBar extends StatefulWidget {
  final String label;
  final TapCallback? onTap;
  final String? buttonText;
  final IconData? icon;

  const TextAddBar({
    super.key,
    required this.label,
    this.onTap,
    this.buttonText,
    this.icon,
  });

  @override
  State<TextAddBar> createState() => _TextAddBarState();
}

class _TextAddBarState extends State<TextAddBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.onTap != null) {
      _focusNode.unfocus();
      widget.onTap!(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.label,
              prefixIcon: widget.icon != null 
                  ? Icon(widget.icon, color: colorScheme.onSurfaceVariant)
                  : null,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmit(),
            onChanged: (_) => setState(() {}),
            enabled: widget.onTap != null,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: widget.onTap != null && _controller.text.trim().isNotEmpty
              ? _handleSubmit
              : null,
          child: Text(widget.buttonText ?? 'Add'),
        ),
      ],
    );
  }
}
