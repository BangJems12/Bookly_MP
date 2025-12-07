import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lupakatasandi.dart'; // ✅ pastikan file ini ada

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    var current = Supabase.instance.client.auth.currentUser;

    if (current == null) {
      final response = await Supabase.instance.client.auth.getUser();
      current = response.user;
    }

    setState(() {
      user = current;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // contoh ambil avatar dari Supabase metadata
    final avatarUrl = user?.userMetadata?['https://avatar.iran.liara.run/public/13'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya",  style: TextStyle( color: Colors.white,),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Foto profil dengan border
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl) // ✅ dari Supabase Storage
                            : const AssetImage("assets/images/a.png")
                                as ImageProvider, // fallback ke assets
                      ),
                    ),
                    const SizedBox(height: 30),

                    // InfoBox gabungan
                    InfoBox(
                      title: "Profil & Pengaturan",
                      children: [
                        const Text(
                          "Detail Profil",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        ProfileRow(
                          icon: Icons.person,
                          label: "Nama",
                          value: user?.userMetadata?['username'] ??
                              "Tidak ada nama",
                        ),
                        const Divider(),
                        ProfileRow(
                          icon: Icons.email,
                          label: "Email",
                          value: user?.email ?? "Tidak ada email",
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Pengaturan",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        SettingRow(
                          icon: Icons.notifications,
                          label: "Atur Notifikasi",
                          onTap: () {},
                        ),
                        const Divider(),
                        SettingRow(
                          icon: Icons.lock,
                          label: "Ubah Kata Sandi",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LupaPasswordScreen(), // ✅ diarahkan ke file lupakatasandi.dart
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        SettingRow(
                          icon: Icons.exit_to_app,
                          label: "Keluar",
                          onTap: () async {
                            await Supabase.instance.client.auth.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/login", (route) => false);
                          },
                          color: Colors.red,
                        ),
                      ],
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
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green, size: 22),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
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
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.green.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? Colors.green, size: 22),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}