import 'package:get/get.dart';
import 'package:cryptosquare/models/app_models.dart';

class UserController extends GetxController {
  final Rx<User> _user = User(id: 0, name: '', isLoggedIn: false).obs;

  User get user => _user.value;

  bool get isLoggedIn => _user.value.isLoggedIn;

  void login(User user) {
    _user.value = user;
  }

  void logout() {
    _user.value = User(id: 0, name: '', isLoggedIn: false);
  }
}
