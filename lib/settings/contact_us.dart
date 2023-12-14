import 'package:flutter/material.dart';
import "package:url_launcher/url_launcher.dart";

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final controllerTo = TextEditingController();
  final controllerSubject = TextEditingController();
  final controllerMessage = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact Us")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField(title: 'To', controller: controllerTo, maxlines: 1),
            const SizedBox(
              height: 16,
            ),
            buildTextField(
                title: 'Subject', controller: controllerSubject, maxlines: 1),
            SizedBox(
              height: 16,
            ),
            buildTextField(
                title: 'Message', controller: controllerMessage, maxlines: 8),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => launchEmail(
                  toEmail: controllerTo.text,
                  subject: controllerSubject.text,
                  message: controllerMessage.text),
              child: Text("Send"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                textStyle: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future launchEmail(
    {required String toEmail,
    required String subject,
    required String message}) async {
  final email = Uri.encodeFull(toEmail);
  final emailSubject = Uri.encodeFull(subject);
  final emailBody = Uri.encodeFull(message);

  final url = "mailto:$email?subject=$emailSubject&body=$emailBody";

  
 
}

buildTextField(
    {required String title,
    required TextEditingController controller,
    required int maxlines}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: 8,
      ),
      TextField(
        controller: controller,
        decoration: InputDecoration(border: OutlineInputBorder()),
        maxLines: maxlines,
      ),
    ],
  );
}
