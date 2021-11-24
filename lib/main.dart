import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


///TODO make sure you create an admob account and create ad units
///to put them instead of the test ad units
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

const int maxAttempts = 3;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late BannerAd staticAd;
  bool staticAdLoaded = false;
  late BannerAd inlineAd;
  bool inlineAdLoaded = false;

  InterstitialAd? interstitialAd;
  int interstitialAttempts = 0;
  
  RewardedAd? rewardedAd;
  int rewardedAdAttempts = 0;


  ///Ad request settings
  static const AdRequest request = AdRequest(
    // keywords: ['', ''],
    // contentUrl: '',
    // nonPersonalizedAds: false
  );

  ///function to load static banner ad
  void loadStaticBannerAd() {
    staticAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            staticAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error){
          ad.dispose();

          print('ad failed to load ${error.message}');
        }
      )
    );

    staticAd.load();
  }

  ///function to load inline banner ad
  void loadInlineBannerAd() {
    inlineAd = BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        request: request,
        listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                inlineAdLoaded = true;
              });
            },
            onAdFailedToLoad: (ad, error){
              ad.dispose();

              print('ad failed to load ${error.message}');
            }
        )
    );

    inlineAd.load();
  }

  ///function to create Interstitial ad
  void createInterstialAd() {
    InterstitialAd.load(
      adUnitId: InterstitialAd.testAdUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad){
            interstitialAd = ad;
            interstitialAttempts = 0;
          },
          onAdFailedToLoad: (error){
            interstitialAttempts++;
            interstitialAd = null;
            print('falied to load ${error.message}');

            if(interstitialAttempts <= maxAttempts){
              createInterstialAd();
            }
          })
    );
  }

  ///function to show the Interstitial ad after loading it
  ///this function will get called when we click on the button
  void showInterstitialAd() {
    if(interstitialAd == null){
      print('trying to show before loading');
      return;
    }

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('ad showed $ad'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        createInterstialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error){
        ad.dispose();
        print('failed to show the ad $ad');

        createInterstialAd();
      }
    );

    interstitialAd!.show();
    interstitialAd = null;
  }

  ///function to create rewarded ad
  void createRewardedAd() {
    RewardedAd.load(
        adUnitId: RewardedAd.testAdUnitId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad){
              rewardedAd = ad;
              rewardedAdAttempts = 0;
            },
            onAdFailedToLoad: (error){
              rewardedAdAttempts++;
              rewardedAd = null;
              print('failed to load ${error.message}');

              if(rewardedAdAttempts <= maxAttempts){
                createRewardedAd();
              }
            })
    );
  }

  ///function to show the rewarded ad after loading it
  ///this function will get called when we click on the button
  void showRewardedAd() {
    if(rewardedAd == null){
      print('trying to show before loading');
      return;
    }

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) => print('ad showed $ad'),
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          createRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error){
          ad.dispose();
          print('failed to show the ad $ad');

          createRewardedAd();
        }
    );

    rewardedAd!.show(onUserEarnedReward: (ad, reward){
      print('reward video ${reward.amount} ${reward.type}');
    });
    rewardedAd = null;
  }

  @override
  void initState() {
    loadStaticBannerAd();
    loadInlineBannerAd();
    createInterstialAd();
    createRewardedAd();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    ///Don't forget to dispose the ads
    staticAd.dispose();
    inlineAd.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Ads'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(staticAdLoaded)
                Container(
                  child: AdWidget(ad: staticAd,),
                  width: staticAd.size.width.toDouble(),
                  height: staticAd.size.height.toDouble(),
                  alignment: Alignment.bottomCenter,
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          showInterstitialAd();
                        },
                        child: const Text('Show Interstitial Ad')),
                    // const SizedBox(width: 50,),
                    ElevatedButton(
                        onPressed: () {
                          showRewardedAd();
                        },
                        child: const Text('Show Rewarded Ad')),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      if(inlineAdLoaded && index == 5){
                        return Column(
                          children: [
                            SizedBox(
                              child: AdWidget(ad: inlineAd,),
                              width: inlineAd.size.width.toDouble(),
                              height: inlineAd.size.height.toDouble(),
                            ),
                            ListTile(
                              title: Text('Item ${index + 1}'),
                              leading: const Icon(Icons.star),
                            )
                          ],
                        );
                      }
                      else{
                        return ListTile(
                          title: Text('Item ${index + 1}'),
                          leading: const Icon(Icons.star),
                        );
                      }

                    }
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
