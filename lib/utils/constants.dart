class AppConstants {
  // API URLs
  static const String mockApiBaseUrl = 'https://6842dfb6e1347494c31e4678.mockapi.io/allPets/pets';
  
  // Storage Keys
  static const String petsStorageKey = 'pets';
  static const String notificationsStorageKey = 'notifications';
  static const String settingsStorageKey = 'settings';
  
  // Notification Channel
  static const String notificationChannelId = 'pet_care_channel';
  static const String notificationChannelName = 'Pet Care Reminders';
  static const String notificationChannelDescription = 'Notifications for pet care reminders';
  
  // Pet Types
  static const List<String> petTypes = [
    'Anjing',
    'Kucing',
    'Burung',
    'Ikan',
    'Kelinci',
    'Hamster',
    'Guinea Pig',
    'Reptil',
    'Lainnya',
  ];
  
  // Care Types
  static const List<String> careTypes = [
    'Vaksinasi',
    'Mandi',
    'Makan',
    'Checkup',
    'Grooming',
    'Obat',
  ];
  
  // Default Values
  static const int defaultVaccinationIntervalDays = 365;
  static const int defaultBathIntervalDays = 30;
  static const int defaultCheckupIntervalDays = 180;
  
  // Currency
  static const String defaultCurrency = 'IDR';
  static const Map<String, double> exchangeRates = {
    'USD': 0.000067,
    'EUR': 0.000061,
    'JPY': 0.0097,
    'SGD': 0.000090,
    'MYR': 0.00031,
  };
  
  // Location
  static const double defaultLatitude = -6.3728;
  static const double defaultLongitude = 106.8345;
  static const String defaultLocation = 'Depok, Jawa Barat';
  
  // Sensor
  static const double defaultShakeThreshold = 12.0;
  static const int shakeDetectionCooldownMs = 500;
  
  // Time Zones
  static const Map<String, int> timeZones = {
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'UTC': 0,
    'GMT': 0,
  };
  
  // App Info
  static const String appName = 'Pet Care Reminder';
  static const String appVersion = '1.0.0';
  static const String developerName = 'Pet Care Team';
  
  // Messages
  static const String noInternetMessage = 'Tidak ada koneksi internet';
  static const String loadingMessage = 'Memuat...';
  static const String errorMessage = 'Terjadi kesalahan';
  static const String successMessage = 'Berhasil';
  
  // Validation
  static const int minPetNameLength = 2;
  static const int maxPetNameLength = 50;
  static const double minCost = 0.0;
  static const double maxCost = 999999999.0;
}
