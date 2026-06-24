import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/core/di/providers.dart';
import 'package:speehive_social/core/utils/extensions.dart';
import 'package:speehive_social/presentation/chat/notifier/chat_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  bool _outlookConnected = false;
  bool _linkedinConnected = false;
  bool _googleCalendarConnected = false;

  @override
  void initState() {
    super.initState();
    _baseUrlController.text = ApiConfig.baseUrl;
    _modelController.text = ApiConfig.defaultModel;
    _checkConnectionStatus();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectionStatus() async {
    final outlookService = ref.read(outlookOAuthServiceProvider);
    final linkedinService = ref.read(linkedinOAuthServiceProvider);
    final googleCalendarService = ref.read(googleCalendarOAuthServiceProvider);

    final outlookAuth = await outlookService.isAuthenticated();
    final linkedinAuth = await linkedinService.isAuthenticated();
    final googleCalendarAuth = await googleCalendarService.isAuthenticated();

    if (mounted) {
      setState(() {
        _outlookConnected = outlookAuth;
        _linkedinConnected = linkedinAuth;
        _googleCalendarConnected = googleCalendarAuth;
      });
    }
  }

  void _saveConfig() {
    ref.read(chatProvider.notifier).updateConfig(
          apiKey: _apiKeyController.text.isNotEmpty
              ? _apiKeyController.text
              : null,
          baseUrl: _baseUrlController.text.isNotEmpty
              ? _baseUrlController.text
              : null,
          model: _modelController.text.isNotEmpty
              ? _modelController.text
              : null,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved')),
    );
  }

  Future<void> _connectOutlook() async {
    final outlookService = ref.read(outlookOAuthServiceProvider);
    final authUrl = outlookService.getAuthorizationUrl();
    await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    // Note: In production, you'd need a deep link handler to capture the callback
  }

  Future<void> _disconnectOutlook() async {
    final outlookService = ref.read(outlookOAuthServiceProvider);
    await outlookService.logout();
    setState(() => _outlookConnected = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outlook disconnected')),
      );
    }
  }

  Future<void> _connectLinkedIn() async {
    final linkedinService = ref.read(linkedinOAuthServiceProvider);
    
    final redirectUri = await linkedinService.startCallbackServer(port: 34217);
    if (redirectUri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start authentication server')),
        );
      }
      return;
    }

    final authUrl = linkedinService.getAuthorizationUrl(redirectUri: redirectUri);
    await launchUrl(authUrl, mode: LaunchMode.externalApplication);

    final code = await linkedinService.waitForAuthorizationCode();
    await linkedinService.stopCallbackServer();

    if (code != null) {
      final tokens = await linkedinService.exchangeCodeForTokens(code);
      if (tokens != null) {
        setState(() => _linkedinConnected = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('LinkedIn connected successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to authenticate with LinkedIn')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication cancelled or failed')),
        );
      }
    }
  }

  Future<void> _disconnectLinkedIn() async {
    final linkedinService = ref.read(linkedinOAuthServiceProvider);
    await linkedinService.logout();
    setState(() => _linkedinConnected = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LinkedIn disconnected')),
      );
    }
  }

  Future<void> _connectGoogleCalendar() async {
    final googleCalendarService = ref.read(googleCalendarOAuthServiceProvider);
    final success = await googleCalendarService.signIn();
    if (mounted) {
      setState(() => _googleCalendarConnected = success);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Calendar connected')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Calendar connection failed')),
        );
      }
    }
  }

  Future<void> _disconnectGoogleCalendar() async {
    final googleCalendarService = ref.read(googleCalendarOAuthServiceProvider);
    await googleCalendarService.signOut();
    setState(() => _googleCalendarConnected = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Calendar disconnected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('API Configuration', cs),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('API Key',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: ApiConfig.apiKey.isNotEmpty
                          ? '${ApiConfig.apiKey.substring(0, 8)}...'
                          : 'sk-...',
                      hintStyle: TextStyle(color: cs.onSurfaceVariant.withAlpha(80)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Base URL',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://api.opencode.ai/v1',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Model',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      hintText: 'gpt-4o-mini',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveConfig,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Configuration'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Connected Accounts', cs),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _googleCalendarConnected
                          ? Colors.red.withAlpha(20)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: _googleCalendarConnected ? Colors.red : cs.onSurfaceVariant,
                    ),
                  ),
                  title: const Text('Google Calendar'),
                  subtitle: Text(
                    _googleCalendarConnected ? 'Connected' : 'Not connected',
                    style: TextStyle(
                      color: _googleCalendarConnected ? Colors.red : cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: _googleCalendarConnected
                      ? TextButton(
                          onPressed: _disconnectGoogleCalendar,
                          child: const Text('Disconnect'),
                        )
                      : FilledButton.tonal(
                          onPressed: _connectGoogleCalendar,
                          child: const Text('Connect'),
                        ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _outlookConnected
                          ? Colors.green.withAlpha(20)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: _outlookConnected ? Colors.green : cs.onSurfaceVariant,
                    ),
                  ),
                  title: const Text('Microsoft Outlook'),
                  subtitle: Text(
                    _outlookConnected ? 'Connected' : 'Not connected',
                    style: TextStyle(
                      color: _outlookConnected ? Colors.green : cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: _outlookConnected
                      ? TextButton(
                          onPressed: _disconnectOutlook,
                          child: const Text('Disconnect'),
                        )
                      : FilledButton.tonal(
                          onPressed: _connectOutlook,
                          child: const Text('Connect'),
                        ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _linkedinConnected
                          ? Colors.blue.withAlpha(20)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.work,
                      color: _linkedinConnected ? Colors.blue : cs.onSurfaceVariant,
                    ),
                  ),
                  title: const Text('LinkedIn'),
                  subtitle: Text(
                    _linkedinConnected ? 'Connected' : 'Not connected',
                    style: TextStyle(
                      color: _linkedinConnected ? Colors.blue : cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: _linkedinConnected
                      ? TextButton(
                          onPressed: _disconnectLinkedIn,
                          child: const Text('Disconnect'),
                        )
                      : FilledButton.tonal(
                          onPressed: _connectLinkedIn,
                          child: const Text('Connect'),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('About', cs),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                  title: const Text('Version'),
                  trailing: Text(AppConstants.appVersion,
                      style: context.textTheme.bodyMedium),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.terminal, color: cs.onSurfaceVariant),
                  title: const Text('AI SDK'),
                  trailing: Text('ai_sdk_dart',
                      style: context.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
