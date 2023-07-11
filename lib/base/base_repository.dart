import 'package:get/get.dart';
import 'package:fortune_fiesta/app/data/network/network_requester.dart';

class BaseRepository {
  NetworkRequester get controller => GetInstance().find<NetworkRequester>();
}
