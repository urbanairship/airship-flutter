import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';

typedef void TapCallback(String text);

class TextAddBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final TapCallback onTap;

  TextAddBar({
    @required this.controller,
    @required this.focusNode,
    @required this.label,
    @required this.onTap,
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
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: label
                ),
                //tyle: Styles,
                cursorColor: Styles.airshipBlue,
              ),
            ),
            GestureDetector(
              onTap: () {
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
