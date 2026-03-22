import 'package:flutter/material.dart';
import '../../services/setting_service.dart';
import '../../l10n/app_localizations.dart';

class GlobalSettingsPage extends StatefulWidget {
  final SettingsService settingsService;
  final Function() onSettingsChanged;

  const GlobalSettingsPage({
    super.key,
    required this.settingsService,
    required this.onSettingsChanged,
  });

  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  bool _isLoading = true;
  String _language = 'system';
  bool _requireBiometrics = true;

  final List<String> _languages = ['system', 'zh', 'en', 'ja'];

  Map<String, String> _getLanguageMap(BuildContext context) {
    return {
      'system': AppLocalizations.of(context).followSystem,
      'zh': AppLocalizations.of(context).chinese,
      'en': AppLocalizations.of(context).english,
      'ja': AppLocalizations.of(context).japanese,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.settingsService.getSettings();
    setState(() {
      _language = settings.language;
      _requireBiometrics = settings.requireBiometrics;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    try {
      final currentSettings = await widget.settingsService.getSettings();
      final newSettings = currentSettings.copyWith(
        language: _language,
        requireBiometrics: _requireBiometrics,
      );
      await widget.settingsService.saveSettings(newSettings);

      widget.onSettingsChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).saveSettingsError),
          ),
        );
      }
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).languageSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _languages.map((lang) {
                return RadioListTile<String>(
                  title: Text(_getLanguageMap(context)[lang]!),
                  value: lang,
                  groupValue: _language,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _language = value;
                      });
                      _saveSettings();
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).globalSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(AppLocalizations.of(context).languageSettings),
              subtitle: Text(_getLanguageMap(context)[_language] ?? 'unknown'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showLanguageDialog,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: Text(AppLocalizations.of(context).enableBiometric),
              subtitle: Text(AppLocalizations.of(context).biometricDescription),
              value: _requireBiometrics,
              onChanged: (value) {
                setState(() {
                  _requireBiometrics = value;
                });
                _saveSettings();
              },
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
