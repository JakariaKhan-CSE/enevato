import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/marketstates/market_states_controller.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class MarketStatsScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final MarketStatsController marketStatsController =
      Get.put(MarketStatsController());
  MarketStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.brown[800], // Set AppBar color
             appBar: AppBar(
         surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.brown[900],
        title: const Text('Market Stats',style: TextStyle(color:Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Total User Card
              Center(
                child: Obx(() {
                  if (marketStatsController.isLoading.value) {
                    return const LoadingShimmer();
                  } else {
                    return _buildTotalUserCard(
                        marketStatsController.totalUsers.value);
                  }
                }),
              ),
              const SizedBox(height: 20), // Space between cards
              // Total Items Card
              Center(
                child: Obx(() {
                  if (marketStatsController.isLoading.value) {
                    return const LoadingShimmer();
                  } else {
                    return _buildTotalItemsCard(
                        marketStatsController.totalItems.value);
                  }
                }),
              ),
              const SizedBox(height: 20), // Space between cards
              // Number of Files Card
              Obx(() {
                return _buildNumberOfFilesCard(
                    marketStatsController.numberOfFiles);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Total Users Card
  Widget _buildTotalUserCard(int totalUsers) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF351F13), // Background card color
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Total Users label
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF901F1B), // Red color on the left
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Text(
              'Total Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Right Side: Number of Users
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFEC037), // Yellow color on the right
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              totalUsers.toString(),
              style: const TextStyle(
                color:
                    Color(0xFF351F13), // Text color that matches the background
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Total Items Card
  Widget _buildTotalItemsCard(int totalItems) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF351F13), // Background card color
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Total Items label
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF901F1B), // Red color on the left
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Text(
              'Total Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Right Side: Number of Items
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFEC037), // Yellow color on the right
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              totalItems.toString(),
              style: const TextStyle(
                color:
                    Color(0xFF351F13), // Text color that matches the background
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildNumberOfFilesCard(List<dynamic> numberOfFiles) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal:10.0),
    padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF351F13), // Background card color
        borderRadius: BorderRadius.circular(16.0),),
    child: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Number of Files by Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Color.fromARGB(255, 165, 91, 51),),
          const SizedBox(height: 10),
          // Use a ListView.builder to allow for scrolling if necessary
          ...numberOfFiles.map((file) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side: Category Name
                  Expanded(
                    child: Text(
                      file['category'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Right Side: Number of Files
                  Text(
                    file['number_of_files'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}
