import 'package:flutter/material.dart';

class DefaultCoverPhoto extends StatelessWidget {
  const DefaultCoverPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[300]!,
            Colors.purple[300]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.landscape,
          size: 60,
          color: Colors.white54,
        ),
      ),
    );
  }
}
