import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final error = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isGoogleLoading = true);

    final error = await _authService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (error != null && error != 'Sign-in cancelled.') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter your email first, then tap Forgot Password.')),
      );
      return;
    }
    final error = await _authService.resetPassword(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
          Text(error ?? 'Password reset email sent! Check your inbox.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildForgotPassword(),
                const SizedBox(height: 28),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildGoogleButton(),
                const SizedBox(height: 24),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.home_repair_service_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome back',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to book local services',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email address',
        hintText: 'you@example.com',
        prefixIcon:
        Icon(Icons.email_outlined, color: Color(0xFF1565C0), size: 20),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter your email';
        if (!v.contains('@')) return 'Enter a valid email address';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: Color(0xFF1565C0), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFFAAAAAA),
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _forgotPassword,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Forgot password?',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: Colors.white),
      )
          : const Text('Sign In'),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _googleSignIn,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A1A2E),
          side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
        ),
        child: _isGoogleLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFF1565C0)),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo drawn with text styling
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'G',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4285F4),
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Color(0xFF888888), fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}