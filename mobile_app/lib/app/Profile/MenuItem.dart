import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color textColor;

  const MenuItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: textColor.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}