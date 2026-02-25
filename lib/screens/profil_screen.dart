import 'package:flutter/material.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // Controller untuk tanggal lahir agar bisa diisi lewat kalender
  final TextEditingController _dobController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1), // Default tahun
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Nama Lengkap', 'Masukkan nama lengkap'),
                  _buildTextField('Alamat Email', 'email@contoh.com', isEmail: true),
                  _buildTextField('Nomor Telepon', '+62 8...', isPhone: true),
                  _buildTextField('Tempat Lahir', 'Masukkan kota kelahiran'),
                  
                  // Field Tanggal Lahir dengan DatePicker
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Pilih tanggal lahir',
                      suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField('Alamat Rumah (Domisili)', 'Masukkan alamat lengkap'),
                  
                  // Dropdown Jenis Kelamin
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    items: ['Laki-laki', 'Perempuan'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Jenjang Pendidikan dengan nama instansi
                  _buildTextField('Jenjang Pendidikan & Instansi', 'Contoh: S1 Teknik Informatika - Universitas Brawijaya'),
                  _buildTextField('Keahlian / Skill', 'Contoh: Java, Desain Grafis'),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Dokumen Pendukung',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Upload e-KTP Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.shade200, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.credit_card, size: 40, color: Colors.deepPurple),
                        SizedBox(height: 8),
                        Text('Upload e-KTP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        SizedBox(height: 4),
                        Text('Format JPG/PNG, max 2MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Save Profile Action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Logout Action
                      },
                      child: const Text('Keluar Akun', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Header melengkung berwarna ungu gelap
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Lengkapi Profil Anda',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agar perusahaan mudah mengenali Anda',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat text field yang seragam
  Widget _buildTextField(String label, String hint, {bool isEmail = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}