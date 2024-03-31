import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

const String apiKey = 'NcervrPwjsV3d2qJQ9i9qmwGZbk45hdC';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giphy Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color.fromARGB(255, 177, 169, 169),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> gifs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PhyGi',
            style: GoogleFonts.mitr(textStyle: TextStyle(color: Colors.white))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหา GIF',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    fetchGifs(_searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                fetchGifs(value);
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: gifs.isEmpty
                ? Center(
                    child: Text('ไม่พบ GIF',
                        style: GoogleFonts.mitr(
                            textStyle: TextStyle(color: Colors.white))),
                  )
                : StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    itemCount: gifs.length,
                    itemBuilder: (context, index) {
                      final gif = gifs[index];
                      return GestureDetector(
                        onTap: () => launchUrl(gif['url']),
                        child: Card(
                          elevation: 4.0,
                          margin: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: CachedNetworkImage(
                              imageUrl: gif['images']['fixed_height']['url'],
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
          ),
          ElevatedButton(
            onPressed: () {
              fetchRandomGif();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text('สุ่ม GIF ',
                style: GoogleFonts.mitr(
                    textStyle: TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }

  Future<void> fetchGifs(String query) async {
    final apiUrl = Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=$apiKey&q=$query&limit=20');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        gifs = data['data'];
      });
    } else {
      throw Exception('Failed to load gifs');
    }
  }

  Future<void> fetchRandomGif() async {
    final random = Random();
    final randomOffset = random.nextInt(1000);

    final apiUrl = Uri.parse(
        'https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=20&offset=$randomOffset');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        gifs = data['data'];
      });
    } else {
      throw Exception('Failed to load random gifs');
    }
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
