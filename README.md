# Todo API 프로젝트

FastAPI 백엔드와 React 프론트엔드로 구성된 Todo 관리 애플리케이션입니다.

## 🚀 프로젝트 구조

```
vibe_coding/
├── backend/                    # FastAPI 백엔드
│   ├── venv/                   # Python 가상환경
│   ├── main.py                 # FastAPI 애플리케이션
│   ├── models.py               # Pydantic 모델 및 CRUD 함수
│   ├── requirements.txt        # Python 의존성
│   ├── test_api.ps1           # PowerShell API 테스트 스크립트
│   ├── test_api.sh            # Bash API 테스트 스크립트
│   ├── test_validation_errors.py # Validation Error 테스트
│   ├── VALIDATION_ERROR_GUIDE.md # Validation Error 가이드
│   ├── Todo_API_Collection.json # Postman 컬렉션
│   └── Todo_API_Environment.json # Postman 환경 변수
└── frontend/                   # React 프론트엔드
    ├── node_modules/           # Node.js 의존성
    ├── public/                 # 정적 파일
    ├── src/                    # 소스 코드
    │   ├── components/         # React 컴포넌트
    │   │   ├── TodoForm.tsx    # 할 일 입력 폼
    │   │   ├── TodoItem.tsx    # 할 일 아이템
    │   │   └── TodoList.tsx    # 할 일 목록
    │   ├── services/           # API 서비스
    │   │   └── TodoService.ts  # Todo API 클라이언트
    │   ├── types/              # TypeScript 타입 정의
    │   │   └── Todo.ts         # Todo 인터페이스
    │   ├── App.tsx             # 메인 앱 컴포넌트
    │   └── index.tsx           # 앱 진입점
    ├── package.json            # Node.js 의존성
    └── tsconfig.json           # TypeScript 설정
```

## 🛠️ 기술 스택

### 백엔드
- **FastAPI** - 현대적이고 빠른 웹 프레임워크
- **Pydantic** - 데이터 검증 및 직렬화
- **Uvicorn** - ASGI 서버
- **Python 3.8+** - 프로그래밍 언어

### 프론트엔드
- **React 18** - 사용자 인터페이스 라이브러리
- **TypeScript** - 타입 안전성
- **Axios** - HTTP 클라이언트
- **CSS3** - 스타일링

## 📋 기능

### 백엔드 API
- ✅ **CRUD 작업**: 할 일 생성, 조회, 수정, 삭제
- ✅ **데이터 검증**: Pydantic을 통한 자동 검증
- ✅ **에러 처리**: 상세한 에러 메시지
- ✅ **CORS 지원**: 프론트엔드와의 통신
- ✅ **테스트 엔드포인트**: 개발 및 테스트용

### 프론트엔드
- ✅ **할 일 관리**: 추가, 수정, 삭제, 완료 토글
- ✅ **실시간 업데이트**: 상태 변경 시 자동 새로고침
- ✅ **반응형 디자인**: 다양한 화면 크기 지원
- ✅ **타입 안전성**: TypeScript로 컴파일 타임 검증

## 🚀 설치 및 실행

### 1. 백엔드 설정

```bash
# 백엔드 디렉토리로 이동
cd backend

# Python 가상환경 생성 및 활성화
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# 의존성 설치
pip install -r requirements.txt

# FastAPI 서버 실행
uvicorn main:app --reload
```

서버가 `http://localhost:8000`에서 실행됩니다.

### 2. 프론트엔드 설정

```bash
# 새 터미널에서 프론트엔드 디렉토리로 이동
cd frontend

# 의존성 설치
npm install

# 개발 서버 실행
npm start
```

앱이 `http://localhost:3000`에서 실행됩니다.

## 🧪 테스트

### API 테스트

#### PowerShell (Windows)
```bash
cd backend
.\test_api.ps1
```

#### Bash (Linux/Mac)
```bash
cd backend
chmod +x test_api.sh
./test_api.sh
```

#### Validation Error 테스트
```bash
cd backend
python test_validation_errors.py
```

### Postman 테스트

1. **컬렉션 가져오기**: `Todo_API_Collection.json` 파일을 Postman에 가져오기
2. **환경 설정**: `Todo_API_Environment.json` 파일을 환경으로 가져오기
3. **테스트 실행**: 컬렉션의 모든 요청을 순차적으로 실행

### 브라우저 테스트

1. **Swagger UI**: `http://localhost:8000/docs`에서 API 문서 확인
2. **React 앱**: `http://localhost:3000`에서 사용자 인터페이스 테스트

## 📚 API 문서

### 기본 엔드포인트

| 메서드 | 엔드포인트 | 설명 |
|--------|------------|------|
| GET | `/` | API 상태 확인 |
| GET | `/todos` | 모든 할 일 조회 |
| POST | `/todos` | 새 할 일 생성 |
| GET | `/todos/{id}` | 특정 할 일 조회 |
| PUT | `/todos/{id}` | 할 일 수정 |
| PATCH | `/todos/{id}/toggle` | 완료 상태 토글 |
| DELETE | `/todos/{id}` | 할 일 삭제 |

### 테스트 엔드포인트

| 메서드 | 엔드포인트 | 설명 |
|--------|------------|------|
| POST | `/test/sample-data` | 샘플 데이터 5개 추가 |
| DELETE | `/test/clear-all` | 모든 데이터 삭제 |
| GET | `/test/status` | 현재 상태 확인 |

### 요청/응답 예시

#### 할 일 생성
```bash
POST /todos
Content-Type: application/json

{
  "title": "점심 먹기",
  "description": "맛있는 점심 먹기",
  "completed": false
}
```

#### 응답
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "title": "점심 먹기",
  "description": "맛있는 점심 먹기",
  "completed": false,
  "created_at": "2024-01-01T12:00:00",
  "updated_at": "2024-01-01T12:00:00"
}
```

## 🔧 개발 환경

### 요구사항
- **Python**: 3.8 이상
- **Node.js**: 16 이상
- **npm**: 8 이상

### 권장 개발 도구
- **VS Code** - 코드 편집기
- **Postman** - API 테스트
- **Git** - 버전 관리

## 📖 추가 문서

### Validation Error 가이드
- `backend/VALIDATION_ERROR_GUIDE.md` - FastAPI 검증 에러 상세 가이드
- Pydantic 검증 작동 원리
- 422 에러 발생 시점 및 처리 방법
- 실제 테스트 예시

### API 테스트 가이드
- `backend/test_api.ps1` - PowerShell 자동화 테스트
- `backend/test_api.sh` - Bash 자동화 테스트
- Postman 컬렉션 및 환경 설정

## 🐛 문제 해결

### 일반적인 문제

#### 백엔드 서버 연결 실패
```bash
# 포트 확인
netstat -an | findstr :8000  # Windows
lsof -i :8000               # Linux/Mac

# 서버 재시작
uvicorn main:app --reload --port 8000
```

#### 프론트엔드 빌드 오류
```bash
# 의존성 재설치
rm -rf node_modules package-lock.json
npm install
```

#### CORS 오류
- 백엔드의 CORS 설정 확인
- 프론트엔드 URL이 허용 목록에 포함되어 있는지 확인

### Validation Error 디버깅
- `backend/test_validation_errors.py` 실행
- Swagger UI에서 요청/응답 확인
- 브라우저 개발자 도구에서 네트워크 탭 확인

## 🤝 기여하기

1. 이 저장소를 포크합니다
2. 기능 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 👥 팀

- **개발자**: [Your Name]
- **프로젝트**: Todo API with React Frontend
- **버전**: 1.0.0

---

**Happy Coding! 🎉**
