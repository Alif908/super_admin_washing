import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_admin_washing/models/superadminmodel.dart';
import 'package:super_admin_washing/services/SuperAdminApiService.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // ← ADD 3

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────
  String? _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final mobile = _mobileController.text.trim();

    if (name.isEmpty) return 'Please enter your full name';
    if (email.isEmpty || !email.contains('@'))
      return 'Please enter a valid email';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (mobile.length < 10) return 'Please enter a valid mobile number';
    return null;
  }

  // ── Sign Up handler ──────────────────────────
  Future<void> _handleSignUp() async {
    // Step 1: validate
    final error = _validate();
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    // Step 2: build SignupRequestModel
    final SignupRequestModel request = SignupRequestModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      mobile: _mobileController.text.trim(),
    );

    // Step 3: call API
    setState(() => _isLoading = true);

    final Map<String, dynamic> raw = await SuperAdminService.signup(
      name: request.name,
      email: request.email,
      password: request.password,
      mobile: request.mobile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Step 4: parse into AuthResponseModel
    final AuthResponseModel response = AuthResponseModel.fromJson(
      raw,
      success: raw['success'] ?? false,
    );

    // Step 5: handle
    if (response.success) {
      _showSnack(
        response.message.isNotEmpty
            ? response.message
            : 'Account created successfully!',
      );
      Navigator.pop(context);
    } else {
      _showSnack(
        response.message.isNotEmpty ? response.message : 'Sign up failed',
        isError: true,
      );
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final screenW = mq.size.width;
    final keyboardH = mq.viewInsets.bottom;

    final isSmall = screenH < 680;
    final isLarge = screenH > 850;

    final hPad = screenW * 0.07;
    final titleSz = isSmall
        ? 22.0
        : isLarge
        ? 30.0
        : 26.0;
    final subSz = isSmall ? 13.0 : 15.0;
    final fieldH = isSmall ? 48.0 : 56.0;
    final btnH = isSmall ? 46.0 : 54.0;
    final fieldGap = isSmall ? 10.0 : 14.0;
    final topGap = isSmall ? screenH * 0.08 : screenH * 0.14;
    final botGap = isSmall ? screenH * 0.06 : screenH * 0.10;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E2A),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(bottom: keyboardH),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenH - mq.padding.top - mq.padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: screenH * 0.018,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: subSz,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: subSz + 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: topGap),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Your Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSz,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: screenH * 0.007),
                            Text(
                              'Join us and get started!',
                              style: TextStyle(
                                color: const Color(0xFFB0B8D4),
                                fontSize: subSz,
                              ),
                            ),
                            SizedBox(height: screenH * 0.038),

                            _buildTextField(
                              controller: _nameController,
                              hint: 'Full Name',
                              keyboardType: TextInputType.name,
                              fieldHeight: fieldH,
                              fontSize: subSz,
                            ),
                            SizedBox(height: fieldGap),

                            _buildTextField(
                              controller: _emailController,
                              hint: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              fieldHeight: fieldH,
                              fontSize: subSz,
                            ),
                            SizedBox(height: fieldGap),

                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Password',
                              obscureText: _obscurePassword,
                              isFocused: true,
                              fieldHeight: fieldH,
                              fontSize: subSz,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF8892B0),
                                  size: subSz + 7,
                                ),
                              ),
                            ),
                            SizedBox(height: fieldGap),

                            _buildTextField(
                              controller: _mobileController,
                              hint: 'Mobile Number',
                              keyboardType: TextInputType.phone,
                              fieldHeight: fieldH,
                              fontSize: subSz,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: screenH * 0.032),

                            SizedBox(
                              width: double.infinity,
                              height: btnH,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2D1B8E),
                                      Color(0xFF7B2FBE),
                                      Color(0xFF9B35D6),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'SIGN UP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: subSz + 1,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: botGap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required double fieldHeight,
    required double fontSize,
    bool obscureText = false,
    bool isFocused = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2150),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF3D5AFE).withOpacity(0.6)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF6B7AAB),
            fontSize: fontSize,
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }
}
