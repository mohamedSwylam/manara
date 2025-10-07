import 'package:flutter/material.dart';
import 'package:manara/purchase/purchase_api.dart';
import 'package:manara/purchase/show_purchase.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({Key? key}) : super(key: key);

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late Future<List<Package>> _futurePackages;

  @override
  void initState() {
    super.initState();
    _futurePackages = PurchaseApi.fetchOffersByIds(Coins.allIds)
        .then((offerings) => offerings
            .map((offer) => offer.availablePackages)
            .expand((pair) => pair)
            .toList())
        .catchError((error) {
      print('Error fetching packages: $error');
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Package>>(
        future: _futurePackages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('No packages found'));
          }
          final packages = snapshot.data!;
          print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>${packages.length}");
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                child: Text(packages[2].offeringIdentifier),
                onPressed: () async {
                  final isSuccess =
                      await PurchaseApi.purchasePackage(packages[2]);
                  isSuccess
                      ? Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const ShowPurchaseStatus(status: "Success")),
                        )
                      : Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const ShowPurchaseStatus(
                                      status: 'UnSeccessFull')),
                        );
                },
              ),
            ),
          );
        });
  }

/*Future fetchOffers() async {
    final offerings = await PurchaseApi.fetchOffersByIds(Coins.allIds);

    if(offerings.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No Plans Found')));
    } else {
      final packages = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();

      print(packages);
    }
  }*/
}
