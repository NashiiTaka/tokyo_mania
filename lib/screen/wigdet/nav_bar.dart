import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final String duration;
  final String distance;
  final String time;
  final VoidCallback onEndNavigation;

  const NavBar({
    Key? key,
    required this.duration,
    required this.distance,
    required this.time,
    required this.onEndNavigation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                duration,
                style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '$distance・$time',
                style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.black),
                  onPressed: () {
                    // ルート変更ロジックをここに実装
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onEndNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('終了', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}