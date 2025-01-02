import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Episode.dart';

class DetailPage extends StatelessWidget {
  final String url;

  DetailPage({required this.url});

  Future<Map<String, dynamic>> fetchAnimeDetail() async {
    final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2/detail/$url'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['result'];
    } else {
      throw Exception('Failed to load anime detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Anime'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>>(
            future: fetchAnimeDetail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading data'));
              } else if (snapshot.hasData) {
                var animeDetail = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
					    child: ClipRRect(
						  borderRadius: BorderRadius.circular(5.0),
						  child: Container(
						    height: 300,
						    width: double.infinity,
						    child: Image.network(
							  animeDetail['image'],
							  fit: BoxFit.contain,
							  errorBuilder: (context, error, stackTrace) {
							    return Center(
								  child: Text('Gambar tidak tersedia'),
							    );
							  },
						    ),
						  ),
					    ),
					  ),
                      SizedBox(height: 20),
                      Text(
                        animeDetail['title'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(animeDetail['description']),
                      SizedBox(height: 15),
                      Table(
                        border: TableBorder.all(color: Colors.grey, width: 1),
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${animeDetail['status']}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Studio', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${animeDetail['studio']}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Released', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${animeDetail['released']}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Season', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${animeDetail['season']}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${animeDetail['type']}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Updated on', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${animeDetail['updatedOn']}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text('Episodes:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      animeDetail['episodes'].isEmpty
                          ? Card(
                              margin: EdgeInsets.all(5.0),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
							  color: Color(0xFFa30026),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                title: Text('Episode tidak tersedia untuk saat ini,', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              ),
                            )
                          : ListView.builder(
                              itemCount: animeDetail['episodes'].length,
                              itemBuilder: (context, index) {
                                var episode = animeDetail['episodes'][index];
                                String slug = episode['epUrl']
                                  .replaceFirst('https://api.i-as.dev/api/animev2/episode/', '')
                                  .replaceAll(RegExp(r'/$'), ''); // Remove trailing slash if exists

                                return Card(
                                  margin: EdgeInsets.all(5.0),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    title: Text(episode['epTitle'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    subtitle: Text('Episode: ${episode['epNo']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EpisodePage(epUrl: slug),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                            ),
                    ],
                  ),
                );
              } else {
                return Center(child: Text('No data available'));
              }
            },
          ),
        ),
      ),
    );
  }
}
