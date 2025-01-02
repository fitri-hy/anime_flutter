import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Detail.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final Map<String, String> _statusOptions = {
    'Ongoing': 'ongoing',
    'Completed': 'completed',
  };
  String _selectedStatus = 'completed';
  List<Map<String, dynamic>> _animeList = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchAnimeByStatus(_selectedStatus, _currentPage);
  }

  Future<void> _fetchAnimeByStatus(String status, int page) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2/status/$status?page=$page'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _animeList = (data['results'] as List)
              .map((anime) {
                String slug = anime['url']
                  .replaceAll(RegExp(r'https://api.i-as.dev/api/animev2/detail/'), '')
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
          _isLoading = false;
        });
      } else {
        print('Failed to load anime list');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onStatusChanged(String? newStatus) {
    if (newStatus != null) {
      setState(() {
        _selectedStatus = newStatus;
        _currentPage = 1;
        _fetchAnimeByStatus(_selectedStatus, _currentPage);
      });
    }
  }

  void _nextPage() {
    _fetchAnimeByStatus(_selectedStatus, _currentPage + 1);
    setState(() {
      _currentPage++;
    });
  }

  void _prevPage() {
    if (_currentPage > 1) {
      _fetchAnimeByStatus(_selectedStatus, _currentPage - 1);
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToDetail(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(url: url),
      ),
    );
  }

  Card _buildAnimeCard(Map<String, dynamic> anime) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: () => _goToDetail(anime['url']),
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

  Row _buildPaginationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentPage > 1)
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _prevPage,
            tooltip: 'Previous',
          ),
        SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _animeList.isNotEmpty ? _nextPage : null,
          tooltip: 'Next',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Select Status',
                border: OutlineInputBorder(),
              ),
              onChanged: _onStatusChanged,
              items: _statusOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList(),
            ),
          ),
          Expanded(
		    child: Stack(
			  children: [
			    SingleChildScrollView(
				  child: Column(
				    children: [
					  if (!_isLoading)
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
					  if (_animeList.isNotEmpty && !_isLoading) _buildPaginationButtons(),
				    ],
				  ),
			    ),
			    if (_isLoading)
				Container(
				  child: Center(
					child: CircularProgressIndicator(),
				  ),
				),
			  ],
		    ),
		  ),
        ],
      ),
    );
  }
}
