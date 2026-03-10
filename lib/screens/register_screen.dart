import 'package:flutter/material.dart';
import 'package:gawein/screens/login_screen.dart';
import 'package:gawein/screens/otp_screen.dart'; // Rute ke OTP
import 'package:supabase_flutter/supabase_flutter.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController(); 
  final _emailController = TextEditingController();
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _dobController.dispose();
    _emailController.dispose(); 
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime maxDate = DateTime(today.year - 17, today.month, today.day); 

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: DateTime(1950),
      lastDate: maxDate, 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // Fungsi Register ke Supabase
  Future<void> _prosesRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        // JIKA BERHASIL, LEMPAR KE HALAMAN OTP
        if (response.user != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(email: email), // Kirim email ke layar OTP
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal Mendaftar: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Daftar untuk mulai mencari kerja',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama sesuai KTP',
                        icon: Icons.person_outline,
                        validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          controller: _dobController,
                          readOnly: true, 
                          onTap: () => _selectDate(context),
                          decoration: _inputDecoration('Tanggal Lahir', 'Pilih tanggal lahir', Icons.calendar_today_outlined),
                          validator: (value) => value!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
                        ),
                      ),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'email@gmail.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
                      ),

                      _buildTextField(
                        label: 'NIK',
                        hint: 'Masukkan 16 digit NIK',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'NIK tidak boleh kosong';
                          if (value.length != 16) return 'NIK harus 16 digit';
                          return null;
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _inputDecoration('Password', 'Buat password', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: TextFormField(
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: _inputDecoration('Konfirmasi Password', 'Ketik ulang password', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) return 'Password tidak cocok';
                            return null;
                          },
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _prosesRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Or Register with', style: TextStyle(color: Colors.grey.shade600)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(Icons.facebook, Colors.blue),
                          const SizedBox(width: 20),
                          _socialButton(Icons.g_mobiledata, Colors.red, isLarge: true), 
                          const SizedBox(width: 20),
                          _socialButton(Icons.apple, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Punya akun GaweIn? ', style: TextStyle(color: Colors.grey[600])),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required String hint, 
    required IconData icon, 
    TextInputType? keyboardType,
    int? maxLength,
    TextEditingController? controller, 
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: _inputDecoration(label, hint, icon).copyWith(
          counterText: '', 
        ),
        validator: validator,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: isLarge ? 32 : 24),
    );
  }
}