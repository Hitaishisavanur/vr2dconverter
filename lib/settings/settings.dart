import 'package:flutter/material.dart';
import 'package:vr2dconverter/settings/contact_us.dart';

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
                  "Buy Premium Version",
                  overflow: TextOverflow.fade,
                ),
                onTap: () {},
              ),
              ListTile(
                title: Text(
                  "How To Use",
                  overflow: TextOverflow.fade,
                ),
                onTap: () {},
              ),
              ListTile(
                title: Text("Rate Us"),
                onTap: () {},
              ),
              ListTile(
                title: Text("Contact Us"),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ContactUs()));
                },
              ),
              ListTile(
                title: Text("Privacy Policy"),
                onTap: () {},
              ),
            ],
          ),
        )));
  }
}
