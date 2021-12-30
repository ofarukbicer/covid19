import 'dart:convert';
import 'dart:developer';
import '../models/covid_data.dart';
import "package:http/http.dart" as http;

Future<List<CovidData>> covidData() async {
  List<CovidData> covidData = [];

  var headers = {
    "Content-Type": "application/json",
    "authority": "interaktif.trthaber.com",
    "accept": "application/json, text/plain, */*",
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
    "sec-gpc": "1",
    "sec-fetch-site": "same-origin",
    "sec-fetch-mode": "cors",
    "sec-fetch-dest": "empty",
    "referer":
        "https://interaktif.trthaber.com/koronavirus/?map=1&counter=1&table=1&news=1&info=1",
    "accept-language": "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7",
  };

  final response = await http.get(
    Uri.parse(
      "https://interaktif.trthaber.com/koronavirus/data/coronaCountries.json",
    ),
    headers: headers,
  );
  var decodeData = jsonDecode(response.body);

  log(response.statusCode.toString());

  for (var i = 0; i < decodeData.length; i++) {
    covidData.add(
      CovidData(
        confirmedCount: decodeData[i]["cases"],
        deathCount: decodeData[i]["deaths"],
        recovryCount: decodeData[i]["recovered"],
        flagUrl: decodeData[i]["countryInfo"]["flag"],
        name: decodeData[i]["country"],
        lat: double.parse(decodeData[i]["countryInfo"]["lat"].toString()),
        long: double.parse(decodeData[i]["countryInfo"]["long"].toString()),
      ),
    );
  }

  return covidData;
}
