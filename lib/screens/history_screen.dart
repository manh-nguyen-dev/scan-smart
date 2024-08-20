import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../helpers/confirm_dialog.dart';
import '../models/scan_model.dart';
import '../utils/snackbar_util.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanModel>> _scansFuture;

  @override
  void initState() {
    super.initState();
    _scansFuture = DatabaseHelper().getScans();
  }

  Future<void> _refreshScans() async {
    setState(() {
      _scansFuture = DatabaseHelper().getScans();
    });
  }

  Future<void> _deleteScan(int id) async {
    await DatabaseHelper().deleteScan(id);
    _refreshScans();
  }

  Future<void> _deleteAllScans() async {
    await DatabaseHelper().deleteAllScans();
    _refreshScans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await showConfirmDialog(
                context,
                title: 'Confirm Deletion',
                content: 'Are you sure you want to delete all scans?',
                confirmText: 'Delete All',
                cancelText: 'Cancel',
              );

              if (confirm == true) {
                await _deleteAllScans();
                if (!context.mounted) return;
                showSnackBar(context, 'Deleted');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ScanModel>>(
        future: _scansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scans found.'));
          }

          final scans = snapshot.data!;
          return ListView.builder(
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              return ListTile(
                title: Text(
                  scan.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: scan.image != null
                    ? Image.memory(scan.image!)
                    : const Icon(Icons.image_not_supported_rounded),
                subtitle: Text(
                  DateFormat('HH:mm dd/MM/yyyy').format(scan.timestamp),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      title: 'Confirm Deletion',
                      content: 'Are you sure you want to this scans',
                      confirmText: 'Delete',
                      cancelText: 'Cancel',
                    );

                    if (confirm == true) {
                      await _deleteScan(scan.id!);
                      if (!context.mounted) return;
                      showSnackBar(context, 'Deleted');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
