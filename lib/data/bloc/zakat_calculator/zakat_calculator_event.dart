import 'package:equatable/equatable.dart';

abstract class ZakatCalculatorEvent extends Equatable {
  const ZakatCalculatorEvent();

  @override
  List<Object?> get props => [];
}

class CalculateZakat extends ZakatCalculatorEvent {
  final Map<String, double> assets;
  final Map<String, double> liabilities;
  final String currency;
  final String calculationBasis;

  const CalculateZakat({
    required this.assets,
    required this.liabilities,
    required this.currency,
    required this.calculationBasis,
  });

  @override
  List<Object?> get props => [assets, liabilities, currency, calculationBasis];
}

class ChangeCurrency extends ZakatCalculatorEvent {
  final String currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class ChangeCalculationBasis extends ZakatCalculatorEvent {
  final String basis;

  const ChangeCalculationBasis(this.basis);

  @override
  List<Object?> get props => [basis];
}
