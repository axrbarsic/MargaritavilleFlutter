import '../models/appearance_settings.dart';

abstract interface class AppearanceSettingsRepository {
  Future<AppearanceSettings> load();

  Future<void> save(AppearanceSettings settings);
}
