import 'package:flutter/material.dart';
import 'package:airship_example/styles.dart';

typedef TapCallback = void Function(String text);

class NotificationsEnabledButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NotificationsEnabledButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
                color: Styles.airshipRed,
                shape: StadiumBorder(),
                height: 40,
                minWidth: 400,
                padding: EdgeInsets.symmetric(vertical: 35),
                onPressed: onPressed,
                child: Text(
                  "Enable Push",
                  style: Styles.homeButtonText,
                ))));
  }
}
