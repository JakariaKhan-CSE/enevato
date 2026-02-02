import 'package:get/get.dart';
import 'package:myenvato/controller/earning/earning_controller.dart';
import 'package:myenvato/controller/marketstates/market_states_controller.dart';
import 'package:myenvato/controller/statement/statement_controller.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/controller/user/user_badge_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';

class Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<EarningsController>(() => EarningsController());
    Get.lazyPut<StatementController>(() => StatementController());
    Get.lazyPut<MarketStatsController>(() => MarketStatsController());
    Get.lazyPut<BadgeController>(() => BadgeController());
    Get.lazyPut<UserController>(() => UserController());
  }
}
