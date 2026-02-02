import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/user_controller.dart';
import 'package:myenvato/widget/loading_shimmer.dart';

class UserDetailsWidget extends StatefulWidget {
  final String username;

  // Injecting the UserController
  final UserController userController = Get.put(UserController());

  UserDetailsWidget({required this.username});

  @override
  State<UserDetailsWidget> createState() => _UserDetailsWidgetState();
}

class _UserDetailsWidgetState extends State<UserDetailsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.userController.fetchUserDetails(widget.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.userController.detailsLoading.value) {
        return const LoadingShimmer();
      }

      if (widget.userController.detailsError.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text(widget.userController.detailsError.value)),
        );
      }

      if (widget.userController.userDetails.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text('No user data available.')),
        );
      }

      var user = widget.userController.userDetails;

      return Container(
        width: double.infinity,  // Full-width container
        margin: const EdgeInsets.symmetric(horizontal: 6.0),  // Outer margin for spacing
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Even space between items
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  Column(
                    children: [
                      Text(
                        user['followers'].toString(),
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Followers font size
                      ),
                      const Text(
                        'Followers',
                        style: TextStyle(fontSize: 14, color: Colors.white), // Smaller font size
                      ),
                    ],
                  ),

                  // Sales Section
                  Column(
                    children: [
                      Text(
                        user['sales'].toString(),
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Sales font size
                      ),
                      const Text(
                        'Sales',
                        style: TextStyle(fontSize: 14, color: Colors.white), // Smaller font size
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12), // Spacing between the user info row and username

              // Username Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circle Avatar for profile image
                  CircleAvatar(
                    radius: 20, // Slightly larger for better visibility
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: NetworkImage(user['image'] ?? ''),
                    child: user['image'] == null || user['image']!.isEmpty
                        ? const Icon(Icons.person, size: 24, color: Colors.white) // Default icon
                        : null,
                  ),
                  const SizedBox(width: 8), // Spacing between avatar and username

                  // Username
                  Text(
                    user['username'],
                    style: const TextStyle(
                      fontSize: 20, // Increased font size for better visibility
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set font color to white for contrast
                    ),
                  ),
                ],
              ),
              

            ],
          ),
        ),
      );
    });
  }
}
