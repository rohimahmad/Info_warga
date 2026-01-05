import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_announcement_page.dart';
import 'add_event_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      
      setState(() {
        _isAdmin = data['role'] == 'admin';
        _isLoading = false;
      });

      if (!_isAdmin && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akses ditolak: Hanya admin yang dapat mengakses')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(
          child: Text('Akses Ditolak: Hanya admin yang dapat mengakses panel ini'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(context, 'Tambah Pengumuman', Icons.note_add, const AddAnnouncementPage()),
          _item(context, 'Tambah Event', Icons.event, const AddEventPage()),
        ],
      ),
    );
  }

  Widget _item(BuildContext c, String title, IconData icon, Widget page) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}