import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Episode.dart';
import 'dart:math';
import '../components/Carousel.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
	
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  List<dynamic> _animeList = [];
  List<dynamic> _randomAnimeList = [];
  bool _isLoading = false;
  String _apiUrl = 'https://api.i-as.dev/api/animev2';

  @override
  void initState() {
    super.initState();
    _fetchAnimeList();
  }

  void _fetchAnimeList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _animeList = (data['results'] as List)
              .take(6) // Ambil hanya 6 item pertama
              .map((anime) {
                String slug = anime['url']
                  .replaceAll(RegExp(r'https://api.i-as.dev/api/animev2/episode/'), '')
                  .replaceAll(RegExp(r'/'), '');
                return {
                  'title': anime['title'],
                  'url': slug,
                  'image': anime['image'],
                  'status': anime['status'],
                  'type': anime['type'],
                };
              })
              .toList();

          // Shuffle the anime list to randomize them
          _randomAnimeList = _animeList.toList()..shuffle(Random());
        });
      } else {
        print('Failed to load anime list, statusCode: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching anime list: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAnimeCard(Map<String, dynamic> anime) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpisodePage(epUrl: anime['url']),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getImageWidget(anime['image']),
              SizedBox(height: 8.0),
              Text(
                anime['title'],
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(Icons.star, size: 14.0, color: Colors.blue),
                  SizedBox(width: 4.0),
                  Text(
                    '${anime['status']}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  SizedBox(width: 10.0),
                  Icon(Icons.category, size: 14.0, color: Colors.blue),
                  SizedBox(width: 4.0),
                  Text(
                    '${anime['type']}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImageWidget(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          height: 250,
          width: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text('Gambar tidak tersedia'),
              );
            },
          ),
        ),
      );
    } else {
      return Icon(Icons.image_not_supported, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    Center(
					  child: Container(
					    margin: EdgeInsets.only(top: 25),
					    child: Center(
						  child: CircularProgressIndicator(),
					    ),
					  ),
                    )
                  else ...[
                    SizedBox(height: 5),
                    CarouselComponent(apiUrl: 'https://api.i-as.dev/api/animev2'),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Terbaru',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _animeList.length,
                      itemBuilder: (context, index) {
                        return _buildAnimeCard(_animeList[index]);
                      },
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Populer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _randomAnimeList.length,
                      itemBuilder: (context, index) {
                        return _buildAnimeCard(_randomAnimeList[index]);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
