import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/images.dart';
import '../../../data/viewmodel/Providers/user_provider.dart';
import '../../widgets/app_background_image_widget.dart';
import '../../widgets/custom_appbar_widget.dart';
import '../../widgets/functions_and_methods.dart';
import '../../widgets/form_field_widget.dart';

class ZakatCalculator extends StatefulWidget {
  const ZakatCalculator({super.key});

  @override
  State<ZakatCalculator> createState() => _ZakatCalculatorState();
}

class _ZakatCalculatorState extends State<ZakatCalculator> {
  final TextEditingController cashAtHomeController = TextEditingController();
  final TextEditingController bankBalanceController = TextEditingController();
  final TextEditingController cashBalanceController = TextEditingController();
  final TextEditingController profitController = TextEditingController();
  final TextEditingController goldSilverController = TextEditingController();
  final TextEditingController investmentPropertyController =
      TextEditingController();
  final TextEditingController othersController = TextEditingController();
  final TextEditingController debtsController = TextEditingController();
  final TextEditingController expensesController = TextEditingController();

  double amt_home = 0;
  double amt_bank = 0;
  double amt_shares = 0;
  double amt_merchandise = 0;
  double amt_gold = 0;
  double amt_property = 0;
  double amt_other = 0;
  double amt_debts = 0;
  double amt_expenses = 0;
  double amt_zakat = 0;
  double amt_eligable = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cashAtHomeController.dispose();
    bankBalanceController.dispose();
    cashBalanceController.dispose();
    profitController.dispose();
    goldSilverController.dispose();
    investmentPropertyController.dispose();
    othersController.dispose();
    debtsController.dispose();
    expensesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackgroundImageWidget(bgImagePath: AssetsPath.background03SVG),
       Column(
         children: [
           CustomAppbarWidget(screenTitle: "jakat_calculator2".tr,),
           Expanded(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16.0),
               child: SingleChildScrollView(
                 child: Column(
                   children: [
                     SizedBox(height: 8.h),
                     countryDropdownWidget(),
                     SizedBox(height: 8.h),
                     _buildWealthInputField(),
                     SizedBox(height: 18.h),
                     _buildDeductionsInputField(),
                     SizedBox(height: 46.h),
                     _buildCalculateButton(),
                     SizedBox(height: 26.h),
                   ],
                 ),
               ),
             ),
           ),
         ],
       )
        ],
      ),
    );
  }

  List<String> getFieldNames() {
    return ['USD', 'BDT', 'INR', 'PKR', 'IDR', 'TRY', 'MYR', 'SAR'];
  }

  String? selectedCurrency;

  Widget countryDropdownWidget() {
    final provider = Provider.of<UserProvider>(context, listen: false);
    List<String> fieldNames =
        provider.allCurrency != null ? getFieldNames() : [];

    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      onChanged: (String? newValue) {
        setState(() {
          selectedCurrency = newValue;
          if (newValue != null) {
            // Handle the selected currency
            print("Selected Currency: $newValue");
          }
        });
      },
      hint: Text(
        'select_your_currency'.tr,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.colorDisabled,
        ),
      ),
      decoration: const InputDecoration(
          // Your decoration properties
          ),
      items: fieldNames.map<DropdownMenuItem<String>>(
        (String fieldName) {
          return DropdownMenuItem<String>(
            value: fieldName,
            child: Text(
              fieldName,
              style: const TextStyle(fontSize: 14, color: AppColors.colorAlert),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildWealthInputField() {
    return Column(
      children: [
        Text(
          "wealth".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22.sp,
              color: AppColors.colorAlert,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 1.h,
          width: double.maxFinite,
          color: AppColors.colorWhiteHighEmp,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'cash_at_home',
          hintText: 'Enter value',
          controller: cashAtHomeController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'bank_account_balance',
          hintText: 'Enter value',
          controller: bankBalanceController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'cash_value_of_stock_and_equities',
          hintText: 'Enter value',
          controller: cashBalanceController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'profits_inventory',
          hintText: 'Enter value',
          controller: profitController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'gold_silver',
          hintText: 'Enter value',
          controller: goldSilverController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'investment_property',
          hintText: 'Enter value',
          controller: investmentPropertyController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'other_income',
          hintText: 'Enter value',
          controller: othersController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
      ],
    );
  }

  Widget _buildDeductionsInputField() {
    return Column(
      children: [
        Text(
          "deductions".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22.sp,
              color: AppColors.colorAlert,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 1.h,
          width: double.maxFinite,
          color: AppColors.colorWhiteHighEmp,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'debts',
          hintText: 'Enter value',
          controller: debtsController,
          keyboardType: TextInputType.number,
          obscureText: false,
        ),
        SizedBox(height: 16.h),
        TextFormFieldWidget2(
          formTitle: 'expenses',
          hintText: 'Enter value',
          controller: expensesController,
          keyboardType: TextInputType.number,
          obscureText: false,
        )
      ],
    );
  }

  Widget _buildCalculateButton() {
    return GestureDetector(
      onTap: () {
        if (selectedCurrency != null) {
          calculate();
          showResultDialog();
        } else {
          makeSnack("enter_a_currency".tr);
        }
      },
      child: Container(
        height: 55.h,
        width: double.maxFinite,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: AppColors.colorAlert),
        child: Center(
          child: Text(
            "calculate".tr,
            style:
                TextStyle(color: AppColors.colorWhiteHighEmp, fontSize: 22.sp),
          ),
        ),
      ),
    );
  }

  showResultDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'totals'.tr,
            style: const TextStyle(
                color: AppColors.colorPrimary, fontWeight: FontWeight.bold),
          )),
          content: Column(
            // Main column containing four Text widgets
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'amount_eligible_for_zakat'.tr,
                textAlign: TextAlign.center,
              ),
              Center(
                child: Text(
                  amt_eligable.toString(),
                  style: TextStyle(fontSize: 22.sp),
                ),
              ),
              Center(
                child: Text(
                  'your_zakat'.tr,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  amt_zakat.toString(),
                  style:
                      TextStyle(fontSize: 32.sp, color: AppColors.colorAlert),
                ),
              ),
            ],
          ),
          /*actions: [
            TextButton(
              onPressed: () {
                cashAtHomeController.clear();
                bankBalanceController.clear();
                cashBalanceController.clear();
                profitController.clear();
                goldSilverController.clear();
                investmentPropertyController.clear();
                othersController.clear();
                debtsController.clear();
                expensesController.clear();
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text(
                  'calculate_again'.tr,
                style: TextStyle(
                  color: AppColors.colorPrimary
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                cashAtHomeController.dispose();
                bankBalanceController.dispose();
                cashBalanceController.dispose();
                profitController.dispose();
                goldSilverController.dispose();
                investmentPropertyController.dispose();
                othersController.dispose();
                debtsController.dispose();
                expensesController.dispose();
                // Close the dialog
                Get.offAll(HomeScreen());
              },
              child: Text(
                  'go_home'.tr,
                style: TextStyle(
                    color: AppColors.colorAlert
                ),
              ),
            ),
          ],*/
        );
      },
    );
  }

  void calculate() {
    final provider = Provider.of<UserProvider>(context, listen: false);
    print("******************************************$selectedCurrency");
    double? amt_nisab;
    setState(() {
      if (selectedCurrency == 'USD') {
        amt_nisab = double.parse(provider.allCurrency!.usd);
      } else if (selectedCurrency == 'BDT') {
        amt_nisab = double.parse(provider.allCurrency!.bdt);
      } else if (selectedCurrency == 'INR') {
        amt_nisab = double.parse(provider.allCurrency!.inr);
      } else if (selectedCurrency == 'PKR') {
        amt_nisab = double.parse(provider.allCurrency!.pkr);
      } else if (selectedCurrency == 'IDR') {
        amt_nisab = double.parse(provider.allCurrency!.idr);
      } else if (selectedCurrency == 'TRY') {
        amt_nisab = double.parse(provider.allCurrency!.tryValue);
      } else if (selectedCurrency == 'MYR') {
        amt_nisab = double.parse(provider.allCurrency!.myr);
      } else if (selectedCurrency == 'SAR') {
        amt_nisab = double.parse(provider.allCurrency!.sar);
      }

      if (cashAtHomeController.text.isNotEmpty) {
        amt_home = double.parse(cashAtHomeController.text);
      }
      if (bankBalanceController.text.isNotEmpty) {
        amt_bank = double.parse(bankBalanceController.text);
      }
      if (cashBalanceController.text.isNotEmpty) {
        amt_shares = double.parse(cashBalanceController.text);
      }
      if (profitController.text.isNotEmpty) {
        amt_merchandise = double.parse(profitController.text);
      }
      if (goldSilverController.text.isNotEmpty) {
        amt_gold = double.parse(goldSilverController.text);
      }
      if (investmentPropertyController.text.isNotEmpty) {
        amt_property = double.parse(investmentPropertyController.text);
      }
      if (othersController.text.isNotEmpty) {
        amt_other = double.parse(othersController.text);
      }
      if (debtsController.text.isNotEmpty) {
        amt_debts = double.parse(debtsController.text);
      }
      if (expensesController.text.isNotEmpty) {
        amt_expenses = double.parse(expensesController.text);
      }

      // Add similar lines for other input fields

      final double amt_assets_gross = amt_home +
          amt_bank +
          amt_shares +
          amt_merchandise +
          amt_gold +
          amt_property +
          amt_other;
      var amt_assets_net = amt_assets_gross - amt_debts - amt_expenses;

      print("nishab $amt_nisab");

      if (amt_assets_net > amt_nisab!) {
        amt_eligable = amt_assets_net.ceilToDouble();
        amt_zakat = (amt_eligable * 0.025).ceilToDouble();
      } else {
        amt_eligable = 0;
        amt_zakat = 0;
      }

      // Display the values
      print('Eligible Amount: $amt_eligable');
      print('Zakat Amount: $amt_zakat');
    });
  }
}
