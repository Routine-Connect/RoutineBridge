import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomSnackBar {
  /// 🚀 1. 일반 알림 스낵바 (기존 유지)
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.error : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 🚀 2. 오늘 첫 루틴 달성 응원 팝업 (스낵바 한계를 넘은 Overlay 방식)
  static void showCheer(BuildContext context) {
    final cheerMessages = [
      '오늘 하루도 화이팅!',
      '쿼카가 당신을 응원해요!',
      '오늘도 갓생 성공!'
    ];
    final String randomMessage = (cheerMessages..shuffle()).first;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // 화면 맨 위에 직접 띄울 커스텀 위젯 생성
    overlayEntry = OverlayEntry(
      builder: (context) => _CheerPopup(
        message: randomMessage,
        onDismissed: () {
          overlayEntry.remove(); // 애니메이션이 끝나면 화면에서 완전히 삭제
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

// ============================================================================
// 👇 100% 통제 가능한 서서히 사라지는 커스텀 팝업 위젯
// ============================================================================
class _CheerPopup extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const _CheerPopup({required this.message, required this.onDismissed});

  @override
  State<_CheerPopup> createState() => _CheerPopupState();
}

class _CheerPopupState extends State<_CheerPopup> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    // 1. 나타날 때: 0.5초 동안 띠용! (크기가 커지며 선명해짐)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // 2. 머무는 시간: 1.5초간 화면에 예쁘게 떠 있음
    // 3. 사라질 때: 2초 동안 천천히 투명해지면서 살짝 작아짐 (스르륵 Fade-out)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
          _scale = 0.9; 
        });
      }
    });

    // 4. 완전 제거: 애니메이션이 다 끝나는 3.5초 뒤에 메모리에서 날려버림
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      bottom: bottomPadding + 40, // 탭바 위쪽으로 안전하게 띄움
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: _opacity,
        // 투명도 애니메이션: 나타날 땐 0.5초, 사라질 땐 2초!
        duration: _opacity == 1.0 ? const Duration(milliseconds: 500) : const Duration(seconds: 2),
        curve: _opacity == 1.0 ? Curves.elasticOut : Curves.easeOut,
        child: AnimatedScale(
          scale: _scale,
          // 크기 애니메이션: 나타날 땐 0.5초, 사라질 땐 2초!
          duration: _opacity == 1.0 ? const Duration(milliseconds: 500) : const Duration(seconds: 2),
          curve: _opacity == 1.0 ? Curves.elasticOut : Curves.easeOut,
          child: Material(
            color: Colors.transparent, // 기본 배경 투명하게
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/quokka_cheerleader.webp',
                    width: 56,
                    height: 56,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}