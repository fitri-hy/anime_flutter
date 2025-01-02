import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'GenreDetail.dart';

class GenrePage extends StatelessWidget {
  const GenrePage({super.key});

  Future<List<Map<String, dynamic>>> fetchGenres() async {
    final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2/genres'));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('genres') && data['genres'] is List) {
          final List genres = data['genres'];
          return genres
              .where((item) => item is Map<String, dynamic> && item.containsKey('name') && item.containsKey('url'))
              .map((item) => {
                    'name': item['name'],
                    'url': item['url'].split('/').last,
                  })
              .toList();
        } else {
          throw Exception('Invalid "genres" data format');
        }
      } catch (e) {
        throw Exception('Failed to parse JSON: $e');
      }
    } else {
      throw Exception('Failed to load genres with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchGenres(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No genres found'),
            );
          }

          final genres = snapshot.data!;
          return ListView.builder(
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  title: Text(genre['name'] ?? 'Unknown'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenreDetailPage(
                          name: genre['name'] ?? 'Unknown',
                          url: genre['url'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
