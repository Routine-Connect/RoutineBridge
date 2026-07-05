import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routine_app/util/api_error_handler.dart';
import '../../provider/user_provider.dart';
import '../theme/app_colors.dart';
import 'main_screen.dart';
import '../../provider/auth_provider.dart';

class GenderOnboardingScreen extends StatefulWidget {
  const GenderOnboardingScreen({super.key});

  @override
  State<GenderOnboardingScreen> createState() => _GenderOnboardingScreenState();
}

class _GenderOnboardingScreenState extends State<GenderOnboardingScreen> {
  bool _showText = false;
  bool _showButtons = false;
  
  // 🚀 로딩 상태 추가 (통신 중일 때 버튼 비활성화)
  bool _isLoading = false; 

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() { _showText = true; });

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() { _showButtons = true; });
  }

  // 🚀 서버로 성별 PATCH 요청 보내는 핵심 함수
  Future<void> _submitGender() async {
    if (_selectedGender == null) return;

    setState(() { _isLoading = true; });

    await ApiErrorHandler.execute(
      context,
      () async {
        // 1. 금고(SecureStorage) 또는 AuthProvider에 저장된 JWT 토큰을 가져옵니다.
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final String? token = authProvider.token; // 💡 AuthProvider에 token getter가 있다고 가정

        if (token == null) {
          throw Exception("인증 토큰이 없습니다. 다시 로그인해 주세요.");
        }

        // 2. 만들어 두신 PATCH API를 토큰과 선택한 성별('M' 또는 'F')을 실어서 호출합니다!
        // 💡 UserProvider 내부에서 인자를 받도록 보완되어 있어야 합니다.
        await context.read<UserProvider>().updateGender(token, _selectedGender!);
      },
      onSuccess: () {
        // 3. 백엔드 DB 업데이트가 완전히 성공하면 홈 화면으로 이동시킵니다.
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
    );

    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showText ? 1.0 : 0.0,
                curve: Curves.easeOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "환영합니다! 🎉",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "정확한 루틴 분석을 위해\n성별을 알려주세요.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showButtons ? 1.0 : 0.0,
                curve: Curves.easeOutBack,
                child: Row(
                  children: [
                    Expanded(child: _buildGenderCard('m', '남자', Icons.male_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildGenderCard('f', '여자', Icons.female_rounded)),
                  ],
                ),
              ),

              const Spacer(),

              // 🚀 3. 하단 '시작하기' 버튼 로직 수정
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _selectedGender != null ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: _selectedGender == null || _isLoading, // 로딩 중에도 터치 막기
                  child: ElevatedButton(
                    onPressed: _submitGender, // 👈 핵심 로직 연결!
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Doday 시작하기',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String value, String label, IconData icon) {
    bool isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () {
        if (_isLoading) return; // 로딩 중엔 선택 변경 금지
        setState(() {
          _selectedGender = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : AppColors.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 12)] 
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 48, 
              color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.outline,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}