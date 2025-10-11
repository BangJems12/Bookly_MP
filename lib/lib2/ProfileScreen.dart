import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key });
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Bar navigasi dengan back
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              // Foto profil
              const CircleAvatar(
                backgroundImage: AssetImage("assets/images/a.png"),
                radius: 100,

              ),
              const SizedBox(height: 40),

              // Detail Profil
              InfoBox(
                title: "Detail Profil",
                children: const [
                  ProfileRow(icon: Icons.email, label: "Email", value: "user@example.com"),
                  Divider(),
                  ProfileRow(icon: Icons.phone, label: "No Telp", value: "08123456789"),
                                    
                ],
              ),
              const SizedBox(height: 24),

              // Pengaturan
              InfoBox(
                title: "Pengaturan",
                children: [
                  SettingRow(icon: Icons.notifications, label: "Atur Notifikasi", onTap: () {}),
                  const Divider(),
                  SettingRow(icon: Icons.chevron_right, label: "Ubah Kata Sandi", onTap: () {}),
                  const Divider(),
                  SettingRow(
                    icon: Icons.exit_to_app,
                    label: "Keluar",
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                    },
                    color: Colors.red,
                  ),
                ],
              ),
              const Spacer(),

              // Tombol Edit Akun
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Edit Akun",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoBox({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value),
      ],
    );
  }
}

class SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const SettingRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Colors.black;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? Colors.grey),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
