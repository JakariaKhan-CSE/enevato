import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class UserAccountWidget extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (userController.accountLoading.value) {
        return const LoadingShimmer();
      } else if (userController.accountError.isNotEmpty) {
        return Center(child: Text(userController.accountError.value));
      } else {
        var account = userController.userAccount;
        return Container(
          width: double.infinity,  // Full-width container
          margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 16.0),  // Outer margin for spacing
          decoration: BoxDecoration(
            color: const Color(0xFF351F13),  // Background color
            borderRadius: BorderRadius.circular(12.0),  // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),  // Soft shadow
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${account['firstname'] ?? ''} ${account['surname'] ?? ''}',  // Null check
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.account_circle, color: Colors.white, size: 30),
                  ],
                ),
                Divider(color: Colors.white.withOpacity(0.5), thickness: 1),

                // Earnings Section
                SizedBox(height: 10),
                _buildAccountInfoRow('Available Earnings:', account['available_earnings']?.toString() ?? '0'),
                SizedBox(height: 10),
                _buildAccountInfoRow('Total Deposits:', account['total_deposits']?.toString() ?? '0'),
                SizedBox(height: 10),
                _buildAccountInfoRow('Balance:', account['balance']?.toString() ?? '0'),
                SizedBox(height: 10),
                _buildAccountInfoRow('Country:', account['country'] ?? 'Unknown'),
              ],
            ),
          ),
        );
      }
    });
  }

  // Helper method to build each row for account details
  Widget _buildAccountInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          '\$$value',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
