# 🌉 Routine Bridge — Backend

> **"작은 습관이 내일의 나를 만든다"**
> 루틴 관리 앱의 백엔드 서버 레포지토리입니다.

---

## 📌 프로젝트 소개

**루틴 브릿지(Routine Bridge)** 는 매일의 작은 습관을 기록하고 시각화하는 개인화 루틴 관리 서비스입니다.

작심삼일에 그치는 대학생, 취준생을 위해 루틴 설정 → 데일리 체크 → 성취도 리포트까지
하나의 앱에서 경험할 수 있도록 설계했습니다.

> 🤝 **협업 구조**: 백엔드(본 레포) + Flutter 앱(별도 레포) 으로 구성된 팀 프로젝트입니다.

---

## 👨‍💻 담당 역할

| 구분 | 내용 |
|------|------|
| 담당자 | 백엔드 개발자 |
| 역할 | REST API 설계 및 구현, DB 설계, 서버 배포 |
| 협업 방식 | Swagger로 API 명세 공유, ngrok → AWS EC2 순차 배포 |

---

## 🛠️ 기술 스택

### Backend
| 기술 | 버전 | 용도 |
|------|------|------|
| Java | 17 | 메인 언어 |
| Spring MVC | 5.3.31 | 웹 프레임워크 (레거시) |
| MyBatis | 3.5.13 | ORM (SQL Mapper) |
| Spring Security | 5.x | 인증/인가 |
| JWT | - | 토큰 기반 인증 |

### Database
| 기술 | 버전 | 용도 |
|------|------|------|
| MySQL | 8.x | 메인 DB |
| commons-dbcp2 | 2.9.0 | 커넥션 풀 |

### DevOps & Tools
| 기술 | 용도 |
|------|------|
| Apache Tomcat 9 | WAS |
| Maven | 빌드 도구 |
| ngrok | 로컬 터널링 (개발 단계) |
| AWS EC2 | 서버 배포 (예정) |
| Docker | 컨테이너화 (예정) |
| Swagger (springfox 2.9.2) | API 문서화 |
| Git / GitHub | 버전 관리 |
| IntelliJ IDEA | IDE |

---

## 🗄️ DB 스키마

```sql
-- 1. 사용자 테이블
CREATE TABLE `Users` (
                         `id`         BIGINT       NOT NULL AUTO_INCREMENT,
                         `email`      VARCHAR(100) NOT NULL,
                         `password`   VARCHAR(255) NOT NULL,
                         `nickname`   VARCHAR(50)  NOT NULL,
                         `gender`     CHAR(1)      NOT NULL DEFAULT 'm', -- 'm' or 'w'
                         `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         PRIMARY KEY (`id`),
                         UNIQUE KEY `uk_email` (`email`)
);

-- 2. 루틴 설정 테이블
CREATE TABLE `Routines` (
                            `id`           BIGINT       NOT NULL AUTO_INCREMENT,
                            `user_id`      BIGINT       NOT NULL,
                            `title`        VARCHAR(100) NOT NULL,
                            `days_of_week` VARCHAR(20)  NOT NULL,  -- 예: "MON,TUE,WED"
                            `alarm_time`   TIME,
                            `is_active`    BOOLEAN      NOT NULL DEFAULT TRUE,
                            `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            PRIMARY KEY (`id`),
                            CONSTRAINT `fk_routines_user_id`
                                FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE
);

-- 3. 루틴 수행 기록 테이블
CREATE TABLE `RoutineLogs` (
                               `id`           BIGINT  NOT NULL AUTO_INCREMENT,
                               `routine_id`   BIGINT  NOT NULL,
                               `check_date`   DATE    NOT NULL,
                               `is_completed` BOOLEAN NOT NULL DEFAULT FALSE,
                               PRIMARY KEY (`id`),
                               CONSTRAINT `fk_routinelogs_routine_id`
                                   FOREIGN KEY (`routine_id`) REFERENCES `Routines` (`id`) ON DELETE CASCADE
);
```

---

## 📁 프로젝트 구조

```
src/
└── main/
    ├── java/com/routinebridge/dev/routinebridge/
    │   ├── config/          # SwaggerConfig 등 설정 클래스
    │   ├── controller/      # REST API 컨트롤러
    │   ├── service/         # 비즈니스 로직
    │   ├── mapper/          # MyBatis Mapper 인터페이스
    │   └── domain/          # VO (User, Routine, RoutineLog)
    └── resources/
        ├── mappers/         # MyBatis Mapper XML (SQL)
        └── db.properties    # DB 접속 정보 (gitignore 처리)
```

---

## 🔌 API 명세

> Swagger UI: `http://localhost:8080/swagger-ui.html`

| 메서드 | 엔드포인트 | 설명 |
|--------|-----------|------|
| POST | `/api/users/signup` | 회원가입 |
| POST | `/api/users/login` | 로그인 (JWT 반환) |
| PUT | `/api/users/me` | 프로필 수정 |
| POST | `/api/routines` | 루틴 생성 |
| GET | `/api/routines` | 루틴 목록 조회 |
| PUT | `/api/routines/{id}` | 루틴 수정 |
| DELETE | `/api/routines/{id}` | 루틴 삭제 |
| GET | `/api/routines/today` | 오늘의 루틴 조회 |
| POST | `/api/routines/{id}/check` | 루틴 완료 체크 |
| GET | `/api/stats/monthly` | 월간 통계 |
| GET | `/api/stats/weekly` | 주간 통계 |

---

## 📅 개발 로드맵

```
✅ 1주차  환경 세팅, DB 연결, ngrok, Swagger 구성
🔄 2주차  회원가입 / 로그인 / JWT 인증
⬜ 3주차  루틴 CRUD
⬜ 4주차  데일리 체크리스트
⬜ 5주차  성취도 리포트 (잔디 + 스트릭)
⬜ 6주차  예외처리 고도화 / 프로필 수정
⬜ 7주차  Docker + AWS EC2 배포
⬜ 8주차  마무리 / 포트폴리오 정리
```

---

## ⚙️ 로컬 실행 방법

### 1. 레포 클론
```bash
git clone https://github.com/{username}/routinebridge.git
cd routinebridge
git checkout backend
```

### 2. DB 설정
`src/main/resources/db.properties` 파일 생성 후 아래 내용 입력:
```properties
db.url=jdbc:mysql://localhost:3306/routinebridge?serverTimezone=UTC&useSSL=false
db.username=your_username
db.password=your_password
```

### 3. MySQL 테이블 생성
위 DB 스키마 SQL 실행

### 4. Tomcat 실행
IntelliJ에서 Smart Tomcat 플러그인으로 실행

### 5. Swagger 접속
```
http://localhost:8080/swagger-ui.html
```

---

## 🔐 보안 주의사항

- `db.properties` 는 `.gitignore` 에 등록되어 있으며 **절대 커밋하지 않습니다**
- JWT Secret Key는 환경변수로 관리합니다

---

## 📬 협업 관련

- API 명세는 Swagger로 공유
- 브랜치 전략: `main` ← `backend` / `frontend` 분리 운영
- 커밋 컨벤션:

```
feat:     새 기능 추가
fix:      버그 수정
refactor: 코드 리팩토링
docs:     문서 수정
chore:    빌드/설정 변경
```

---

<div align="center">
  <sub>Built with ☕ and 💪 | Routine Bridge Backend</sub>
</div>