import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {

      var data = doc.data() as Map<String, dynamic>;

      _namaController.text = data["nama"] ?? "";
      _emailController.text = data["email"] ?? "";
      _nikController.text = data["nik"] ?? "";
      _dobController.text = data["tanggal_lahir"] ?? "";
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [

            _buildProfileHeader(),

            Padding(
              padding: const EdgeInsets.all(24.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Informasi Pribadi',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(_namaController,'Nama Lengkap','Masukkan nama lengkap'),

                  _buildTextField(_emailController,'Alamat Email','email@contoh.com'),

                  _buildTextField(_nikController,'NIK','Nomor Induk Kependudukan'),

                  // Tanggal Lahir
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),

                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      suffixIcon: const Icon(Icons.calendar_today),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Dokumen Pendukung',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: const [

                        Icon(Icons.credit_card,
                            size: 40,
                            color: Colors.deepPurple),

                        SizedBox(height: 8),

                        Text(
                          'Upload e-KTP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Format JPG/PNG, max 2MB',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),

      decoration: const BoxDecoration(
        color: Color(0xFF1E1B3A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),

      child: Column(

        children: [

          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person,
                size: 50,
                color: Colors.white),
          ),

          const SizedBox(height: 16),

          Text(
            _namaController.text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            _emailController.text,
            style: const TextStyle(
                color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),

      child: TextFormField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,
          hintText: hint,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}