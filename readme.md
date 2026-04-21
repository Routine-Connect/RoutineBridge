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
| Etc | Lombok, commons-fileupload, webp-imageio |

<br />

## 📁 프로젝트 구조

```
src/main/java/com/doday/dev/doday/
├── controller/
│   ├── UserController.java         # 유저 API
│   ├── RoutineController.java      # 루틴 API
│   ├── StatsController.java        # 통계 API
│   ├── CalendarController.java     # 캘린더 API
│   └── NotificationController.java # 알림 설정 API
├── service/
│   ├── UserService.java
│   ├── RoutineService.java
│   ├── StatsService.java
│   ├── CalendarService.java
│   └── NotificationService.java
├── mapper/
│   ├── UserMapper.java
│   ├── RoutineMapper.java
│   ├── RoutineLogMapper.java
│   └── NotificationSettingsMapper.java
├── domain/
│   ├── User.java
│   ├── Routine.java
│   ├── RoutineLog.java
│   └── NotificationSettings.java
├── dto/
│   ├── SignupRequestDto.java
│   ├── LoginRequestDto.java
│   ├── UpdateProfileRequestDto.java
│   └── NotificationSettingsDto.java
└── common/
    ├── ApiResponse.java
    ├── ErrorCode.java
    ├── GlobalExceptionHandler.java
    └── JwtAuthenticationFilter.java
```

<br />

## 🗄️ DB 스키마

```sql
CREATE TABLE Users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL DEFAULT 'm',
    profile_image VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Routines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(100) NOT NULL,
    days_of_week VARCHAR(20) NOT NULL,
    alarm_time TIME,
    is_active BOOLEAN DEFAULT TRUE,
    icon_id INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE RoutineLogs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    routine_id BIGINT NOT NULL,
    check_date DATE NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (routine_id) REFERENCES Routines(id)
);

CREATE TABLE NotificationSettings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    is_push_enabled BOOLEAN DEFAULT TRUE,
    is_routine_noti_enabled BOOLEAN DEFAULT TRUE,
    is_marketing_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);
```

<br />

## 📡 API 명세

### 👤 User API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| POST | /api/users/signup | 회원가입 | ❌ |
| POST | /api/users/login | 로그인 | ❌ |
| GET | /api/users/me | 프로필 조회 | ✅ |
| PUT | /api/users/me | 프로필 수정 (닉네임/비밀번호) | ✅ |
| POST | /api/users/me/image | 프로필 이미지 업로드 | ✅ |
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
| POST | /api/routines/{id}/check | 루틴 완료 토글 | ✅ |

### 📊 Stats API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/stats/monthly | 월간 달성률 통계 | ✅ |
| GET | /api/stats/weekly | 주간 달성률 통계 | ✅ |
| GET | /api/stats/streak | 스트릭 조회 | ✅ |

### 📆 Calendar API

| Method | URL | 설명 | 인증 |
|--------|-----|------|------|
| GET | /api/calendar/monthly | 월간 캘린더 루틴 목록 | ✅ |

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
| A001 | 토큰이 없음 |
| A002 | 유효하지 않은 토큰 |
| F001 | 허용되지 않는 파일 형식 |
| F002 | 파일 크기 초과 (5MB) |

<br />

## 🚀 로컬 실행 방법

```bash
# 1. 레포 클론
git clone https://github.com/{username}/doday.git

# 2. db.properties 설정
db.url=jdbc:mysql://localhost:3306/doday?serverTimezone=UTC&useSSL=false&characterEncoding=UTF-8&useUnicode=true&allowPublicKeyRetrieval=true
db.username=YOUR_USERNAME
db.password=YOUR_PASSWORD
jwt.secret=YOUR_JWT_SECRET
server.url=http://localhost:8080

# 3. Tomcat 9 서버 실행
```

<br />

## 🔗 관련 레포지토리

| 레포 | 설명 |
|------|------|
| [doday-landing](https://github.com/{username}/doday-landing) | React 랜딩페이지 |
| [doday-app](https://github.com/{username}/doday-app) | Flutter 앱 (협업 중) |

<br />

## 📌 주요 설계 결정

| 항목 | 결정 | 이유 |
|------|------|------|
| 루틴 삭제 | Hard Delete + CASCADE 제거 | 과거 통계 데이터 보존 |
| 통계 형식 | Boolean → Double (%) | 하루 n개 중 완료 개수 기반 정확한 달성률 |
| 이미지 저장 | 서버 로컬 + WebP 변환 | 용량 최적화 (30~50% 절감) |
| 알림 설정 | 별도 테이블 (1:1) | 확장성 (방해금지 시간 등 추가 용이) |
| JWT 방식 | Request Attribute | 세션 방식 아닌 무상태 인증 |

<br />

---

<div align="center">
  <sub>Built with ☕ | DoDay Backend Server</sub>
</div>