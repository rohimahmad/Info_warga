import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Supabase.initialize(
		url: 'https://qxycygomqzctmzuabpod.supabase.co',
		anonKey:
				'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4eWN5Z29tcXpjdG16dWFicG9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc0NzEzMzIsImV4cCI6MjA4MzA0NzMzMn0.z_3XuxVhlxpIQRXSKdonmtubf6H87yn6UCfIB-ewhI4',
	);
	runApp(const InfoWargaApp());
}

class InfoWargaApp extends StatelessWidget {
	const InfoWargaApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'Info Warga',
			home: const AuthGate(),
			theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
		);
	}
}

class AuthGate extends StatelessWidget {
	const AuthGate({super.key});

	@override
	Widget build(BuildContext context) {
		return StreamBuilder<AuthState>(
			stream: Supabase.instance.client.auth.onAuthStateChange,
			builder: (context, snapshot) {
				final session = snapshot.data?.session ??
						Supabase.instance.client.auth.currentSession;
				if (session == null) {
					return const LoginPage();
				}
				return const HomePage();
			},
		);
	}
}
 