import '../constants/app_constants.dart';

/// String validation and formatting utilities
class StringUtils {
  /// Validates email format
  static bool isValidEmail(String email) {
    final regex = RegExp(AppConstants.emailRegex);
    return regex.hasMatch(email);
  }

  /// Validates phone number format
  static bool isValidPhone(String phone) {
    final regex = RegExp(AppConstants.phoneRegex);
    return regex.hasMatch(phone);
  }

  /// Validates container number format
  static bool isValidContainerNumber(String containerNumber) {
    final regex = RegExp(AppConstants.containerNumberRegex);
    return regex.hasMatch(containerNumber);
  }

  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalizes the first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Converts camelCase to snake_case
  static String camelToSnake(String text) {
    return text.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// Converts snake_case to camelCase
  static String snakeToCamel(String text) {
    final parts = text.split('_');
    if (parts.length <= 1) return text;

    return parts.first + parts.skip(1).map((part) => capitalize(part)).join('');
  }

  /// Converts any string to title case
  static String toTitleCase(String text) {
    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Removes special characters and returns alphanumeric only
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  /// Truncates text to specified length with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Masks email for privacy (e.g., j***@example.com)
  static String maskEmail(String email) {
    if (!isValidEmail(email)) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}@$domain';
  }

  /// Masks phone number for privacy
  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;

    final visibleStart = phone.length > 7 ? 3 : 2;
    final visibleEnd = 2;
    final maskedCount = phone.length - visibleStart - visibleEnd;

    return phone.substring(0, visibleStart) +
        '*' * maskedCount +
        phone.substring(phone.length - visibleEnd);
  }

  /// Generates a random string of specified length
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random % chars.length)),
    );
  }

  /// Extracts initials from a full name
  static String getInitials(String name, {int maxInitials = 2}) {
    if (name.isEmpty) return '';

    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(maxInitials)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .where((initial) => initial.isNotEmpty)
        .join();

    return initials;
  }

  /// Formats container number with standard spacing
  static String formatContainerNumber(String containerNumber) {
    if (containerNumber.length != 11) return containerNumber;

    // Format: ABCD 123456 7
    return '${containerNumber.substring(0, 4)} '
        '${containerNumber.substring(4, 10)} '
        '${containerNumber.substring(10)}';
  }

  /// Pluralizes a word based on count
  static String pluralize(String word, int count) {
    if (count == 1) return word;

    // Simple pluralization rules
    if (word.endsWith('y')) {
      return '${word.substring(0, word.length - 1)}ies';
    } else if (word.endsWith('s') ||
        word.endsWith('sh') ||
        word.endsWith('ch') ||
        word.endsWith('x') ||
        word.endsWith('z')) {
      return '${word}es';
    } else {
      return '${word}s';
    }
  }

  /// Checks if string is null or empty
  static bool isNullOrEmpty(String? text) {
    return text == null || text.isEmpty;
  }

  /// Checks if string is null, empty, or only whitespace
  static bool isNullOrWhitespace(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Safe substring that won't throw out of bounds error
  static String safeSubstring(String text, int start, [int? end]) {
    if (start < 0) start = 0;
    if (start >= text.length) return '';

    if (end == null) return text.substring(start);
    if (end > text.length) end = text.length;
    if (end <= start) return '';

    return text.substring(start, end);
  }

  /// Counts words in a string
  static int wordCount(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Removes extra whitespace and normalizes spaces
  static String normalizeWhitespace(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Generates a slug from text (URL-friendly)
  static String generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
