import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EpisodePage extends StatefulWidget {
  final String epUrl;

  EpisodePage({required this.epUrl});

  @override
  _EpisodePageState createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage> {
  late InAppWebViewController _webViewController;
  bool _isVideoInitialized = false;
  bool _showReloadButton = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final data = await fetchEpisodeDetails();
      setState(() {
        _isVideoInitialized = true;
        _showReloadButton = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isVideoInitialized = false;
        _showReloadButton = true;
        _errorMessage = 'Video failed to load. Please try again or check your connection.';
      });
    }
  }

  Future<Map<String, dynamic>> fetchEpisodeDetails() async {
    try {
      final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2/episode/${widget.epUrl}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['result'] != null) {
          return data['result'];
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load episode details, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load episode details');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _webViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Episode Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchEpisodeDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading episode details'),
                  if (_showReloadButton)
                    ElevatedButton(
                      onPressed: _initializeVideoPlayer,
                      child: Text('Reload Data'),
                    ),
                  if (_errorMessage != null) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isVideoInitialized)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: InAppWebView(
                          initialUrlRequest: URLRequest(url: WebUri(data['videoUrl'])),
                          initialOptions: InAppWebViewGroupOptions(
                            android: AndroidInAppWebViewOptions(useHybridComposition: true),
                          ),
                          onWebViewCreated: (controller) {
                            _webViewController = controller;
                          },
                          onLoadError: (controller, url, code, message) {
                            setState(() {
                              _errorMessage = 'Video failed to load: $message';
                              _isVideoInitialized = false;
                              _showReloadButton = true;
                            });
                          },
                        ),
                      ),
                    )
                  else
                    Center(child: CircularProgressIndicator()),
                  SizedBox(height: 16),
                  Text(
                    data['title'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(data['description']),
                  SizedBox(height: 15),
                  buildInfoTable(data),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget buildInfoTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.grey, width: 1),
      children: [
        buildTableRow('Studio', data['studio']),
        buildTableRow('Released', data['released']),
        buildTableRow('Season', data['season']),
        buildTableRow('Director', data['director']),
        buildTableRow('Producers', data['producers']),
        buildTableRow('Status', data['status']),
        buildTableRow('Type', data['type']),
        buildTableRow('Censor', data['censor']),
      ],
    );
  }

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value ?? 'N/A'),
        ),
      ],
    );
  }
}
