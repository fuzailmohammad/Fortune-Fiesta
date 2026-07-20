import 'package:fortune_fiesta/app/data/network/network_requester.dart';
import 'package:get/get.dart';

class BaseRepository {
  NetworkRequester get controller => GetInstance().find<NetworkRequester>();
}
