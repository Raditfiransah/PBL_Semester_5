import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmailVerificationPage extends StatefulWidget {
  final String? email;

  const EmailVerificationPage({super.key, this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const Color _primaryColor = Color(0xFF2B62B8);
  static const Color _textDarkColor = Color(0xFF1E293B);
  static const Color _textMutedColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 56;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendCountdown = 56;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleResend() {
    if (_resendCountdown == 0) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP baru telah dikirimkan ke email kamu.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi email berhasil!'),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative subtle wave at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 180,
            child: CustomPaint(
              painter: _BottomWavePainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Email send illustration
                        Image.asset(
                          'lib/images/send_email.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Verifikasi Email',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Kami telah mengirimkan kode OTP ke\nemail kamu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _textMutedColor,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 36),
                        // 6-digit OTP Input
                        _buildOtpInputRow(),
                        const SizedBox(height: 36),
                        // Resend text
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Tidak menerima kode? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: _textMutedColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: _resendCountdown == 0 ? _handleResend : null,
                              child: Text(
                                'Kirim ulang',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _resendCountdown == 0
                                      ? _primaryColor
                                      : _textMutedColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: _textDarkColor,
            ),
            splashRadius: 24,
          ),
          Text(
            _resendCountdown > 0
                ? 'Kirim ulang ($_resendCountdown)'
                : 'Kirim ulang',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) => _buildOtpBox(index)),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 52,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _otpControllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
            _otpControllers[index - 1].clear();
          }
        },
        child: TextFormField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDarkColor,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryColor, width: 1.8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
                _verifyOtp();
              }
            }
          },
        ),
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFEBF3FC).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.45);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.55,
    );
    path1.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.75,
      size.width,
      size.height * 0.65,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    final paint2 = Paint()
      ..color = const Color(0xFFDDEAF9).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.75,
    );
    path2.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.88,
      size.width,
      size.height * 0.8,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
