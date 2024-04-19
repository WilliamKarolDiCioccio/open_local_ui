import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_local_ui/layout/page_base.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBaseLayout(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'OpenLocalUI',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text('Di Cioccio William Karol'),
            ],
          ),
          SizedBox(height: 32),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Powered by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Flutter'),
                  SizedBox(width: 8),
                  Text('LangChain'),
                  SizedBox(width: 8),
                  Text('Ollama'),
                  SizedBox(width: 8),
                  Text('Supabase'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
