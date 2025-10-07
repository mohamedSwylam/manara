import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Coins {
  static const idStarter = 'starter_1_one';
  static const idBasic = 'basic_5_five';
  static const idAdvance = 'advance_15_fifteen';
  static const idDonor = 'donor_25_twentyfive';

  static const allIds = [idStarter, idBasic, idAdvance, idDonor];
}

class PurchaseApi {
  static String get _apiKey => dotenv.env['revenueCat_Key'] ?? '';

  static Future init() async {
    try {
      final apiKey = _apiKey;
      if (apiKey.isNotEmpty && !apiKey.contains('YOUR REVENUE CAT API KEY HERE')) {
        await Purchases.setDebugLogsEnabled(true);
        await Purchases.setup(apiKey);
        print("RevenueCat initialized successfully");
      } else {
        print("RevenueCat key not configured. Skipping RevenueCat initialization.");
      }
    } catch (e) {
      print("Error initializing RevenueCat: $e");
    }
  }

  static Future<List<Offering>> fetchOffersByIds(List<String> ids) async {
    final offers = await fetchOffers();

    return offers.where((offer) => ids.contains(offer.identifier)).toList();
  }

  static Future<List<Offering>> fetchOffers({bool all = true}) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (!all) {
        final current = offerings.current;
        return current == null ? [] : [current];
      } else {
        return offerings.all.values.toList();
      }
    } on PlatformException catch (e) {
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (e) {
      return false;
    }
  }
}
