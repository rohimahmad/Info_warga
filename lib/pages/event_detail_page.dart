import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  final String title;
  final DateTime date;
  final String location;
  final String? description;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.title,
    required this.date,
    required this.location,
    this.description,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Stream<List<Map<String, dynamic>>> _attendanceStream;
  bool _isLoading = true;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _attendanceStream = Supabase.instance.client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .map((list) => list.cast<Map<String, dynamic>>());
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

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} $hh:$mm';
  }

  Future<void> _confirmAttendance(BuildContext context) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Silakan login untuk konfirmasi')));
      return;
    }
    
    try {
      // Check if already confirmed
      final existing = await client
          .from('attendance')
          .select()
          .eq('event_id', widget.eventId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existing != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Anda telah melakukan konfirmasi')));
        }
        return;
      }
      
      // Show dialog with 2 options
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi Kehadiran'),
            content: const Text('Pilih status kehadiran Anda:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _submitAttendance(userId, 'not_going');
                },
                child: const Text('Izin'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _submitAttendance(userId, 'going');
                },
                child: const Text('Hadir'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
  
  Future<void> _submitAttendance(String userId, String status) async {
    final client = Supabase.instance.client;
    try {
      // For now, only 'going' status is supported by database constraint
      // Store both going and not_going as valid attendance records
      await client.from('attendance').insert({
        'event_id': widget.eventId,
        'user_id': userId,
        'status': status == 'not_going' ? 'going' : status, // Temporarily map not_going to going
        'note': status == 'not_going' ? 'Izin' : null, // Use note field to store "Izin"
      });
      if (mounted) {
        final message = status == 'going' 
            ? 'Terima kasih, Anda akan hadir!' 
            : 'Terima kasih telah konfirmasi Izin Anda';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              content: Text('Gagal menyimpan konfirmasi: $e'),
              backgroundColor: Colors.red,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [const Icon(Icons.calendar_today), const SizedBox(width: 8), Text(_formatDate(widget.date))]),
            const SizedBox(height: 10),
            Row(children: [const Icon(Icons.place), const SizedBox(width: 8), Text(widget.location)]),
            const SizedBox(height: 20),
            Text(widget.description?.isNotEmpty == true ? widget.description! : 'Tidak ada deskripsi'),
            const SizedBox(height: 20),
            if (_role == 'admin') ...[
              const Text('Daftar Peserta:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _attendanceStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final attendees = snapshot.data ?? [];
                    if (attendees.isEmpty) {
                      return const Center(child: Text('Belum ada peserta yang konfirmasi'));
                    }

                    return ListView.builder(
                      itemCount: attendees.length,
                      itemBuilder: (context, index) {
                        final attendance = attendees[index];
                        final userId = attendance['user_id'];
                        final status = attendance['status'];
                        final note = attendance['note'];

                        return FutureBuilder<Map<String, dynamic>>(
                          future: Supabase.instance.client
                              .from('profiles')
                              .select('full_name')
                              .eq('id', userId)
                              .single(),
                          builder: (context, profileSnapshot) {
                            final fullName = profileSnapshot.data?['full_name'] ?? 'Pengguna';
                            final isIzin = note == 'Izin';
                            final isHadir = status == 'going' && !isIzin;
                            
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  isHadir ? Icons.check_circle : (isIzin ? Icons.schedule : Icons.help),
                                  color: isHadir ? Colors.green : (isIzin ? Colors.orange : Colors.grey),
                                ),
                                title: Text(fullName),
                                subtitle: Text(isHadir ? 'Hadir' : (isIzin ? 'Izin' : 'Belum Konfirmasi')),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              const Text('Konfirmasi Kehadiran:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_available, size: 48, color: Colors.blue),
                      const SizedBox(height: 12),
                      const Text('Klik tombol di bawah untuk\nkonfirmasi kehadiran Anda'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmAttendance(context),
                  child: const Text('Pilih Status Kehadiran'),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
