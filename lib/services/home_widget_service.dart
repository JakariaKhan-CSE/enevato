// import 'package:home_widget/home_widget.dart';

// class HomeWidgetService {
//   static const String balanceKey = 'summary_balance';
//   static const String salesKey = 'summary_sales';
//   static const String appGroupId = 'group.com.example.myenvato';
//   static const String androidWidgetName = 'SummaryWidget';
//   static const String iosWidgetName = 'SummaryWidget';

//   static Future<void> init() async {
//     await HomeWidget.setAppGroupId(appGroupId);
//   }

//   static Future<void> updateSummary({
//     String? balance,
//     int? sales,
//   }) async {
//     if (balance != null) {
//       await HomeWidget.saveWidgetData(balanceKey, balance);
//     }
//     if (sales != null) {
//       await HomeWidget.saveWidgetData(salesKey, sales);
//     }
//     await HomeWidget.updateWidget(
//       name: androidWidgetName,
//       iOSName: iosWidgetName,
//     );
//   }
// }
