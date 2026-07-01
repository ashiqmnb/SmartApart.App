/// General app-wide constants — not related to API config.
/// Similar to a constants.js file you'd import across a React project.
class AppConstants {
  AppConstants._();

  static const String appName = 'SmartApart';
  static const String appVersion = '1.0.0';

  // Debounce delay for search inputs (e.g. resident directory search)
  static const Duration searchDebounce = Duration(milliseconds: 300);
}