# 🐾 DoDay — 백엔드 서버

> **"작은 습관이 내일의 나를 만든다"**
> 루틴 관리 앱 DoDay의 Spring MVC 기반 백엔드 REST API 서버입니다.

<br />

## 🛠️ 기술 스택

| 분류 | 기술 |
|------|------|
| Language | Java 17 |
| Framework | Spring MVC 5.3.31 |
| ORM | MyBatis 1.3.3 |
| Database | MySQL 8.x |
| Auth | JWT (jjwt 0.11.5) |
| Security | Spring Security 5.8.13 |
| Server | Apache Tomcat 9 |
| Build | Maven |
| Docs | Springfox Swagger 2.9.2 |
| Etc | Lombok, commons-fileupload, webp-imageio, logback |

<br />

## 📡 API 명세

### 👤 User API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| POST | /api/users/signup | 회원가입 | ❌ |
| POST | /api/users/login | 로그인 | ❌ |
| GET | /api/users/me | 프로필 조회 | ✅ |
| PUT | /api/users/me | 프로필 수정 (닉네임/비밀번호) | ✅ |
| POST | /api/users/me/image | 프로필 이미지 업로드 (WebP 변환) | ✅ |
| GET | /api/users/me/notifications | 알림 설정 조회 | ✅ |
| PUT | /api/users/me/notifications | 알림 설정 변경 | ✅ |

### 📅 Routine API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/routines | 루틴 목록 조회 (sort_order 정렬) | ✅ |
| GET | /api/routines/{id} | 루틴 단건 조회 | ✅ |
| POST | /api/routines | 루틴 생성 (sort_order 자동 부여) | ✅ |
| PUT | /api/routines/{id} | 루틴 수정 | ✅ |
| DELETE | /api/routines/{id} | 루틴 삭제 | ✅ |
| GET | /api/routines/today | 오늘의 루틴 조회 | ✅ |
| GET | /api/routines/daily?date= | 특정 날짜 루틴 조회 | ✅ |
| GET | /api/routines/monthly-daily?year=&month= | 한달치 날짜별 루틴 조회 | ✅ |
| POST | /api/routines/{id}/check?date= | 루틴 완료 토글 | ✅ |
| PUT | /api/routines/order | 루틴 순서 변경 | ✅ |

### 📊 Stats API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/stats/monthly?year=&month= | 월간 달성률 통계 | ✅ |
| GET | /api/stats/weekly | 주간 달성률 통계 | ✅ |
| GET | /api/stats/streak | 이번달 기준 스트릭 조회 | ✅ |
| GET | /api/stats/streak/all | 전체 기간 기준 스트릭 조회 | ✅ |

### 📆 Calendar API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/calendar/monthly?year=&month= | 월간 캘린더 루틴 목록 | ✅ |

### 🔔 Notification API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/users/me/notifications | 알림 설정 조회 | ✅ |
| PUT | /api/users/me/notifications | 알림 설정 변경 | ✅ |

<br />

## 🔐 공통 응답 포맷

```json
{
    "success": true,
    "data": {},
    "error": null
}
```

### 에러 코드

| 코드 | 설명 |
|------|------|
| U001 | 이미 사용 중인 이메일 |
| U002 | 유저를 찾을 수 없음 |
| U003 | 비밀번호 불일치 |
| R001 | 루틴을 찾을 수 없음 |
| R002 | 루틴 접근 권한 없음 |
| R003 | 비활성화된 루틴 |
| A001 | 토큰이 없음 |
| A002 | 유효하지 않은 토큰 |
| C002 | 서버 오류 |
| C003 | 잘못된 입력값 |
| F001 | 허용되지 않는 파일 형식 |
| F002 | 파일 크기 초과 (5MB) |

<br />

## 🔗 관련 레포지토리

| 레포 | 설명 |
|------|------|
| [doday-landing](https://github.com/{username}/doday-landing) | React 랜딩페이지 |
| [doday-app](https://github.com/{username}/doday-app) | Flutter 앱 (협업 중) |

<br />

---

<div align="center">
  <sub>Built with ☕ | DoDay Backend Server</sub>
</div>