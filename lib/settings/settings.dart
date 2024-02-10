// change share app link.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:vr2dconverter/settings/contact_us.dart';
import 'package:vr2dconverter/settings/how_to_use.dart';
import 'package:vr2dconverter/settings/privacy_policy.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Settings")),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "Buy Ad Free Version",
                  overflow: TextOverflow.fade,
                ),
                onTap: () {},
              ),
              ListTile(
                title: Text(
                  "How To Use",
                  overflow: TextOverflow.fade,
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => HowTo()));
                },
              ),
              ListTile(
                  title: Text("Share the app"),
                  onTap: () {
                    Share.share("Download the app: www.google.com");
                  }),
              ListTile(
                title: Text("Contact Us"),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ContactUs()));
                },
              ),
              ListTile(
                title: Text("Privacy Policy"),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                },
              ),
            ],
          ),
        )));
  }
}
