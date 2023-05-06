import 'dart:convert';
import 'package:news/news_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsData newsData = NewsData();
  int? length = 0;
  List<String> categories = [
    "technology",
    // "sports",
    // "science",
    // "health",
    // "general",
    "entertainment",
    // "business"
  ];

  List<bool> isSelected = [
    true,
    // false,
    // false,
    // false,
    // false,
    false,
    // false,
  ];

  int selectedIndex = 0;

  Future<void> fetchNews(String category) async {
   try{
     String url =
        "https://saurav.tech/NewsAPI/top-headlines/category/$category/in.json";
    var getResult = await http.get(Uri.parse(url));
    var result = json.decode(getResult.body);
    setState(() {
      newsData = NewsData.fromJson(result);
      length = newsData.articles?.length;
    });
   }catch(e){
    errorAlert(e.toString());
   }
  }

void showAlertDialog(
    BuildContext context,
    String? title,
    String? author,
    String? description,
    Image image,
  ) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      var message = "Author: $author\n\nDescription: $description";
      return AlertDialog(
        title: Text(title.toString()),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            image,
            SizedBox(height: 8),
            Text(message),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void errorAlert(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text("Error"),
            ],
          ),
          content: Text("$error\n\nCheck internet connection"),
          actions: [
            TextButton(
                onPressed: () {
                  fetchNews(categories[selectedIndex]);
                  Navigator.of(context).pop();
                },
                child: Text("retry")),
            TextButton(
              child: Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
}

  @override
  void initState() {
    fetchNews(categories[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            buildCategories(),
            SizedBox(height: 8),
            Expanded(
              child: buildNews(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNews() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () { 
              showAlertDialog(
                context, 
                newsData.articles?[index].title, 
                newsData.articles?[index].author,  
                newsData.articles?[index].description, 
                Image(image: NetworkImage(newsData.articles![index].urlToImage!)
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10, top: 20, right: 10),
              padding: const EdgeInsets.all(20),
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 189, 213, 255)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image(
                      image: NetworkImage(
                          newsData.articles![index].urlToImage.toString()),
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'Title: ${newsData.articles?[index].title!.substring(0, 20)}...',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text('Author: ${newsData.articles?[index].author}',
                        style: TextStyle(
                            color: Color.fromARGB(255, 45, 45, 45),
                            fontSize: 18)),
                  ]),
            ),
          );
        });
  }

  Widget buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            if (selectedIndex != 0) {
              selectedIndex = 0;
              fetchNews(categories[0]);
              setState(() {
                isSelected[0] = true;
                isSelected[1] = false;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10, top: 20, right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              categories[0],
              style: TextStyle(
                fontSize: 18,
                color: isSelected[0] ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (selectedIndex != 1) {
              selectedIndex = 1;
              fetchNews(categories[1]);
              setState(() {
                isSelected[1] = true;
                isSelected[0] = false;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10, top: 20, right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              categories[1],
              style: TextStyle(
                fontSize: 18,
                color: isSelected[1] ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget buildCategories() {
  //   return Container(
  //     height: 50,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: categories.length,

  //       physics: BouncingScrollPhysics(),
  //       itemBuilder: (BuildContext context, int index) {
  //         return GestureDetector(
  //           onTap: () {
  //             if (selectedIndex != index) {
  //               selectedIndex = index;
  //               fetchNews(categories[index]);
  //               print('selectedIndex: $selectedIndex,  index: $index');
  //               for (int i = 0; i < isSelected.length; i++) {
  //                 setState(() {
  //                   isSelected[i] = i == index;
  //                 });
  //               }
  //               fetchNews(categories[index]);
  //               fetchNews(categories[index]);
  //             }
  //           },
  //           child: Container(
  //             margin: const EdgeInsets.only(left: 10, top: 20, right: 10),
  //             padding: const EdgeInsets.symmetric(horizontal: 8),
  //             child: Text(
  //               categories[index],
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 color: isSelected[index] ? Colors.blue : Colors.black,
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
