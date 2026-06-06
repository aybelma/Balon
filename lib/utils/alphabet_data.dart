enum Language { french, arabic }

class AlphabetData {
  static const List<String> frenchLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static const List<String> arabicLetters = [
    'أ', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
    'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
    'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي',
  ];

  static const Map<String, List<String>> frenchSimilar = {
    'B': ['D', 'P', 'R'],
    'C': ['G', 'O', 'Q'],
    'D': ['B', 'O', 'Q'],
    'G': ['C', 'O', 'Q'],
    'M': ['N', 'W'],
    'N': ['M', 'H'],
    'O': ['C', 'D', 'Q'],
    'P': ['B', 'D', 'R'],
    'Q': ['C', 'G', 'O'],
    'U': ['V', 'N'],
    'V': ['U', 'W'],
    'W': ['M', 'V'],
    'I': ['L', 'J'],
    'J': ['I', 'L'],
    'L': ['I', 'J'],
  };

  static const Map<String, List<String>> arabicSimilar = {
    'ب': ['ت', 'ث', 'ن'],
    'ت': ['ب', 'ث'],
    'ث': ['ب', 'ت'],
    'ج': ['ح', 'خ'],
    'ح': ['ج', 'خ'],
    'خ': ['ج', 'ح'],
    'د': ['ذ'],
    'ذ': ['د'],
    'ر': ['ز'],
    'ز': ['ر'],
    'س': ['ش'],
    'ش': ['س'],
    'ص': ['ض'],
    'ض': ['ص'],
    'ط': ['ظ'],
    'ظ': ['ط'],
    'ع': ['غ'],
    'غ': ['ع'],
  };

  static List<String> getLettersForLevel(Language language, int level) {
    final letters =
        language == Language.french ? frenchLetters : arabicLetters;
    final total = letters.length;
    final count = level == 0
        ? 6
        : level == 1
            ? (total ~/ 2)
            : total;
    return letters.take(count).toList();
  }

  static String getLanguageCode(Language language) =>
      language == Language.french ? 'fr-FR' : 'ar-SA';

  static String getInstruction(Language language, String letter) {
    return language == Language.french
        ? 'Peux-tu trouver le $letter ?'
        : 'هل يمكنك إيجاد حرف $letter ؟';
  }

  static String getSuccessMessage(Language language, String letter) {
    return language == Language.french
        ? 'Bravo ! $letter !'
        : 'أحسنت ! $letter !';
  }

  static String getMissedMessage(Language language, String letter) {
    return language == Language.french
        ? 'Essayons encore ! Trouve le $letter !'
        : 'حاول مجدداً ! ابحث عن $letter !';
  }

  static String getDiscoveryTap(Language language, String letter) {
    return language == Language.french ? letter : letter;
  }

  static String levelName(Language language, int level) {
    if (language == Language.french) {
      return level == 0
          ? 'Débutant (A–F)'
          : level == 1
              ? 'Intermédiaire (A–M)'
              : 'Avancé (A–Z)';
    } else {
      return level == 0
          ? 'مبتدئ (أ–ح)'
          : level == 1
              ? 'متوسط (أ–ش)'
              : 'متقدم (أ–ي)';
    }
  }
}
