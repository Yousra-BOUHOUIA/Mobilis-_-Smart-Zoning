import 'package:flutter/material.dart';
import 'package:mobilis/pages/assignment_table.dart';
import 'package:mobilis/pages/homepage.dart';
import 'package:mobilis/pages/zones_page.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE9F4EB),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Transform.scale(
                  scale: 3,
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/images/mobilis-logo.png',
                    height: 50,
                  ),
                ),
              ),
              const Text(
                'Ensemble, nous construisons le future',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FooterColumn(items: {
                'Accueil': SmartZoningHomePage(),
                'Zones': MapPage(),
                'Affectations': const AssignmentTablePage(),
              }),
              _FooterColumn(items: {
                'Paramètres': const PlaceholderPage(title: 'Paramètres'),
                'Terms and Polices': const PlaceholderPage(title: 'Terms and Policies'),
                'Conditions et Politiques': const PlaceholderPage(title: 'Conditions et Politiques'),
              }),
              _FooterColumn(items: {
                'Facebook': const PlaceholderPage(title: 'Facebook'),
                'Instagram': const PlaceholderPage(title: 'Instagram'),
                'WhatsApp': const PlaceholderPage(title: 'WhatsApp'),
              }),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final Map<String, Widget> items;

  const _FooterColumn({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.entries.map((entry) {
        return _HoverableText(label: entry.key, destination: entry.value);
      }).toList(),
    );
  }
}

class _HoverableText extends StatefulWidget {
  final String label;
  final Widget destination;

  const _HoverableText({required this.label, required this.destination});

  @override
  State<_HoverableText> createState() => _HoverableTextState();
}

class _HoverableTextState extends State<_HoverableText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => widget.destination),
          );
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _isHovered ? Colors.green.shade800 : Colors.grey,
            fontSize: _isHovered ? 16 : 14,
            fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
            decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title page coming soon...')),
    );
  }
}
