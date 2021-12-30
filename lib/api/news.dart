import 'dart:convert';
import 'dart:developer';
import '../models/news_api.dart';
import "package:http/http.dart" as http;

Future<List<NewsApi>> newsApi(String country) async {
  List<NewsApi> newsApi = [];

  var headers = {
    "Content-Type": "application/json",
  };

  final response = await http.get(
    Uri.parse(
      "https://newsapi.org/v2/top-headlines?country=$country&category=health&apiKey=61f03705160640d4b847b0cd54e16999",
    ),
    headers: headers,
  );
  var decodeData = jsonDecode(response.body);

  log(response.statusCode.toString());

  for (var i = 0; i < decodeData["articles"].length; i++) {
    newsApi.add(
      NewsApi(
        author: decodeData["articles"][i]["author"] ?? "",
        title: decodeData["articles"][i]["title"] ?? "",
        description: decodeData["articles"][i]["description"] ?? "",
        url: decodeData["articles"][i]["url"] ?? "",
        urlToImage: decodeData["articles"][i]["urlToImage"] ?? "",
        content: decodeData["articles"][i]["content"] ?? "",
      ),
    );
  }

  return newsApi;
}
