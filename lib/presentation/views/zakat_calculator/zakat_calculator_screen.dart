import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/images.dart';
import '../../../data/bloc/zakat_calculator/zakat_calculator_bloc.dart';
import '../../../data/bloc/zakat_calculator/zakat_calculator_event.dart';
import '../../../data/bloc/zakat_calculator/zakat_calculator_state.dart';
import 'widgets/currency_dropdown.dart';
import 'widgets/calculation_basis_selector.dart';
import 'widgets/zakat_text_field.dart';
import 'widgets/zakat_results_bottom_sheet.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  String selectedCurrency = 'USD';
  String selectedBasis = 'Gold';
  ZakatCalculatorLoaded? lastCalculation;

  // Text editing controllers for all input fields
  final TextEditingController nisabController = TextEditingController();
  final TextEditingController goldValueController = TextEditingController();
  final TextEditingController silverValueController = TextEditingController();
  final TextEditingController cashInHandController = TextEditingController();
  final TextEditingController depositedController = TextEditingController();
  final TextEditingController loansController = TextEditingController();
  final TextEditingController investmentsController = TextEditingController();
  final TextEditingController borrowedMoneyController = TextEditingController();
  final TextEditingController wagesController = TextEditingController();
  final TextEditingController taxesController = TextEditingController();

  @override
  void dispose() {
    nisabController.dispose();
    goldValueController.dispose();
    silverValueController.dispose();
    cashInHandController.dispose();
    depositedController.dispose();
    loansController.dispose();
    investmentsController.dispose();
    borrowedMoneyController.dispose();
    wagesController.dispose();
    taxesController.dispose();
    super.dispose();
  }

  void _showResultsBottomSheet(ZakatCalculatorLoaded result) {
    setState(() {
      lastCalculation = result;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ZakatResultsBottomSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ZakatCalculatorBloc(),
      child: BlocListener<ZakatCalculatorBloc, ZakatCalculatorState>(
        listener: (context, state) {
          if (state is ZakatCalculatorLoaded) {
            _showResultsBottomSheet(state);
          }
        },
        child: _ZakatCalculatorContent(
          selectedCurrency: selectedCurrency,
          selectedBasis: selectedBasis,
          lastCalculation: lastCalculation,
          onCurrencyChanged: (currency) {
            setState(() {
              selectedCurrency = currency;
            });
          },
          onBasisChanged: (basis) {
            setState(() {
              selectedBasis = basis;
            });
          },
          nisabController: nisabController,
          goldValueController: goldValueController,
          silverValueController: silverValueController,
          cashInHandController: cashInHandController,
          depositedController: depositedController,
          loansController: loansController,
          investmentsController: investmentsController,
          borrowedMoneyController: borrowedMoneyController,
          wagesController: wagesController,
          taxesController: taxesController,
        ),
      ),
    );
  }
}

class _ZakatCalculatorContent extends StatelessWidget {
  final String selectedCurrency;
  final String selectedBasis;
  final ZakatCalculatorLoaded? lastCalculation;
  final Function(String) onCurrencyChanged;
  final Function(String) onBasisChanged;
  final TextEditingController nisabController;
  final TextEditingController goldValueController;
  final TextEditingController silverValueController;
  final TextEditingController cashInHandController;
  final TextEditingController depositedController;
  final TextEditingController loansController;
  final TextEditingController investmentsController;
  final TextEditingController borrowedMoneyController;
  final TextEditingController wagesController;
  final TextEditingController taxesController;

  const _ZakatCalculatorContent({
    required this.selectedCurrency,
    required this.selectedBasis,
    this.lastCalculation,
    required this.onCurrencyChanged,
    required this.onBasisChanged,
    required this.nisabController,
    required this.goldValueController,
    required this.silverValueController,
    required this.cashInHandController,
    required this.depositedController,
    required this.loansController,
    required this.investmentsController,
    required this.borrowedMoneyController,
    required this.wagesController,
    required this.taxesController,
  });

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'QAR':
        return 'ر.ق';
      case 'KWD':
        return 'د.ك';
      case 'OMR':
        return 'ر.ع';
      case 'BHD':
        return 'د.ب';
      case 'JOD':
        return 'د.ا';
      default:
        return '\$';
    }
  }

  String _formatCurrency(double amount, String currency) {
    return '${_getCurrencySymbol(currency)}${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
          title: Text(
            'Zakat Calculator',
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: const Color(0xFF8B0000), // Burgundy color to match button
            ),
          ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Calculation Card
            if (lastCalculation != null) ...[
              Container(
                width: 328.w,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      right: 10.w,
                      child: SvgPicture.asset(
                        AssetsPath.iconTransparent,
                        width: 65.w,
                        height: 65.h,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LAST CALCULATION',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              height: 16 / 10,
                              letterSpacing: 0,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Assets',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _formatCurrency(
                                          lastCalculation!.totalAssets,
                                          lastCalculation!.currency),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zakat Payable',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      lastCalculation!.isZakatRequired
                                          ? _formatCurrency(
                                              lastCalculation!.zakatPayable,
                                              lastCalculation!.currency)
                                          : 'No Zakat Required',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Description text
            Text(
              'Input all assets that have been in your possession for a full lunar year into the Zakat Calculator. It will then calculate the total amount of zakat you owe.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Currency Selection
            Text(
              'Select Currency',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            CurrencyDropdown(
              selectedCurrency: selectedCurrency,
              onCurrencyChanged: onCurrencyChanged,
            ),
            SizedBox(height: 24.h),

            // Calculation Basis Selection
            Text(
              'Select Calculation Basis',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            CalculationBasisSelector(
              selectedBasis: selectedBasis,
              onBasisChanged: onBasisChanged,
            ),
            SizedBox(height: 24.h),

            // Nisab Section
            Row(
              children: [
                Text(
                  'Nisab',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                Tooltip(
                  message:
                      'The nisab is the minimum amount of wealth a Muslim must possess before they become eligible to pay zakat. This amount is often referred to as the nisab threshold.',
                  preferBelow: true,
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    size: 16.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: nisabController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 16.h),

            // Value of Gold
            Text(
              'Value of Gold',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: goldValueController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 16.h),

            // Value of Silver
            Text(
              'Value of Silver',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: silverValueController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 24.h),

            // Cash Section
            Text(
              'Cash',
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            // In hand and bank accounts
            Text(
              'In hand and in bank accounts',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: cashInHandController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 16.h),

            // Deposited for future purpose
            Text(
              'Deposited for future purpose, e.g. Hajj',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: depositedController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 16.h),

            // Given out in loans
            Text(
              'Given out in loans',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: loansController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 16.h),

            // Business investments
            Text(
              'Business investments, shares, savings, pensions funded by money in one\'s possession',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: investmentsController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 24.h),

            // Liabilities Section
            Text(
              'Liabilities',
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            // Borrowed money
            Text(
              'Borrowed money, goods bought on credit',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: borrowedMoneyController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 16.h),

            // Wages due to employees
            Text(
              'Wages due to employees',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: wagesController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 16.h),

            // Taxes, rent, utility bills
            Text(
              'Taxes, rent, utility bills due immediately',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            ZakatTextField(
              controller: taxesController,
              hintText: 'Enter amount',
              currency: selectedCurrency,
            ),
            SizedBox(height: 32.h),

            // Calculate Button
            SizedBox(
              width: 328.w,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  // Collect all asset values
                  Map<String, double> assets = {
                    'gold': double.tryParse(goldValueController.text) ?? 0,
                    'silver': double.tryParse(silverValueController.text) ?? 0,
                    'cash_in_hand':
                        double.tryParse(cashInHandController.text) ?? 0,
                    'deposited': double.tryParse(depositedController.text) ?? 0,
                    'loans': double.tryParse(loansController.text) ?? 0,
                    'investments':
                        double.tryParse(investmentsController.text) ?? 0,
                  };

                  // Collect all liability values
                  Map<String, double> liabilities = {
                    'borrowed_money':
                        double.tryParse(borrowedMoneyController.text) ?? 0,
                    'wages': double.tryParse(wagesController.text) ?? 0,
                    'taxes': double.tryParse(taxesController.text) ?? 0,
                  };

                  // Trigger calculation using the correct context
                  final bloc = BlocProvider.of<ZakatCalculatorBloc>(context);
                  bloc.add(CalculateZakat(
                    assets: assets,
                    liabilities: liabilities,
                    currency: selectedCurrency,
                    calculationBasis: selectedBasis,
                  ));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color(0xFF8B0000), // Explicit burgundy color
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Text(
                  'Calculate Zakat',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
