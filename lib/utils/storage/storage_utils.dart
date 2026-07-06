import 'package:fortune_fiesta/app/data/models/dto/user.dart';
import 'package:fortune_fiesta/app/data/models/response/app_config_response.dart';
import 'package:get_storage/get_storage.dart';

class Storage {
  Storage._privateConstructor();

  static final _box = GetStorage();

  static AppConfig getAppConfig() =>
      AppConfig.fromJson(_box.read(StorageKeys.appConfig));

  static void setAppConfig(AppConfig appConfig) =>
      _box.write(StorageKeys.appConfig, appConfig.toJson());

  static User getUser() => User.fromJson(_box.read(StorageKeys.user));

  static void setUser(User? user) =>
      _box.write(StorageKeys.user, user?.toJson());

  static bool isUserExists() => _box.read(StorageKeys.user) != null;
}

class StorageKeys {
  StorageKeys._privateConstructor();

  static const appConfig = 'app_config';
  static const user = 'user';
}
