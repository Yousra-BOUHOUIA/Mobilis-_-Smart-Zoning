import 'package:flutter/material.dart';

class SecurityOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback? onTap;

  const SecurityOption({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.isEnabled = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return isEnabled
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Activé',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          );
  }
}