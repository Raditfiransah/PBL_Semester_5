import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Full Authentication flow smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    // 1. Onboarding Screen
    expect(find.text('Perpustakaan'), findsOneWidget);
    expect(find.text('Temukan Buku,\nRaih Ilmu'), findsOneWidget);

    // Slide 1 -> Slide 2
    await tester.tap(find.text('Selanjutnya'));
    await tester.pumpAndSettle();
    expect(find.text('Jelajahi Koleksi\nPerpustakaan'), findsOneWidget);

    // Slide 2 -> Slide 3
    await tester.tap(find.text('Selanjutnya'));
    await tester.pumpAndSettle();
    expect(find.text('Kelola Peminjaman\ndengan Mudah'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);

    // 2. Slide 3 -> Login Page
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    // Verify Login Page
    expect(find.text('Selamat datang kembali!'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);

    // 3. Login Page -> Register Page
    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    // Verify Register Page (Email only, without NIM)
    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);

    // Fill registration form
    await tester.enterText(find.widgetWithText(TextFormField, 'Nama Lengkap'), 'Budi Santoso');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'budi@kampus.ac.id');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Konfirmasi Password'), 'secret123');

    // Agree to terms
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byIcon(Icons.check_box_outline_blank_rounded));
    await tester.pumpAndSettle();

    // Submit registration -> Email Verification Page
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pumpAndSettle();

    // 4. Verify Email Verification Page
    expect(find.text('Verifikasi Email'), findsOneWidget);
    expect(find.text('Kami telah mengirimkan kode OTP ke\nemail kamu.'), findsOneWidget);
    expect(find.text('Kirim ulang', skipOffstage: false), findsWidgets);
  });
}
