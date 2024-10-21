import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';
import 'package:flutter/services.dart' show SystemChannels;

typedef TapCallback = void Function(String text);

class TextAddBar extends StatelessWidget {
  final String label;
  final TapCallback onTap;
  final controller = TextEditingController();
  final focusNode = FocusNode();

  TextAddBar({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration:
                    InputDecoration(border: InputBorder.none, hintText: label),
                cursorColor: Styles.airshipBlue,
              ),
            ),
            GestureDetector(
              onTap: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                onTap(controller.text);
              },
              child: Icon(
                Icons.add,
                semanticLabel: label,
                color: Styles.airshipBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
