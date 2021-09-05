import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:simple_admob_app/data/ad_helper.dart';
import 'package:simple_admob_app/data/news_article.dart';
import 'package:simple_admob_app/presentation/news_article_page.dart';
import 'package:simple_admob_app/presentation/widgets.dart';

const int maxFailedLoadAttempt = 3;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _inlineAdIndex = 3;

  int _interstitialLoadAttempt = 0;

  late BannerAd _bottomBannerAd;
  late BannerAd _inlineBannerAd;
  InterstitialAd? _interstitialAd;

  bool _isBottomBannerAdLoaded = false;
  bool _isInlineAdLoaded = false;

  int _getListViewItemIndex(int index) {
    if (index >= _inlineAdIndex && _isInlineAdLoaded) {
      return index - 1;
    }
    return index;
  }

  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: AdRequest(),
    );
    _bottomBannerAd.load();
  }

  void _createInlineBannerAd() {
    _inlineBannerAd = BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isInlineAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: AdRequest(),
    );
    _inlineBannerAd.load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.intersitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialLoadAttempt = 0;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempt += 1;
          _interstitialAd = null;
          if(_interstitialLoadAttempt >= maxFailedLoadAttempt) {
            _createInterstitialAd();
          }
        }
      ),
    );
  }

  void _showInterstitialAd() {
    if(_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAd();
        }
      );
      _interstitialAd!.show();
    }
  }

  @override
  void initState() {
    super.initState();
    _createBottomBannerAd();
    _createInlineBannerAd();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bottomBannerAd.dispose();
    _inlineBannerAd.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // use this if we alrdy have bottomNavigationBar
      // persistentFooterButtons: [],
      bottomNavigationBar: _isBottomBannerAdLoaded
          ? Container(
              height: _bottomBannerAd.size.height.toDouble(),
              width: _bottomBannerAd.size.width.toDouble(),
              child: AdWidget(
                ad: _bottomBannerAd,
              ),
            )
          : null,
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: AppBarTitle(),
        backgroundColor: Colors.indigo[800],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: NewsArticle.articles.length + (_isInlineAdLoaded ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isInlineAdLoaded && index == _inlineAdIndex) {
            return Container(
              padding: EdgeInsets.only(bottom: 10.0),
              width: _inlineBannerAd.size.width.toDouble(),
              height: _inlineBannerAd.size.height.toDouble(),
              child: AdWidget(
                ad: _inlineBannerAd,
              ),
            );
          } else {
            final article = NewsArticle.articles[_getListViewItemIndex(index)];
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: GestureDetector(
                onTap: () {
                  _showInterstitialAd();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsArticlePage(
                        title: article.headline,
                        imagePath: article.asset,
                      ),
                    ),
                  );
                },
                child: ArticleTile(
                  article: article,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
