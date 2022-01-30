import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:chatapp/Screens/LoginScreen.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  var pageController = PageController(initialPage: 0);
  var pageViewModelData = List<PageViewData>();

  var title = "More and More";
  var subtitle = "Stay in touch with the people who matter most";
  var subtitle2 = "Talk to people who has similar intrest as you";
  var subtitle3 = "Let's chat over ChatApp";

  Timer sliderTimer;
  var currentShowIndex = 0;

  navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void initState() {
    pageViewModelData.add(PageViewData(
      titleText: title,
      subtitleText: subtitle,
      assetsImage: logo,
    ));

    pageViewModelData.add(PageViewData(
      titleText: title,
      subtitleText: subtitle2,
      assetsImage: intro1,
    ));

    pageViewModelData.add(PageViewData(
      titleText: title,
      subtitleText: subtitle3,
      assetsImage: intro2,
    ));

    sliderTimer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (currentShowIndex == 0) {
        pageController.animateTo(MediaQuery.of(context).size.width,
            duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 1) {
        pageController.animateTo(MediaQuery.of(context).size.width * 2,
            duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 2) {
        pageController.animateTo(0, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colors,
        body: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            new Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 2.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  alignment: Alignment.center,
                  height: 48,
                  width: 90,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        navigateToLogin();
                      },
                      child: Text("SKIP",
                          style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: bgcolors)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PageView(
                  controller: pageController,
                  pageSnapping: true,
                  onPageChanged: (index) {
                    currentShowIndex = index;
                  },
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    PagePopup(imageData: pageViewModelData[0]),
                    PagePopup(imageData: pageViewModelData[1]),
                    PagePopup(imageData: pageViewModelData[2]),
                  ],
                ),
              ),
            ),
            PageIndicator(
              layout: PageIndicatorLayout.WARM,
              size: 12.0,
              controller: pageController,
              space: 6.0,
              count: 3,
              color: Colors.grey,
              activeColor: bgcolors,
            ),
            new Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                    color: bgcolors,
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        navigateToLogin();
                      },
                      child: Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          Text("START",
                              style: new TextStyle(
                                  letterSpacing: 1, fontWeight: FontWeight.w300, fontSize: 16, color: colors)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SLIDER MENU

class PagePopup extends StatelessWidget {
  final PageViewData imageData;

  const PagePopup({Key key, this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            width: MediaQuery.of(context).size.width - 120,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    imageData.assetsImage,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  new Text(
                    imageData.subtitleText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
          ),
        ),
      ],
    );
  }
}

class PageViewData {
  final String titleText;
  final String subtitleText;
  final String assetsImage;

  PageViewData({this.titleText, this.subtitleText, this.assetsImage});
}
