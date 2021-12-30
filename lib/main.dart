import 'package:covid19/api/covid.dart';
import 'package:covid19/api/news.dart';
import 'package:covid19/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

// Debug
// import 'dart:developer';

import 'models/country_information.dart';
import 'models/covid_data.dart';
import 'models/news_api.dart';

void main() {
  runApp(Covid19());
}

class Covid19 extends StatelessWidget {
  const Covid19({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid19',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Circle> circles = [];
  List<CovidData> covid = [];
  GoogleMapController? _mapController;
  double zoom = 4;
  double pinPillPosition = -100;
  CountryInformation? countryInformation;
  bool mapPinShow = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<NewsApi> lastNews = [];

  void _onMapCreated(GoogleMapController _cntlr) {
    _mapController = _cntlr;
    _mapController!.setMapStyle(mapStyle);
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    if (zoom != cameraPosition.zoom) {
      setState(() {
        zoom = cameraPosition.zoom;
      });
      asyncMethod();
    }
  }

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  getNewsApi(String country) async {
    List<NewsApi> news = await newsApi(country);
    setState(() {
      lastNews = news;
    });
  }

  void asyncMethod() async {
    List<CovidData> covid = await covidData();
    setState(() {
      circles = [];
    });
    for (var i = 0; i < covid.length; i++) {
      setState(() {
        circles.add(
          Circle(
            circleId: CircleId(i.toString()),
            center: LatLng(covid.elementAt(i).lat, covid.elementAt(i).long),
            radius:
                (covid.elementAt(i).confirmedCount / (10 * zoom)).toDouble(),
            fillColor: Color.fromRGBO(19, 80, 162, 0.75),
            strokeColor: Color.fromRGBO(19, 80, 162, 1),
            strokeWidth: 2,
            consumeTapEvents: true,
            onTap: () async {
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target:
                        LatLng(covid.elementAt(i).lat, covid.elementAt(i).long),
                    zoom: 4,
                  ),
                ),
              );
              setState(() {
                countryInformation = CountryInformation(
                  countryName: covid.elementAt(i).name,
                  confirmedCount: covid.elementAt(i).confirmedCount.toString(),
                  deathCount: covid.elementAt(i).deathCount.toString(),
                  recovryCount: covid.elementAt(i).recovryCount.toString(),
                  flag: covid.elementAt(i).flagUrl,
                  labelColor: Color.fromRGBO(19, 80, 162, 0.75),
                );
              });
              await getNewsApi(
                covid.elementAt(i).flagUrl.split("/").last.substring(0, 2),
              );
              await showSlidingBottomSheet(context, builder: (context) {
                return SlidingSheetDialog(
                  cornerRadius: 16,
                  snapSpec: const SnapSpec(
                    snap: true,
                    snappings: [0.25, 0.50],
                    positioning: SnapPositioning.relativeToAvailableSpace,
                  ),
                  builder: (context, state) {
                    return buttomSheetBuilder(
                        MediaQuery.of(context).size, lastNews);
                  },
                );
              });
            },
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: GoogleMap(
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(38.9637, 35.2433),
                zoom: zoom,
              ),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              circles: circles.toSet(),
            ),
          )
        ],
      ),
    );
  }

  buttomSheetBuilder(size, List<NewsApi> news) {
    List<Widget> sliders = [];
    for (var i = 0; i < news.length; i++) {
      if (news.elementAt(i).title == "" ||
          news.elementAt(i).urlToImage == "" ||
          news.elementAt(i).url == "") {
        continue;
      } else {
        sliders.add(
          Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: GestureDetector(
                onTap: () {
                  _launchURL(news.elementAt(i).url);
                },
                child: Stack(
                  children: <Widget>[
                    Image.network(news.elementAt(i).urlToImage,
                        fit: BoxFit.cover, width: 1000.0),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: const [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          news.elementAt(i).title,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return Container(
      height: size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: size.width * 0.25,
            height: 10,
            child: Container(
              margin: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: countryInformation!.labelColor,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        countryInformation!.countryName,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: countryInformation!.labelColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Cases: ${countryInformation!.confirmedCount}',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15),
                child: Image.network(
                  countryInformation!.flag,
                  width: 50,
                  height: 50,
                ),
              )
            ],
          ),
          news.isNotEmpty
              ? Text(
                  'Sağlık ile ilgili Son Haberler',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: countryInformation!.labelColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                )
              : SizedBox(),
          SizedBox(height: 5),
          news.isNotEmpty
              ? CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: false,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                  ),
                  items: sliders,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
