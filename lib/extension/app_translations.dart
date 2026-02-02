import 'package:get/get.dart';
import 'package:myenvato/extension/en.dart';
import 'package:myenvato/extension/es.dart';


class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': En.values,
        'es': Es.values,
      };
}
