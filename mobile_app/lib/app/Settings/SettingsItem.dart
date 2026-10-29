import 'package:flutter/material.dart';


class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBackgroundColor;
  final double iconSize;
  final EdgeInsets contentPadding;
  final TextStyle titleStyle;

  SettingItem({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor = Colors.green,
    Color? iconBackgroundColor,
    this.iconSize = 24.0,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 4.0),
    this.titleStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
  }) : iconBackgroundColor = iconBackgroundColor ?? iconColor.withOpacity(0.1),
       super(key: key);

  @override
  Widget build(BuildContext context) {
   return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
      title: Text(
        title,
        style: titleStyle,
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}