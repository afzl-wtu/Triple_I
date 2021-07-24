import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LanguagesScreen())),
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text(
              EasyLocalization.of(context).locale.languageCode == 'en'
                  ? 'English'
                  : 'עברית',
            ),
          ),
        ],
      ),
    );
  }
}

class LanguagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.separated(
        itemBuilder: (_, i) => ListTile(
          title: Text(i == 0 ? 'English' : 'עברית‎'),
          onTap: () => context.setLocale(
            Locale(i == 0 ? 'en' : 'he'),
          ),
        ),
        separatorBuilder: (_, __) => Divider(),
        itemCount: 2,
      ),
    );
  }
}
