import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class AdState
{
  Future<InitializationStatus> initialization;
  AdState(this.initialization);
  String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  BannerAdListener get bannerAdListener => _bannerAdListener;

  /// An listener used to listen to bannerAds
  final BannerAdListener _bannerAdListener = const BannerAdListener(
    // onAdLoaded: (Ad) => print('Add loaded')
  );
}
