import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_local_ui/layout/page_base.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBaseLayout(
      body: Center(
        child: _buildGrid(),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      children: List.generate(
        3,
        (index) => _buildCard(index),
      ),
    );
  }

  Widget _buildCard(int index) {
    const List<String> titles = [
      'GitHub - OpenLocalUI',
      'GitHub - WilliamKarolDiCioccio',
      'Instagram - Wilielmus',
    ];

    const List<String> links = [
      'https://github.com/WilliamKarolDiCioccio/open_local_ui',
      'https://github.com/WilliamKarolDiCioccio',
      'https://www.instagram.com/wilielmus/',
    ];

    return Card(
      child: Center(
        child: GestureDetector(
          onTap: () {
            final url = Uri.parse(links[index]);
            launchUrl(url);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titles[index],
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(width: 8.0),
              const Icon(
                UniconsLine.link,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
