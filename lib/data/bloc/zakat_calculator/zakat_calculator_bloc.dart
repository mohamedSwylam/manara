import 'package:flutter_bloc/flutter_bloc.dart';
import 'zakat_calculator_event.dart';
import 'zakat_calculator_state.dart';

class ZakatCalculatorBloc extends Bloc<ZakatCalculatorEvent, ZakatCalculatorState> {
  ZakatCalculatorBloc() : super(ZakatCalculatorInitial()) {
    on<CalculateZakat>(_onCalculateZakat);
    on<ChangeCurrency>(_onChangeCurrency);
    on<ChangeCalculationBasis>(_onChangeCalculationBasis);
  }

  void _onCalculateZakat(CalculateZakat event, Emitter<ZakatCalculatorState> emit) async {
    emit(ZakatCalculatorLoading());

    try {
      // Calculate total assets
      double totalAssets = 0;
      for (double value in event.assets.values) {
        totalAssets += value;
      }

      // Calculate total liabilities
      double totalLiabilities = 0;
      for (double value in event.liabilities.values) {
        totalLiabilities += value;
      }

      // Calculate net wealth
      double netWealth = totalAssets - totalLiabilities;

      // Get Nisab threshold based on currency and calculation basis
      double nisabThreshold = _getNisabThreshold(event.currency, event.calculationBasis);

      // Calculate Zakat (2.5% of net wealth if above Nisab)
      double zakatPayable = 0;
      bool isZakatRequired = false;

      if (netWealth >= nisabThreshold) {
        zakatPayable = netWealth * 0.025; // 2.5%
        isZakatRequired = true;
      }

      emit(ZakatCalculatorLoaded(
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        netWealth: netWealth,
        nisabThreshold: nisabThreshold,
        zakatPayable: zakatPayable,
        currency: event.currency,
        calculationBasis: event.calculationBasis,
        isZakatRequired: isZakatRequired,
      ));
    } catch (e) {
      emit(ZakatCalculatorError(e.toString()));
    }
  }

  void _onChangeCurrency(ChangeCurrency event, Emitter<ZakatCalculatorState> emit) {
    // Handle currency change if needed
  }

  void _onChangeCalculationBasis(ChangeCalculationBasis event, Emitter<ZakatCalculatorState> emit) {
    // Handle calculation basis change if needed
  }

  double _getNisabThreshold(String currency, String calculationBasis) {
    // Nisab values based on Islamic standards
    // Gold Nisab: 87.48 grams of gold
    // Silver Nisab: 612.36 grams of silver
    
    Map<String, Map<String, double>> nisabValues = {
      'USD': {
        'Gold': 5000.0,    // Approximate value of 87.48g gold in USD
        'Silver': 350.0,    // Approximate value of 612.36g silver in USD
      },
      'EUR': {
        'Gold': 4500.0,
        'Silver': 320.0,
      },
      'GBP': {
        'Gold': 4000.0,
        'Silver': 280.0,
      },
      'SAR': {
        'Gold': 18750.0,
        'Silver': 1312.5,
      },
      'AED': {
        'Gold': 18350.0,
        'Silver': 1284.5,
      },
      'QAR': {
        'Gold': 18200.0,
        'Silver': 1274.0,
      },
      'KWD': {
        'Gold': 1500.0,
        'Silver': 105.0,
      },
      'OMR': {
        'Gold': 1925.0,
        'Silver': 134.75,
      },
      'BHD': {
        'Gold': 1875.0,
        'Silver': 131.25,
      },
      'JOD': {
        'Gold': 3550.0,
        'Silver': 248.5,
      },
    };

    return nisabValues[currency]?[calculationBasis] ?? 5000.0;
  }
}
