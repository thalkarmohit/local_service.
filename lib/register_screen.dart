import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final error = await _authService.register(
      name: _nameController.text,
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
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 28),
                _buildGoogleButton(),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF1A1A2E), size: 20),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Create account',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join to book trusted local services',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xFF888888),
          ),
        ),
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
            const Text(
              'G',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sign up with Google',
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

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or sign up with email',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        hintText: 'e.g. Rahul Sharma',
        prefixIcon: Icon(Icons.person_outline_rounded,
            color: Color(0xFF1565C0), size: 20),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter your name';
        if (v.trim().length < 2) return 'Name is too short';
        return null;
      },
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
        hintText: 'Min. 6 characters',
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
        if (v == null || v.isEmpty) return 'Please enter a password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: Color(0xFF1565C0), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFFAAAAAA),
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: Colors.white),
      )
          : const Text('Create Account'),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Color(0xFF888888), fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Sign In',
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