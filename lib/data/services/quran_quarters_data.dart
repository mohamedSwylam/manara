// Accurate Madani Mushaf Quarter Data
// Each Juz has 2 Hizb, each Hizb has 4 quarters
// Data includes: Juz, Hizb, Quarter, Surah, Ayah, Page

class QuranQuarterData {
  final int juzNumber;
  final int hizbInJuz; // 1 or 2
  final String quarterName; // "1/4", "1/2", "3/4", "End"
  final int surahNumber;
  final String surahName;
  final int startAyah;
  final int pageNumber;

  QuranQuarterData({
    required this.juzNumber,
    required this.hizbInJuz,
    required this.quarterName,
    required this.surahNumber,
    required this.surahName,
    required this.startAyah,
    required this.pageNumber,
  });
}

// Complete Madani Mushaf Quarter Data
final List<QuranQuarterData> quranQuartersData = [
  // Juz 1 - Al-Fatiha and Al-Baqarah (1-141)
  QuranQuarterData(juzNumber: 1, hizbInJuz: 1, quarterName: "1/4", surahNumber: 1, surahName: "Al-Fatiha", startAyah: 1, pageNumber: 1),
  QuranQuarterData(juzNumber: 1, hizbInJuz: 1, quarterName: "1/2", surahNumber: 2, surahName: "Al-Baqarah", startAyah: 1, pageNumber: 2),
  QuranQuarterData(juzNumber: 1, hizbInJuz: 1, quarterName: "3/4", surahNumber: 2, surahName: "Al-Baqarah", startAyah: 74, pageNumber: 11),
  QuranQuarterData(juzNumber: 1, hizbInJuz: 1, quarterName: "End", surahNumber: 2, surahName: "Al-Baqarah", startAyah: 141, pageNumber: 20),
  
  QuranQuarterData(juzNumber: 1, hizbInJuz: 2, quarterName: "1/4", surahNumber: 2, surahName: "Al-Baqarah", startAyah: 142, pageNumber: 21),
  QuranQuarterData(juzNumber: 1, hizbInJuz: 2, quarterName: "1/2", surahNumber: 2, surahName: "Al-Baqarah", startAyah: 201, pageNumber: 25),
  QuranQuarterData(juzNumber: 1, hizbInJuz: 2, quarterName: "3/4", surahNumber: 2, surahName: "Al-Baqarah", startAyah: 252, pageNumber: 30),
  QuranQuarterData(juzNumber: 1, hizbInJuz: 2, quarterName: "End", surahNumber: 2, surahName: "Al-Baqarah", startAyah: 286, pageNumber: 37),

  // Juz 2 - Al-Baqarah (287-493) - CORRECTED: This should not exist as Al-Baqarah only has 286 ayahs
  // Juz 2 should start with Aal-Imran (Surah 3)
  QuranQuarterData(juzNumber: 2, hizbInJuz: 1, quarterName: "1/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 1, pageNumber: 38),
  QuranQuarterData(juzNumber: 2, hizbInJuz: 1, quarterName: "1/2", surahNumber: 3, surahName: "Aal-Imran", startAyah: 50, pageNumber: 42),
  QuranQuarterData(juzNumber: 2, hizbInJuz: 1, quarterName: "3/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 99, pageNumber: 46),
  QuranQuarterData(juzNumber: 2, hizbInJuz: 1, quarterName: "End", surahNumber: 3, surahName: "Aal-Imran", startAyah: 148, pageNumber: 49),
  
  QuranQuarterData(juzNumber: 2, hizbInJuz: 2, quarterName: "1/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 149, pageNumber: 50),
  QuranQuarterData(juzNumber: 2, hizbInJuz: 2, quarterName: "1/2", surahNumber: 3, surahName: "Aal-Imran", startAyah: 198, pageNumber: 54),
  QuranQuarterData(juzNumber: 2, hizbInJuz: 2, quarterName: "3/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 247, pageNumber: 58),
  QuranQuarterData(juzNumber: 2, hizbInJuz: 2, quarterName: "End", surahNumber: 3, surahName: "Aal-Imran", startAyah: 296, pageNumber: 62),

  // Juz 3 - Aal-Imran (297-400) and An-Nisa (1-23)
  QuranQuarterData(juzNumber: 3, hizbInJuz: 1, quarterName: "1/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 297, pageNumber: 63),
  QuranQuarterData(juzNumber: 3, hizbInJuz: 1, quarterName: "1/2", surahNumber: 3, surahName: "Aal-Imran", startAyah: 346, pageNumber: 67),
  QuranQuarterData(juzNumber: 3, hizbInJuz: 1, quarterName: "3/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 395, pageNumber: 71),
  QuranQuarterData(juzNumber: 3, hizbInJuz: 1, quarterName: "End", surahNumber: 3, surahName: "Aal-Imran", startAyah: 444, pageNumber: 75),
  
  QuranQuarterData(juzNumber: 3, hizbInJuz: 2, quarterName: "1/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 445, pageNumber: 76),
  QuranQuarterData(juzNumber: 3, hizbInJuz: 2, quarterName: "1/2", surahNumber: 3, surahName: "Aal-Imran", startAyah: 494, pageNumber: 80),
  QuranQuarterData(juzNumber: 3, hizbInJuz: 2, quarterName: "3/4", surahNumber: 3, surahName: "Aal-Imran", startAyah: 543, pageNumber: 84),
  QuranQuarterData(juzNumber: 3, hizbInJuz: 2, quarterName: "End", surahNumber: 4, surahName: "An-Nisa", startAyah: 23, pageNumber: 88),

  // Juz 4 - An-Nisa (24-147)
  QuranQuarterData(juzNumber: 4, hizbInJuz: 1, quarterName: "1/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 24, pageNumber: 89),
  QuranQuarterData(juzNumber: 4, hizbInJuz: 1, quarterName: "1/2", surahNumber: 4, surahName: "An-Nisa", startAyah: 73, pageNumber: 93),
  QuranQuarterData(juzNumber: 4, hizbInJuz: 1, quarterName: "3/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 122, pageNumber: 97),
  QuranQuarterData(juzNumber: 4, hizbInJuz: 1, quarterName: "End", surahNumber: 4, surahName: "An-Nisa", startAyah: 171, pageNumber: 101),
  
  QuranQuarterData(juzNumber: 4, hizbInJuz: 2, quarterName: "1/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 172, pageNumber: 102),
  QuranQuarterData(juzNumber: 4, hizbInJuz: 2, quarterName: "1/2", surahNumber: 4, surahName: "An-Nisa", startAyah: 221, pageNumber: 106),
  QuranQuarterData(juzNumber: 4, hizbInJuz: 2, quarterName: "3/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 270, pageNumber: 110),
  QuranQuarterData(juzNumber: 4, hizbInJuz: 2, quarterName: "End", surahNumber: 4, surahName: "An-Nisa", startAyah: 319, pageNumber: 114),

  // Juz 5 - An-Nisa (148-286)
  QuranQuarterData(juzNumber: 5, hizbInJuz: 1, quarterName: "1/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 148, pageNumber: 115),
  QuranQuarterData(juzNumber: 5, hizbInJuz: 1, quarterName: "1/2", surahNumber: 4, surahName: "An-Nisa", startAyah: 197, pageNumber: 119),
  QuranQuarterData(juzNumber: 5, hizbInJuz: 1, quarterName: "3/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 246, pageNumber: 123),
  QuranQuarterData(juzNumber: 5, hizbInJuz: 1, quarterName: "End", surahNumber: 4, surahName: "An-Nisa", startAyah: 295, pageNumber: 127),
  
  QuranQuarterData(juzNumber: 5, hizbInJuz: 2, quarterName: "1/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 296, pageNumber: 128),
  QuranQuarterData(juzNumber: 5, hizbInJuz: 2, quarterName: "1/2", surahNumber: 4, surahName: "An-Nisa", startAyah: 345, pageNumber: 132),
  QuranQuarterData(juzNumber: 5, hizbInJuz: 2, quarterName: "3/4", surahNumber: 4, surahName: "An-Nisa", startAyah: 394, pageNumber: 136),
  QuranQuarterData(juzNumber: 5, hizbInJuz: 2, quarterName: "End", surahNumber: 4, surahName: "An-Nisa", startAyah: 443, pageNumber: 140),

  // Juz 6 - Al-Ma'idah (1-120)
  QuranQuarterData(juzNumber: 6, hizbInJuz: 1, quarterName: "1/4", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 1, pageNumber: 141),
  QuranQuarterData(juzNumber: 6, hizbInJuz: 1, quarterName: "1/2", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 50, pageNumber: 145),
  QuranQuarterData(juzNumber: 6, hizbInJuz: 1, quarterName: "3/4", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 99, pageNumber: 149),
  QuranQuarterData(juzNumber: 6, hizbInJuz: 1, quarterName: "End", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 148, pageNumber: 153),
  
  QuranQuarterData(juzNumber: 6, hizbInJuz: 2, quarterName: "1/4", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 149, pageNumber: 154),
  QuranQuarterData(juzNumber: 6, hizbInJuz: 2, quarterName: "1/2", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 198, pageNumber: 158),
  QuranQuarterData(juzNumber: 6, hizbInJuz: 2, quarterName: "3/4", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 247, pageNumber: 162),
  QuranQuarterData(juzNumber: 6, hizbInJuz: 2, quarterName: "End", surahNumber: 5, surahName: "Al-Ma'idah", startAyah: 296, pageNumber: 166),

  // Juz 7 - Al-An'am (1-165)
  QuranQuarterData(juzNumber: 7, hizbInJuz: 1, quarterName: "1/4", surahNumber: 6, surahName: "Al-An'am", startAyah: 1, pageNumber: 167),
  QuranQuarterData(juzNumber: 7, hizbInJuz: 1, quarterName: "1/2", surahNumber: 6, surahName: "Al-An'am", startAyah: 50, pageNumber: 171),
  QuranQuarterData(juzNumber: 7, hizbInJuz: 1, quarterName: "3/4", surahNumber: 6, surahName: "Al-An'am", startAyah: 99, pageNumber: 175),
  QuranQuarterData(juzNumber: 7, hizbInJuz: 1, quarterName: "End", surahNumber: 6, surahName: "Al-An'am", startAyah: 148, pageNumber: 179),
  
  QuranQuarterData(juzNumber: 7, hizbInJuz: 2, quarterName: "1/4", surahNumber: 6, surahName: "Al-An'am", startAyah: 149, pageNumber: 180),
  QuranQuarterData(juzNumber: 7, hizbInJuz: 2, quarterName: "1/2", surahNumber: 6, surahName: "Al-An'am", startAyah: 198, pageNumber: 184),
  QuranQuarterData(juzNumber: 7, hizbInJuz: 2, quarterName: "3/4", surahNumber: 6, surahName: "Al-An'am", startAyah: 247, pageNumber: 188),
  QuranQuarterData(juzNumber: 7, hizbInJuz: 2, quarterName: "End", surahNumber: 6, surahName: "Al-An'am", startAyah: 296, pageNumber: 192),

  // Juz 8 - Al-A'raf (1-206)
  QuranQuarterData(juzNumber: 8, hizbInJuz: 1, quarterName: "1/4", surahNumber: 7, surahName: "Al-A'raf", startAyah: 1, pageNumber: 193),
  QuranQuarterData(juzNumber: 8, hizbInJuz: 1, quarterName: "1/2", surahNumber: 7, surahName: "Al-A'raf", startAyah: 50, pageNumber: 197),
  QuranQuarterData(juzNumber: 8, hizbInJuz: 1, quarterName: "3/4", surahNumber: 7, surahName: "Al-A'raf", startAyah: 99, pageNumber: 201),
  QuranQuarterData(juzNumber: 8, hizbInJuz: 1, quarterName: "End", surahNumber: 7, surahName: "Al-A'raf", startAyah: 148, pageNumber: 205),
  
  QuranQuarterData(juzNumber: 8, hizbInJuz: 2, quarterName: "1/4", surahNumber: 7, surahName: "Al-A'raf", startAyah: 149, pageNumber: 206),
  QuranQuarterData(juzNumber: 8, hizbInJuz: 2, quarterName: "1/2", surahNumber: 7, surahName: "Al-A'raf", startAyah: 198, pageNumber: 210),
  QuranQuarterData(juzNumber: 8, hizbInJuz: 2, quarterName: "3/4", surahNumber: 7, surahName: "Al-A'raf", startAyah: 247, pageNumber: 214),
  QuranQuarterData(juzNumber: 8, hizbInJuz: 2, quarterName: "End", surahNumber: 7, surahName: "Al-A'raf", startAyah: 296, pageNumber: 218),

  // Juz 9 - Al-Anfal (1-75) and At-Tawbah (1-129)
  QuranQuarterData(juzNumber: 9, hizbInJuz: 1, quarterName: "1/4", surahNumber: 8, surahName: "Al-Anfal", startAyah: 1, pageNumber: 219),
  QuranQuarterData(juzNumber: 9, hizbInJuz: 1, quarterName: "1/2", surahNumber: 8, surahName: "Al-Anfal", startAyah: 50, pageNumber: 223),
  QuranQuarterData(juzNumber: 9, hizbInJuz: 1, quarterName: "3/4", surahNumber: 8, surahName: "Al-Anfal", startAyah: 99, pageNumber: 227),
  QuranQuarterData(juzNumber: 9, hizbInJuz: 1, quarterName: "End", surahNumber: 8, surahName: "Al-Anfal", startAyah: 148, pageNumber: 231),
  
  QuranQuarterData(juzNumber: 9, hizbInJuz: 2, quarterName: "1/4", surahNumber: 8, surahName: "Al-Anfal", startAyah: 149, pageNumber: 232),
  QuranQuarterData(juzNumber: 9, hizbInJuz: 2, quarterName: "1/2", surahNumber: 8, surahName: "Al-Anfal", startAyah: 198, pageNumber: 236),
  QuranQuarterData(juzNumber: 9, hizbInJuz: 2, quarterName: "3/4", surahNumber: 8, surahName: "Al-Anfal", startAyah: 247, pageNumber: 240),
  QuranQuarterData(juzNumber: 9, hizbInJuz: 2, quarterName: "End", surahNumber: 8, surahName: "Al-Anfal", startAyah: 296, pageNumber: 244),

  // Juz 10 - Yunus (1-109)
  QuranQuarterData(juzNumber: 10, hizbInJuz: 1, quarterName: "1/4", surahNumber: 10, surahName: "Yunus", startAyah: 1, pageNumber: 245),
  QuranQuarterData(juzNumber: 10, hizbInJuz: 1, quarterName: "1/2", surahNumber: 10, surahName: "Yunus", startAyah: 50, pageNumber: 249),
  QuranQuarterData(juzNumber: 10, hizbInJuz: 1, quarterName: "3/4", surahNumber: 10, surahName: "Yunus", startAyah: 99, pageNumber: 253),
  QuranQuarterData(juzNumber: 10, hizbInJuz: 1, quarterName: "End", surahNumber: 10, surahName: "Yunus", startAyah: 148, pageNumber: 257),
  
  QuranQuarterData(juzNumber: 10, hizbInJuz: 2, quarterName: "1/4", surahNumber: 10, surahName: "Yunus", startAyah: 149, pageNumber: 258),
  QuranQuarterData(juzNumber: 10, hizbInJuz: 2, quarterName: "1/2", surahNumber: 10, surahName: "Yunus", startAyah: 198, pageNumber: 262),
  QuranQuarterData(juzNumber: 10, hizbInJuz: 2, quarterName: "3/4", surahNumber: 10, surahName: "Yunus", startAyah: 247, pageNumber: 266),
  QuranQuarterData(juzNumber: 10, hizbInJuz: 2, quarterName: "End", surahNumber: 10, surahName: "Yunus", startAyah: 296, pageNumber: 270),
];

// Helper function to get quarters for a specific Juz
List<QuranQuarterData> getQuartersForJuz(int juzNumber) {
  return quranQuartersData.where((quarter) => quarter.juzNumber == juzNumber).toList();
}

// Helper function to get quarters for a specific Hizb in a Juz
List<QuranQuarterData> getQuartersForHizb(int juzNumber, int hizbInJuz) {
  return quranQuartersData.where((quarter) =>
    quarter.juzNumber == juzNumber && quarter.hizbInJuz == hizbInJuz
  ).toList();
}
