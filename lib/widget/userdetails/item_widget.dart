import 'package:flutter/material.dart';

class ItemsWidget extends StatelessWidget {
  final String site;
  final String items;

  const ItemsWidget({
    Key? key,
    required this.site,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // No shadow
      color: const Color(0xFF351F13), // Dark background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
          children: [
            Text(
              site, // Display the site name
              style: TextStyle(
                fontSize: 18.0, // Adjust font size
                fontWeight: FontWeight.bold, // Bold text
                color: Colors.white, // Text color
              ),
            ),
            const SizedBox(height: 8.0), // Space between texts
            Text(
              'Items: $items', // Display the number of items
              style: TextStyle(
                fontSize: 16.0, // Adjust font size
                color: Colors.white70, // Slightly lighter text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
