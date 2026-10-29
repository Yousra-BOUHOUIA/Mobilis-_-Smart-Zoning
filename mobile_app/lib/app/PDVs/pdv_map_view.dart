import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:myapp/app/services/pdv_service.dart';

class PDVMapView extends StatefulWidget {
  final List<Map<String, dynamic>> pdvList;

  const PDVMapView({
    Key? key,
    required this.pdvList,
  }) : super(key: key);

  @override
  State<PDVMapView> createState() => _PDVMapViewState();
}

class _PDVMapViewState extends State<PDVMapView> {
  late final WebViewController controller;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Loading page: $url');
          },
          onPageFinished: (String url) {
            print('Page loaded: $url');
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            setState(() {
              this.error = 'Error loading map: ${error.description}';
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('http://192.168.18.68:8000/optimal_path_map'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDV Map View'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        error = null;
                        isLoading = true;
                      });
                      controller.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 