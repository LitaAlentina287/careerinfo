import 'package:flutter/material.dart';
import '../../services/auth_services.dart';
import '../wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final adminCodeController = TextEditingController();

  String selectedRole = 'member';
  bool isLoading = false;

  static const String ADMIN_SECRET_CODE =
      "ADMIN123"; // 🔐 ganti sesuai kebutuhan

  Future<void> register(BuildContext context) async {
    // 🔎 Validasi input
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email & password wajib diisi")),
      );
      return;
    }

    if (selectedRole == 'admin' &&
        adminCodeController.text != ADMIN_SECRET_CODE) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kode admin salah")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 📝 Register user
      await AuthService().register(
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole,
      );

      // 🔥 WAJIB: logout supaya tidak auto masuk dashboard
      await AuthService().logout();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil, silakan login")),
      );

      // 🔁 Reset navigation → Wrapper (akan tampil LoginScreen)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Wrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Register gagal: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    adminCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/register.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Overlay
          Container(color: Colors.black.withOpacity(0.35)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  color: Colors.white.withOpacity(0.75),
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 36,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Daftar Akun",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Silakan buat akun baru",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // EMAIL
                        _inputField(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 18),

                        // PASSWORD
                        _inputField(
                          controller: passwordController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),

                        const SizedBox(height: 22),

                        // ROLE
                        const Text(
                          "Daftar sebagai:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),

                        RadioListTile(
                          value: 'member',
                          groupValue: selectedRole,
                          onChanged: (v) => setState(() => selectedRole = v!),
                          title: const Text("Member"),
                        ),
                        RadioListTile(
                          value: 'admin',
                          groupValue: selectedRole,
                          onChanged: (v) => setState(() => selectedRole = v!),
                          title: const Text("Admin"),
                        ),

                        // ADMIN CODE
                        if (selectedRole == 'admin') ...[
                          const SizedBox(height: 12),
                          _inputField(
                            controller: adminCodeController,
                            label: "Kode Admin",
                            icon: Icons.security,
                          ),
                        ],

                        const SizedBox(height: 28),

                        // BUTTON
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => register(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "DAFTAR",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Sudah punya akun? Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
