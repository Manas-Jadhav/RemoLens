import 'package:flutter/material.dart';
import 'package:remote_finder_app/main.dart';

class Remote_Details_Page extends StatefulWidget {

  final Map<String, dynamic> remoteData;
  const Remote_Details_Page({super.key,required this.remoteData});

  @override
  State<Remote_Details_Page> createState() => _Remote_Details_PageState();
}

class _Remote_Details_PageState extends State<Remote_Details_Page> {
  bool _isDeleting = false;

  Future<void> _deleteRemote() async {
    // 1. Show Confirmation Dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Remote?'),
        content: Text(
            'Are you sure you want to delete the ${widget.remoteData['brand']} remote? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // 2. Delete from Supabase Database
      await supabase
          .from('remotes')
          .delete()
          .eq('id', widget.remoteData['id']);

      if (mounted) {
        Navigator.pop(context); // Close the details page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remote deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remote = widget.remoteData;
    final String brand = remote['brand'] ?? 'Unknown Brand';
    final String category = remote['category'] ?? 'General';
    final int price = remote['price'] ?? 0;
    final String rack = remote['rack_no'] ?? 'Not Available';
    final String imageUrl = remote['image_url'] ?? '';
    final String id = remote['id'].toString();

    final String? similarity = remote['similarity'] != null
        ? "${(remote['similarity'] * 100).toStringAsFixed(1)}% Match"
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(brand),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4, // 40% Width
                  child: Container(
                    height: 450, // Fixed height for consistency
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain, // Keep original aspect ratio
                        errorBuilder: (c, e, s) => const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16), // Spacer

                // RIGHT: The Details
                Expanded(
                  flex: 6, // 60% Width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueGrey.shade200),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Technical Details
                      _buildDetailRow("ID", id),
                      const SizedBox(height: 10),
                      _buildDetailRow("Type", "Infrared / Bluetooth"), // Placeholder
                      const SizedBox(height: 10),
                      _buildDetailRow("Price", "₹ "+price.toString()),
                      const SizedBox(height: 10),
                      _buildDetailRow("Rack Number", rack), // Placeholder
                      const SizedBox(height: 10),

                      // Show Similarity Badge if available
                      if (similarity != null)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              const SizedBox(width: 5),
                              Text(
                                similarity,
                                style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // --- BOTTOM SECTION: Action Buttons ---
            Row(
              children: [
                // Edit Button (Placeholder)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add Update Logic later
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit feature coming soon!")));
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Info"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueGrey[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteRemote,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Delete Remote"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for small text rows
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}