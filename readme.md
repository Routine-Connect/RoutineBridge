

<img src="https://github.com/user-attachments/assets/252a4860-f339-4ef9-a0c8-cb1562a0dc22" width="120" height="120" style="border-radius: 20px"/>

# DoDay 두데이

**"작은 습관이 내일의 나를 만든다"**

매일의 루틴을 기록하고, 성장하는 나를 확인하는 습관 관리 앱

<br/>

![Java](https://img.shields.io/badge/Java_17-007396?style=flat-square&logo=OpenJDK&logoColor=white)
![Spring](https://img.shields.io/badge/Spring_MVC-6DB33F?style=flat-square&logo=Spring&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL_8.x-4479A1?style=flat-square&logo=MySQL&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-000000?style=flat-square&logo=JSON%20Web%20Tokens&logoColor=white)
![Swagger](https://img.shields.io/badge/Swagger-85EA2D?style=flat-square&logo=Swagger&logoColor=black)

</div>

---

## 📌 배포 주소

| 서비스 | 주소 |
|--------|------|
| 백엔드 API | 배포 예정 |
| 랜딩페이지 | 배포 예정 |
| 공유페이지 | 배포 예정 |
| Swagger | 배포 예정 |

---

## 👨‍💻 팀 소개

## 🙆🏼‍♂️ Doday Team
### Developers
|Banckend Dev & Front Dev|App Dev & Front Dev|
|:---:|:---:|
|<img src="https://avatars.githubusercontent.com/u/94667528?v=4" width="100">|<img src="https://avatars.githubusercontent.com/u/83564922?v=4" width="100">|
|[문광희](https://github.com/MoonGwangHee)|[조민국](https://github.com/adward27)
|Project Reader|App Developer|

---

## 📱 프로젝트 소개

**DoDay(두데이)** 는 루틴 관리 앱으로, 매일의 작은 습관을 기록하고 시각화하는 서비스입니다.

- 📅 **루틴 설정** — 요일별 알림으로 나만의 루틴 관리
- ✅ **데일리 체크** — 오늘 할 루틴을 한눈에 확인하고 완료
- 📊 **성취도 리포트** — 월간 달성률, 스트릭으로 성장 확인
- 🔥 **스트릭 시스템** — 연속 달성일로 동기부여
- 🐾 **기록 공유** — 나의 루틴 기록을 카카오톡 등으로 공유

---

## 🛠️ 기술 스택

### Backend
| 분류 | 기술 |
|------|------|
| Language | Java 17 |
| Framework | Spring MVC 5.3.31 |
| ORM | MyBatis 1.3.3 |
| Database | MySQL 8.x |
| Auth | JWT (jjwt 0.11.5) · Kakao OAuth2.0 |
| Security | Spring Security 5.8.13 · Caffeine Cache |
| Server | Apache Tomcat 9 |
| Build | Maven |
| Docs | Springfox Swagger 2.9.2 |
| Image | WebP 변환 (webp-imageio) · Magic Byte 검증 |
| Etc | Lombok · commons-fileupload · logback |

### Infra (예정)
| 분류 | 기술 |
|------|------|
| Server | AWS EC2 |
| Static | AWS S3 + CloudFront |
| Container | Docker · docker-compose |
| Domain | doday-quokka.co.kr |

### Frontend / App
| 분류 | 기술 |
|------|------|
| App | Flutter (iOS / Android) |
| Landing | React 18 · Framer Motion |
| Share | React 18 · Framer Motion |

---

## 🖥️ 화면 구성

| 홈 화면 | 통계 화면 | 공유 페이지 |
|---------|---------|-----------|
| 오늘의 루틴 목록 | 월간/주간 달성률 | 스트릭 공유 카드 |

---

## 📡 API 명세

### 👤 User API
| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| POST | /api/users/signup | 회원가입 | ❌ |
| POST | /api/users/login | 로그인 | ❌ |
| GET | /api/users/me | 프로필 조회 | ✅ |
| PUT | /api/users/me | 프로필 수정 | ✅ |
| POST | /api/users/me/image | 프로필 이미지 업로드 | ✅ |
| PATCH | /api/users/me/gender | 성별 설정 | ✅ |
| GET | /api/users/me/notifications | 알림 설정 조회 | ✅ |
| PUT | /api/users/me/notifications | 알림 설정 변경 | ✅ |

### 📅 Routine API
| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/routines | 루틴 목록 조회 | ✅ |
| GET | /api/routines/{id} | 루틴 단건 조회 | ✅ |
| POST | /api/routines | 루틴 생성 | ✅ |
| PUT | /api/routines/{id} | 루틴 수정 | ✅ |
| DELETE | /api/routines/{id} | 루틴 삭제 | ✅ |
| GET | /api/routines/today | 오늘의 루틴 조회 | ✅ |
| GET | /api/routines/daily?date= | 특정 날짜 루틴 조회 | ✅ |
| GET | /api/routines/monthly-daily?year=&month= | 한달치 루틴 조회 | ✅ |
| POST | /api/routines/{id}/check?date= | 루틴 완료 토글 | ✅ |
| PUT | /api/routines/order | 루틴 순서 변경 | ✅ |
| PATCH | /api/routines/{id}/alarm | 루틴 알람 토글 | ✅ |

### 📊 Stats API
| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/stats/monthly?year=&month= | 월간 달성률 통계 | ✅ |
| GET | /api/stats/weekly | 주간 달성률 통계 | ✅ |
| GET | /api/stats/streak | 이번달 스트릭 조회 | ✅ |
| GET | /api/stats/streak/all | 전체 기간 스트릭 조회 | ✅ |
| GET | /api/stats/share/token | 공유 토큰 발급 | ✅ |

### 📆 Calendar API
| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/calendar/monthly?year=&month= | 월간 캘린더 루틴 목록 | ✅ |

### 🔗 Share API
| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/share/{token} | 공유 데이터 조회 | ❌ |

### 🔐 Auth API
| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| POST | /api/auth/kakao | 카카오 소셜 로그인 | ❌ |

---

## ✨ 주요 기능

### 루틴 관리
- 요일별 루틴 설정 및 알람 시간 지정
- 루틴 아이콘 설정 (Flutter 내장 이모지)
- 드래그로 루틴 순서 변경
- 루틴 개별 알람 ON/OFF

### 통계 & 스트릭
- 월간/주간 달성률 (%) 계산
- 현재 스트릭 / 최장 스트릭 / 총 완료 루틴
- 이번달 기준 스트릭 · 전체 기간 기준 스트릭 분리

### 보안
- JWT 기반 무상태 인증
- BCrypt 비밀번호 암호화
- 로그인 5회 실패 시 10분 잠금 (Caffeine Cache)
- 파일 업로드 Magic Byte 검증
- 루틴 체크 날짜 검증 (생성일 이전 / 과거 날짜 방지)

### 소셜 로그인
- 카카오 OAuth2.0 로그인
- 기존 이메일 계정 자동 연동
- 신규 유저 자동 회원가입

### 기록 공유
- 나의 스트릭 기록 공유 URL 생성
- 토큰 기반 공유 (재발급 시 기존 링크 무효화)
- 인증 없이 공유 페이지 접근 가능

---

## 🏗️ 시스템 아키텍처

![System Architecture](https://github.com/user-attachments/assets/ad2dc319-da12-429a-b073-32bffd5fc73e)


---

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
| U004 | 로그인 5회 실패로 계정 잠금 |
| R001 | 루틴을 찾을 수 없음 |
| R002 | 루틴 접근 권한 없음 |
| R003 | 비활성화된 루틴 |
| A001 | 토큰이 없음 |
| A002 | 유효하지 않은 토큰 |
| C002 | 서버 오류 |
| C003 | 잘못된 입력값 |
| F001 | 허용되지 않는 파일 형식 |
| F002 | 파일 크기 초과 (5MB) |

---

## 🔗 관련 레포지토리

| 레포 | 설명 |
|------|------|
| [doday-app](https://github.com/Routine-Connect/doday/tree/frontend) | Flutter 앱 (협업 중) |
| [doday-landing](https://github.com/Routine-Connect/doday_web) | React 랜딩페이지 |
| [doday-share](https://github.com/Routine-Connect/doday-share) | React 공유페이지 |

---

<div align="center">
  <sub>Built with ☕ and 🐾 | DoDay Backend Server</sub>
</div>
