import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
//import 'profile_edit_screen.dart'; // 곧 만들 파일

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        const SizedBox(height: 20),
        // 👤 프로필 영역 (연필 아이콘 포함)
        Center(
          child: Stack(
            children: [
              const CircleAvatar(radius: 45, backgroundColor: AppColors.border, child: Icon(Icons.person, size: 45, color: Colors.white)),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  //onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileEditScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text("루틴왕 쿼카", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 40),

        // 🛠 설정 리스트
        _buildSectionTitle("설정"),
        SwitchListTile(
          title: const Text("알림 설정"),
          value: _isNotificationOn,
          activeColor: AppColors.accent,
          onChanged: (v) => setState(() => _isNotificationOn = v),
        ),
        _buildMenuTile("테마 설정", Icons.palette_outlined, trailText: "라이트 모드"),
        const SizedBox(height: 20),
        
        _buildSectionTitle("지원"),
        _buildMenuTile("고객센터", Icons.help_outline),
        _buildMenuTile("앱 정보", Icons.info_outline),
        const SizedBox(height: 20),

        TextButton(
          onPressed: () => print("로그아웃 실행"),
          child: const Text("로그아웃", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 8),
    child: Text(title, style: const TextStyle(color: AppColors.textSub, fontSize: 12, fontWeight: FontWeight.bold)),
  );

  Widget _buildMenuTile(String title, IconData icon, {String? trailText}) => ListTile(
    leading: Icon(icon, color: AppColors.textMain),
    title: Text(title),
    trailing: trailText != null ? Text(trailText, style: const TextStyle(color: AppColors.textSub)) : const Icon(Icons.chevron_right),
  );
}