import 'package:flutter/material.dart';
import 'package:speehive_social/core/utils/extensions.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Accounts'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.add_circle_outline,
                    size: 36, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 24),
              Text(
                'Connect Your Accounts',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Link your social media accounts to start automating posts, scheduling content, and tracking analytics.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _platformButton('Twitter / X', Icons.alternate_email, cs),
                  _platformButton('LinkedIn', Icons.work_outline, cs),
                  _platformButton('Instagram', Icons.camera_alt_outlined, cs),
                  _platformButton('Facebook', Icons.facebook, cs),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _platformButton(String name, IconData icon, ColorScheme cs) {
    return SizedBox(
      width: 160,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(name),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
    );
  }
}
