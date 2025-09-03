# FastAPI Todo Backend

FastAPI와 Pydantic을 사용한 Todo 관리 API 백엔드입니다.

## 🚀 시작하기

### 필수 조건
- Python 3.8 이상
- pip (Python 패키지 관리자)

### 설치

```bash
# 가상환경 생성
python -m venv venv

# 가상환경 활성화
# Windows
.\venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 의존성 설치
pip install -r requirements.txt
```

### 서버 실행

```bash
# 개발 서버 실행
uvicorn main:app --reload

# 프로덕션 서버 실행
uvicorn main:app --host 0.0.0.0 --port 8000
```

서버가 `http://localhost:8000`에서 실행됩니다.

## 📚 API 문서

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

## 🧪 테스트

### 자동화 테스트

#### PowerShell (Windows)
```bash
.\test_api.ps1
```

#### Bash (Linux/Mac)
```bash
chmod +x test_api.sh
./test_api.sh
```

#### Validation Error 테스트
```bash
python test_validation_errors.py
```

### Postman 테스트

1. `Todo_API_Collection.json` 파일을 Postman에 가져오기
2. `Todo_API_Environment.json` 파일을 환경으로 설정
3. 컬렉션 실행

## 📁 파일 구조

- `main.py` - FastAPI 애플리케이션 및 엔드포인트
- `models.py` - Pydantic 모델 및 CRUD 함수
- `requirements.txt` - Python 의존성
- `test_api.ps1` - PowerShell 테스트 스크립트
- `test_api.sh` - Bash 테스트 스크립트
- `test_validation_errors.py` - Validation Error 테스트
- `VALIDATION_ERROR_GUIDE.md` - Validation Error 가이드
- `Todo_API_Collection.json` - Postman 컬렉션
- `Todo_API_Environment.json` - Postman 환경 변수

## 🔧 환경 설정

### CORS 설정

`main.py`에서 CORS 설정을 확인하세요:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # React 앱 URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 데이터베이스

현재는 메모리 내 리스트를 사용합니다. 프로덕션에서는 데이터베이스를 연결하세요.

## 🐛 문제 해결

### 일반적인 문제

#### 포트 충돌
```bash
# 포트 확인
netstat -an | findstr :8000  # Windows
lsof -i :8000               # Linux/Mac

# 다른 포트로 실행
uvicorn main:app --reload --port 8001
```

#### 의존성 오류
```bash
# 가상환경 재생성
rm -rf venv
python -m venv venv
source venv/bin/activate  # 또는 .\venv\Scripts\activate
pip install -r requirements.txt
```

#### CORS 오류
- 프론트엔드 URL이 CORS 설정에 포함되어 있는지 확인
- 브라우저 개발자 도구에서 네트워크 탭 확인

## 📖 추가 문서

- `VALIDATION_ERROR_GUIDE.md` - FastAPI 검증 에러 상세 가이드
- API 테스트 스크립트 사용법
- Postman 컬렉션 설정

---

**Happy Coding! 🎉**
