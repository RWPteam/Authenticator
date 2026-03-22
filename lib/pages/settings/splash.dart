// settings_main_page.dart
import 'package:neap/main.dart';
import 'package:flutter/material.dart';
import '../../services/setting_service.dart';
import 'theme.dart';
import 'global.dart';
import '../../l10n/app_localizations.dart';

class SettingsMainPage extends StatefulWidget {
  const SettingsMainPage({super.key});

  @override
  State<SettingsMainPage> createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends State<SettingsMainPage> with RouteAware {
  final SettingsService _settingsService = SettingsService();

  List<Map<String, dynamic>> _getLocalizedMenuItems(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      {
        'title': localizations.globalSettings,
        'subtitle': localizations.globalSettingsSubtitle,
        'icon': Icons.settings,
      },
      {
        'title': localizations.themeSettings,
        'subtitle': localizations.themeSettingsSubtitle,
        'icon': Icons.palette,
      },
      {
        'title': localizations.about,
        'subtitle': localizations.aboutSubtitle,
        'icon': Icons.info,
      },
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onSettingsChanged() async {
    await MyApp.of(context)?.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getLocalizedMenuItems(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settings)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: menuItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'],
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                item['title'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(item['subtitle']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GlobalSettingsPage(
                        settingsService: _settingsService,
                        onSettingsChanged: _onSettingsChanged,
                      ),
                    ),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThemeSettingsPage(
                        settingsService: _settingsService,
                        onSettingsChanged: _onSettingsChanged,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LicensePage()),
                  );
                }
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          );
        },
      ),
    );
  }
}
