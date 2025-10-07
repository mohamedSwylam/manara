import 'package:equatable/equatable.dart';

abstract class ZakatCalculatorState extends Equatable {
  const ZakatCalculatorState();

  @override
  List<Object?> get props => [];
}

class ZakatCalculatorInitial extends ZakatCalculatorState {}

class ZakatCalculatorLoading extends ZakatCalculatorState {}

class ZakatCalculatorLoaded extends ZakatCalculatorState {
  final double totalAssets;
  final double totalLiabilities;
  final double netWealth;
  final double nisabThreshold;
  final double zakatPayable;
  final String currency;
  final String calculationBasis;
  final bool isZakatRequired;

  const ZakatCalculatorLoaded({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWealth,
    required this.nisabThreshold,
    required this.zakatPayable,
    required this.currency,
    required this.calculationBasis,
    required this.isZakatRequired,
  });

  @override
  List<Object?> get props => [
        totalAssets,
        totalLiabilities,
        netWealth,
        nisabThreshold,
        zakatPayable,
        currency,
        calculationBasis,
        isZakatRequired,
      ];
}

class ZakatCalculatorError extends ZakatCalculatorState {
  final String message;

  const ZakatCalculatorError(this.message);

  @override
  List<Object?> get props => [message];
}
