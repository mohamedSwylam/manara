import 'package:flutter/material.dart';

class ShowPurchaseStatus extends StatefulWidget {
  final String status;

  const ShowPurchaseStatus({Key? key, required this.status}) : super(key: key);

  @override
  State<ShowPurchaseStatus> createState() => _ShowPurchaseStatusState();
}

class _ShowPurchaseStatusState extends State<ShowPurchaseStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.status),
      ),
    );
  }
}
