# Doday - Frontend

사용자의 일상적인 루틴을 관리하고 성취도를 시각화하는 루틴 관리 앱의 프론트엔드 리포지토리입니다.

## 🛠 Tech Stack
- **Framework:** Flutter (SDK 3.41.5)
- **State Management:** Provider
- **Local Storage:** flutter_secure_storage (JWT 토큰 보관)
- **Network:** `http

## 📁 Directory Structure
아키텍처에 따라 기능 및 목적별로 디렉토리를 분리하여 관리합니다.

```text
lib/
┣ 📂 provider/        # 전역 상태 관리 (AuthProvider 등)
┣ 📂 screen/          # UI 화면 컴포넌트
┃ ┣ 📄 main_screen.dart      # 바텀 네비게이션 및 탭 관리
┃ ┣ 📄 home_screen.dart      # 루틴 목록 및 주간 달력
┃ ┣ 📄 routine_screen.dart   # 성취도 및 통계 리포트
┃ ┣ 📄 mypage_screen.dart    # 설정 및 프로필
┃ ┗ 📄 profile_edit_screen.dart
┣ 📂 theme/            # 공통 디자인 시스템
┃ ┗ 📄 app_colors.dart        # 메인 컬러(Quokka Brown, Sage Green 등) 및 테마
┣ 📂 utils/            # 헬퍼 함수 (아이콘 매핑, 날짜 포맷 변환 등)
┗ 📄 main.dart         # 앱 엔트리 포인트 및 Provider 주입
```
 
 
성능 개선을 위해 앱 내에 이미지는 .webp 형식을 사용합니다.