import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speehive_social/core/di/providers.dart';
import 'package:speehive_social/core/utils/extensions.dart';
import 'package:speehive_social/presentation/social/screens/draft_list_screen.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> {
  int _pendingDrafts = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    final draftService = ref.read(draftStorageServiceProvider);
    final count = await draftService.getPendingCount();
    if (mounted) {
      setState(() => _pendingDrafts = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Accounts'),
        actions: [
          if (_pendingDrafts > 0)
            Badge(
              label: Text('$_pendingDrafts'),
              child: IconButton(
                icon: const Icon(Icons.article_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DraftListScreen(),
                    ),
                  ).then((_) => _loadPendingCount());
                },
              ),
            ),
        ],
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
              const SizedBox(height: 32),
              if (_pendingDrafts > 0)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DraftListScreen(),
                        ),
                      ).then((_) => _loadPendingCount());
                    },
                    icon: const Icon(Icons.article),
                    label: Text('View $_pendingDrafts Pending Drafts'),
                  ),
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
