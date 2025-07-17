import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieCustomView extends StatelessWidget {
  final Map<String, dynamic> properties;

  const LottieCustomView({
    Key? key,
    required this.properties,
  }) : super(key: key);

  String? get animationUrl => properties['animationUrl'] as String?;

  @override
  Widget build(BuildContext context) {
    if (animationUrl == null || animationUrl!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.animation,
                size: 48,
                color: Colors.grey[600],
              ),
              SizedBox(height: 8),
              Text(
                'No animation URL provided',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Lottie.network(
          animationUrl!,
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load animation',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
          frameBuilder: (context, child, composition) {
            if (composition == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            return child;
          },
        ),
      ),
    );
  }
}
