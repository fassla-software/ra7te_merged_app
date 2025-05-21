import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/lib2/interface/repository_interface.dart';

abstract class OutOfZoneRepositoryInterface implements RepositoryInterface {
  Future<Response> getZoneList();
}
