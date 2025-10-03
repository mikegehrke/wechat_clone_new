import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../main_navigation.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  int _resendTimer = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendOTP(_phoneController.text.trim());

      if (success && mounted) {
        setState(() {
          _otpSent = true;
          _resendTimer = 60;
        });
        _startResendTimer();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to send OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length == 6) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyOTP(
        _phoneController.text.trim(),
        _otpController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      }
    });
  }

  String _formatPhoneNumber(String phone) {
    // Add country code if not present
    if (!phone.startsWith('+')) {
      return '+49$phone'; // Germany country code
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Title
                Text(
                  _otpSent ? 'Verify Phone Number' : 'Enter Phone Number',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  _otpSent 
                    ? 'Enter the 6-digit code sent to\n${_phoneController.text}'
                    : 'We\'ll send you a verification code',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                if (!_otpSent) ...[
                  // Phone Number Field
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '+49 123 456 7890',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Send OTP Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'Send Code',
                        onPressed: authProvider.isLoading ? null : _sendOTP,
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),
                ] else ...[
                  // OTP Field
                  CustomTextField(
                    controller: _otpController,
                    label: 'Verification Code',
                    hint: '123456',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.security_outlined,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    onChanged: (value) {
                      if (value.length == 6) {
                        _verifyOTP();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.length != 6) {
                        return 'Please enter a 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Verify Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'Verify Code',
                        onPressed: authProvider.isLoading ? null : _verifyOTP,
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Resend Code
                  TextButton(
                    onPressed: _resendTimer > 0 ? null : () {
                      setState(() {
                        _otpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: Text(
                      _resendTimer > 0 
                        ? 'Resend code in ${_resendTimer}s'
                        : 'Didn\'t receive code? Send again',
                      style: TextStyle(
                        color: _resendTimer > 0 ? Colors.grey : const Color(0xFF07C160),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Terms
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}