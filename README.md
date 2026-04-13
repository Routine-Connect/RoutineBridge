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
┣ 📂 provider/             # [ViewModel] 전역 상태 관리 및 화면 갱신
┃ ┗ 📄 auth_provider.dart         # 로그인/로그아웃 상태 관리 및 SecureStorage 토큰 관리 
┃
┣ 📂 screen/               # [View] UI 화면 컴포넌트
┃ ┣ 📄 main_screen.dart           # 뼈대 (통합된 바텀 네비게이션 및 공통 상단바)
┃ ┣ 📄 login_screen.dart          # 로그인 화면
┃ ┣ 📄 home_screen.dart           # [탭 1] 오늘의 루틴 목록 및 주간 달력
┃ ┣ 📄 statistics_screen.dart     # [탭 2] (구 routine_screen) 성취도 및 월간 통계 리포트
┃ ┣ 📄 mypage_screen.dart         # [탭 3] 프로필 및 설정 (로그아웃 연동)
┃ ┗ 📄 profile_edit_screen.dart   # 프로필 수정 화면
┃
┣ 📂 service/              # [Model] 백엔드 API 통신 전담
┃ ┣ 📄 auth_service.dart          # Auth 도메인 (로그인 통신 및 토큰 발급)
┃ ┣ 📄 routine_service.dart       # Routine 도메인 (루틴 조회, 추가, 완료 처리 통신)
┃ ┣ 📄 statistics_service.dart    # Statistics 도메인 (월간 달성률, 스트릭 조회 통신)
┃ ┗ 📄 user_service.dart          # User 도메인 (유저 프로필 조회 및 수정 통신)
┃
┣ 📂 theme/                # 공통 디자인 시스템
┃ ┗ 📄 app_style.dart             # 컬러 팔레트 및 전역 그림자(plushShadow) 통합 관리
┃
┗ 📄 main.dart             # 앱 엔트리 포인트 (시작 화면 설정 및 Provider 전역 주입)

assets/
┗ 📂 images/               # WebP 등으로 최적화된 앱 내부 에셋 이미지
  ┣ 📄 bg_login.webp              # 로그인 배경 
  ┣ 📄 quokka_manager.webp        # 탐정/매니저 쿼카 (통계 화면)
  ┣ 📄 quokka_cheerleader.webp    # 응원하는 쿼카 (홈 화면)
  ┗ 📄 (아이콘 이미지들)
```
 
 
프론트엔드 에셋 최적화(WebP 인코딩 및 해상도 최적화)를 주도하여 전체 이미지 리소스 용량을 평균 98% 이상 절감