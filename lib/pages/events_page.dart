import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'event_detail_page.dart';
import 'add_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _isLoading = true;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      setState(() {
        _role = data['role'] ?? 'user';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent(String id) async {
    try {
      await Supabase.instance.client.from('events').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Event dihapus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client
        .from('events')
        .stream(primaryKey: ['id'])
        .order('date', ascending: true);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada event'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final title = item['title'] as String? ?? '-';
              final location = item['location'] as String? ?? '-';
              final description = item['description'] as String?;
              final dateStr = item['date']?.toString();
              final itemId = item['id'].toString();
              DateTime? date;
              if (dateStr != null) {
                date = DateTime.tryParse(dateStr);
              }
              final subtitle = date != null
                  ? '${date.day}/${date.month}/${date.year} - $location'
                  : location;
              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  onTap: date == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailPage(
                                eventId: itemId,
                                title: title,
                                date: date!,
                                location: location,
                                description: description,
                              ),
                            ),
                          ),
                  trailing: _role == 'admin'
                      ? PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEventPage(
                                    eventId: itemId,
                                    initialTitle: title,
                                    initialDate: dateStr,
                                    initialLocation: location,
                                    initialDescription: description,
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              onTap: () => _deleteEvent(itemId),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
