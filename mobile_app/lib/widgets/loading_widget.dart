import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingWidget({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? Theme.of(context).primaryColor,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: color ?? Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}