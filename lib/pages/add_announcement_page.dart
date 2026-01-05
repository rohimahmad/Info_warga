import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAnnouncementPage extends StatefulWidget {
	final String? announcementId;
	final String? initialTitle;
	final String? initialBody;

	const AddAnnouncementPage({
		super.key,
		this.announcementId,
		this.initialTitle,
		this.initialBody,
	});

	@override
	State<AddAnnouncementPage> createState() => _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends State<AddAnnouncementPage> {
	final _titleController = TextEditingController();
	final _bodyController = TextEditingController();
	bool _loading = false;

	@override
	void initState() {
		super.initState();
		if (widget.initialTitle != null) {
			_titleController.text = widget.initialTitle!;
		}
		if (widget.initialBody != null) {
			_bodyController.text = widget.initialBody!;
		}
	}

	@override
	void dispose() {
		_titleController.dispose();
		_bodyController.dispose();
		super.dispose();
	}

	Future<void> _save() async {
		final title = _titleController.text.trim();
		final body = _bodyController.text.trim();
		if (title.isEmpty || body.isEmpty) {
			ScaffoldMessenger.of(context)
					.showSnackBar(const SnackBar(content: Text('Judul dan isi wajib diisi')));
			return;
		}
		setState(() => _loading = true);
		final client = Supabase.instance.client;
		try {
			if (widget.announcementId != null) {
				// Edit existing announcement
				await client
					.from('announcements')
					.update({'title': title, 'body': body})
					.eq('id', widget.announcementId!);
				if (mounted) {
					ScaffoldMessenger.of(context)
							.showSnackBar(const SnackBar(content: Text('Pengumuman diperbarui')));
					Navigator.pop(context);
				}
			} else {
				// Create new announcement
				await client.from('announcements').insert({
					'title': title,
					'body': body,
					'created_by': client.auth.currentUser?.id,
				});
				if (mounted) {
					ScaffoldMessenger.of(context)
							.showSnackBar(const SnackBar(content: Text('Pengumuman tersimpan')));
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
		final isEditing = widget.announcementId != null;
		return Scaffold(
			appBar: AppBar(title: Text(isEditing ? 'Edit Pengumuman' : 'Tambah Pengumuman')),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul')),
						const SizedBox(height: 12),
						TextField(
							controller: _bodyController,
							maxLines: 4,
							decoration: const InputDecoration(labelText: 'Isi Pengumuman'),
						),
						const Spacer(),
						SizedBox(
							width: double.infinity,
							child: ElevatedButton(
								onPressed: _loading ? null : _save,
								child: _loading
										? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
										: Text(isEditing ? 'Perbarui' : 'Simpan'),
							),
						),
					],
				),
			),
		);
	}
}