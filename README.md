# 🗓 Doday - Frontend

사용자의 일상적인 루틴을 관리하고 성취도를 시각화하는 루틴 관리 앱 'Doday'의 프론트엔드 리포지토리입니다.

## 🛠 Tech Stack
- **Framework:** Flutter (SDK 3.x)
- **State Management:** Provider
- **Network:** `http`
- **Local Storage:** `flutter_secure_storage` (JWT 토큰 보관)

---

## 🚀 Performance & Optimization
Doday 프론트엔드는 사용자 경험(UX)과 앱 성능 향상을 위해 아래와 같은 최적화를 적용했습니다.

- **에셋(Asset) 최적화 및 용량 절감:** 앱 내 모든 무거운 이미지 리소스를 `.webp` 형식으로 인코딩 및 해상도 최적화를 진행하여, **전체 이미지 리소스 용량을 평균 98% 이상 절감**했습니다.
- **낙관적 업데이트 (Optimistic UI):** 루틴 완료 체크 시, 서버의 응답을 기다리지 않고 로컬 상태(캐시)를 즉시 변경해 화면에 렌더링하는 낙관적 업데이트를 적용했습니다. 이를 통해 네트워크 지연 없는 압도적인 조작감을 제공하며, 통신 실패 시에만 조용히 롤백(Rollback)하도록 예외 처리를 완벽하게 구현했습니다.
- **데이터 프리페칭 (Data Pre-fetching) 및 캐싱:** 통계 및 달력 화면 진입 시, 현재 월을 기준으로 이전/다음 달을 포함한 총 3개월 치의 데이터를 `Future.wait`을 통해 병렬로 미리 캐싱(Pre-fetch)합니다. 유저가 달력을 스와이프할 때 발생하는 로딩 버퍼링을 없앴습니다.

---

## 📁 Directory Structure
클린 아키텍처 원칙을 지향하며, 유지보수와 확장성을 고려해 기능과 계층별로 디렉토리를 분리했습니다.

```text
lib/
┣ 📄 main.dart                  # 앱 엔트리 포인트 및 Provider 전역 주입
┃
┣ 📂 model/                     # 데이터 모델 (JSON 직렬화/역직렬화)
┃ ┣ 📄 NotificationSettings.dart, Routine.dart, User.dart
┃
┣ 📂 provider/                  # [ViewModel] 상태 관리 및 비즈니스 로직 통제
┃ ┣ 📄 auth_provider.dart       # 로그인/로그아웃 및 소셜 인증 상태 관리
┃ ┣ 📄 routine_provider.dart    # 루틴 조회, 체크, 캐싱 상태 관리
┃ ┣ 📄 statistics_provider.dart # 통계 및 스트릭 데이터 상태 관리
┃ ┣ 📄 theme_provider.dart      # 앱 전역 테마 상태 관리
┃ ┗ 📄 user_provider.dart       # 유저 프로필 정보 상태 관리
┃
┣ 📂 service/                   # [Model] 백엔드 API 통신 전담 (네트워크 계층)
┃ ┣ 📄 auth_service.dart, notification_service.dart
┃ ┗ 📄 routine_service.dart, statistics_service.dart, user_service.dart
┃
┣ 📂 ui/                        # [View] 화면 및 UI 컴포넌트
┃ ┣ 📂 screen/                  # 독립된 페이지 단위 위젯
┃ ┃ ┣ 📄 splash_screen.dart, main_screen.dart, home_screen.dart
┃ ┃ ┗ 📄 login_screen.dart, signup_screen.dart, gender_onboarding_screen.dart
┃ ┃ ┗ 📄 statistics_screen.dart, mypage_screen.dart
┃ ┃
┃ ┣ 📂 theme/                   # 디자인 시스템 및 공통 스타일 요소
┃ ┃ ┗ 📄 app_colors.dart, app_icon.dart, app_shadow.dart
┃ ┃
┃ ┗ 📂 widget/                  # 재사용 가능한 공통 UI 부품
┃   ┗ 📄 app_modal.dart, custom_snackbar.dart, routine_card.dart
┃
┗ 📂 util/                      # 공통 유틸리티
  ┗ 📄 api_error_handler.dart   # 전역 API 에러 처리기


## 📱 앱 주요 화면

| | | | |
| :---: | :---: | :---: | :---: |
| <img width="200" src="https://github.com/user-attachments/assets/1806a6f3-15ce-4c49-bcf6-ffa478bf8118" /> | <img width="200" src="https://github.com/user-attachments/assets/5d7c2490-0d65-4274-be87-91426ec03487" /> | <img width="200" src="https://github.com/user-attachments/assets/e9baaa6d-c6d1-4607-b430-c884de1b71b0" /> | <img width="200" src="https://github.com/user-attachments/assets/ab473e85-7b44-424d-b94f-1c7939ad5844" /> |
| **스플래시 화면** | **로그인 화면** | **홈 화면 1** | **홈 화면 2** |
| <img width="200" src="https://github.com/user-attachments/assets/c53303b2-5ea9-4c2f-904e-23c250a660da" /> | <img width="200" src="https://github.com/user-attachments/assets/e03828c0-ecb0-4fb3-872d-ebbcbe4265d0" /> | <img width="200" src="https://github.com/user-attachments/assets/03993607-503d-42ce-bbdd-c32f7a911c93" /> | <img width="200" src="https://github.com/user-attachments/assets/891076dc-fd23-43a5-a652-f4fb59cd2651" /> |
| **통계 화면 1** | **통계 화면 2** | **마이페이지 1** | **마이페이지 2** |

## 🎥 앱 실행 데모

| |
| :---: |
| <img width="400" src="https://github.com/user-attachments/assets/88000c1e-167c-43a3-811c-083880b83800" /> |
| **앱 스플래시 영상** |