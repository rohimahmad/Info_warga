import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEventPage extends StatefulWidget {
  final String? eventId;
  final String? initialTitle;
  final String? initialDate;
  final String? initialLocation;
  final String? initialDescription;

  const AddEventPage({
    super.key,
    this.eventId,
    this.initialTitle,
    this.initialDate,
    this.initialLocation,
    this.initialDescription,
  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialDate != null) {
      _selectedDateTime = DateTime.tryParse(widget.initialDate!);
    }
    if (widget.initialLocation != null) {
      _locationController.text = widget.initialLocation!;
    }
    if (widget.initialDescription != null) {
      _descController.text = widget.initialDescription!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final desc = _descController.text.trim();
    
    if (title.isEmpty || location.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Judul, tanggal, lokasi wajib diisi')));
      return;
    }
    
    setState(() => _loading = true);
    final client = Supabase.instance.client;
    try {
      if (widget.eventId != null) {
        // Edit existing event
        await client
            .from('events')
            .update({
              'title': title,
              'description': desc.isEmpty ? null : desc,
              'date': _selectedDateTime!.toUtc().toIso8601String(),
              'location': location,
            })
            .eq('id', widget.eventId!);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Event diperbarui')));
          Navigator.pop(context);
        }
      } else {
        // Create new event
        await client.from('events').insert({
          'title': title,
          'description': desc.isEmpty ? null : desc,
          'date': _selectedDateTime!.toUtc().toIso8601String(),
          'location': location,
          'created_by': client.auth.currentUser?.id,
        });
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Event tersimpan')));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventId != null;
    final dateText = _selectedDateTime != null
        ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
        : 'Pilih Tanggal & Waktu';
    
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Event' : 'Tambah Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul Event')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _selectDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(dateText),
            ),
            const SizedBox(height: 12),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi')),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEditing ? 'Perbarui Event' : 'Simpan Event'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
