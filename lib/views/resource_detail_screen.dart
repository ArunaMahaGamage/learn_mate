import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/*class ResourceDetailScreen extends StatelessWidget {
  const ResourceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Lesson lesson = ModalRoute.of(context)!.settings.arguments as Lesson;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Subject: ${lesson.subject}'),
          Text('Type: ${lesson.type}'),
          const SizedBox(height: 12),
          Text('This resource can be downloaded and used offline.'),
        ]),
      ),
    );
  }
}*/
class ResourceDetailScreen extends StatefulWidget {
  const ResourceDetailScreen({super.key});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  InAppWebViewController? webViewController;
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    final Lesson lesson = ModalRoute.of(context)!.settings.arguments as Lesson;
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Column(
        children: [
          // Linear progress indicator
          progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(lesson.downloadUrl)),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

