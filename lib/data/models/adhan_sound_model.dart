class AdhanSoundModel {
  final String name;
  final String assetPath;
  final bool isSelected;

  const AdhanSoundModel({
    required this.name,
    required this.assetPath,
    this.isSelected = false,
  });

  AdhanSoundModel copyWith({
    String? name,
    String? assetPath,
    bool? isSelected,
  }) {
    return AdhanSoundModel(
      name: name ?? this.name,
      assetPath: assetPath ?? this.assetPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
