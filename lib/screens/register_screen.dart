import 'package:flutter/material.dart';
import 'package:timtujuh/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // ==========================
  // DATE PICKER (MIN 17 TAHUN)
  // ==========================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime maxDate =
        DateTime(today.year - 17, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: DateTime(1950),
      lastDate: maxDate,
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  // ==========================
  // REGISTER FUNCTION
  // ==========================
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Create user di Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User user = userCredential.user!;

      // 2️⃣ Simpan data tambahan ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'nama': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'nik': _nikController.text.trim(),
        'tanggal_lahir': _dobController.text.trim(),
        'created_at': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Register berhasil!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";

      if (e.code == 'email-already-in-use') {
        message = "Email sudah terdaftar";
      } else if (e.code == 'weak-password') {
        message = "Password minimal 6 karakter";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isLoading = false);
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
              children: [
                const Text(
                  'Create Account',
                  style:
                      TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Daftar untuk mulai mencari kerja',
                  style:
                      TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      _buildTextField(
                        controller: _namaController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama sesuai KTP',
                        icon: Icons.person_outline,
                        validator: (value) =>
                            value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),

                      // DATE
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: _inputDecoration(
                              'Tanggal Lahir',
                              'Pilih tanggal lahir',
                              Icons.calendar_today_outlined),
                          validator: (value) =>
                              value!.isEmpty
                                  ? 'Tanggal lahir wajib diisi'
                                  : null,
                        ),
                      ),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'email@contoh.com',
                        icon: Icons.email_outlined,
                        keyboardType:
                            TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty
                                ? 'Email tidak boleh kosong'
                                : null,
                      ),

                      _buildTextField(
                        controller: _nikController,
                        label: 'NIK',
                        hint: 'Masukkan 16 digit NIK',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'NIK tidak boleh kosong';
                          }
                          if (value.length != 16) {
                            return 'NIK harus 16 digit';
                          }
                          return null;
                        },
                      ),

                      // PASSWORD
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          controller:
                              _passwordController,
                          obscureText:
                              !_isPasswordVisible,
                          decoration:
                              _inputDecoration(
                                      'Password',
                                      'Buat password',
                                      Icons
                                          .lock_outline)
                                  .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons
                                        .visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  setState(() =>
                                      _isPasswordVisible =
                                          !_isPasswordVisible),
                            ),
                          ),
                          validator: (value) =>
                              value!.length < 6
                                  ? 'Minimal 6 karakter'
                                  : null,
                        ),
                      ),

                      // CONFIRM PASSWORD
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 24.0),
                        child: TextFormField(
                          controller:
                              _confirmPasswordController,
                          obscureText:
                              !_isConfirmPasswordVisible,
                          decoration:
                              _inputDecoration(
                                      'Konfirmasi Password',
                                      'Ketik ulang password',
                                      Icons
                                          .lock_outline)
                                  .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons
                                        .visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  setState(() =>
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible),
                            ),
                          ),
                          validator: (value) {
                            if (value !=
                                _passwordController
                                    .text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : _registerUser,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.deepPurple,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          Colors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Punya akun GaweIn? ',
                            style: TextStyle(
                                color:
                                    Colors.grey[600]),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator
                                  .pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors
                                      .deepPurple,
                                  fontWeight:
                                      FontWeight
                                          .bold),
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
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: _inputDecoration(label, hint, icon)
            .copyWith(counterText: ''),
        validator: validator,
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2),
      ),
    );
  }
}