# Todo API 프로젝트 개발 가이드

이 문서는 Todo API 프로젝트의 개발 환경 설정과 개발 워크플로우를 설명합니다.

## 🎯 프로젝트 개요

FastAPI 백엔드와 React 프론트엔드로 구성된 Todo 관리 애플리케이션입니다.

### 주요 기능
- ✅ 할 일 CRUD 작업
- ✅ 실시간 데이터 동기화
- ✅ 데이터 검증 및 에러 처리
- ✅ 자동화된 테스트
- ✅ API 문서화

## 🛠️ 개발 환경 설정

### 1. 시스템 요구사항

#### 필수 소프트웨어
- **Python**: 3.8 이상
- **Node.js**: 16.0.0 이상
- **npm**: 8.0.0 이상
- **Git**: 버전 관리

#### 권장 개발 도구
- **VS Code** - 코드 편집기
- **Postman** - API 테스트
- **Chrome DevTools** - 브라우저 디버깅

### 2. 프로젝트 클론

```bash
# 저장소 클론
git clone <repository-url>
cd vibe_coding

# 프로젝트 구조 확인
ls -la
```

### 3. 백엔드 환경 설정

```bash
# 백엔드 디렉토리로 이동
cd backend

# Python 가상환경 생성
python -m venv venv

# 가상환경 활성화
# Windows
.\venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 의존성 설치
pip install -r requirements.txt

# 설치 확인
python -c "import fastapi, uvicorn, pydantic; print('백엔드 환경 설정 완료!')"
```

### 4. 프론트엔드 환경 설정

```bash
# 새 터미널에서 프론트엔드 디렉토리로 이동
cd frontend

# 의존성 설치
npm install

# 설치 확인
npm run build
```

## 🚀 개발 서버 실행

### 1. 백엔드 서버

```bash
# 백엔드 디렉토리에서
cd backend
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# 개발 서버 실행
uvicorn main:app --reload
```

**확인 사항:**
- 서버가 `http://localhost:8000`에서 실행되는지 확인
- Swagger UI (`http://localhost:8000/docs`) 접속 가능한지 확인

### 2. 프론트엔드 서버

```bash
# 새 터미널에서 프론트엔드 디렉토리로 이동
cd frontend

# 개발 서버 실행
npm start
```

**확인 사항:**
- 앱이 `http://localhost:3000`에서 실행되는지 확인
- 브라우저에서 Todo 앱이 정상적으로 로드되는지 확인

## 🧪 테스트 실행

### 1. API 테스트

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

### 2. Postman 테스트

1. **컬렉션 가져오기**
   - Postman 열기
   - Import 버튼 클릭
   - `backend/Todo_API_Collection.json` 파일 선택

2. **환경 설정**
   - Import 버튼 클릭
   - `backend/Todo_API_Environment.json` 파일 선택
   - 환경을 "Todo API Environment"로 설정

3. **테스트 실행**
   - 컬렉션의 "Run" 버튼 클릭
   - 모든 요청이 순차적으로 실행됨

### 3. 브라우저 테스트

1. **Swagger UI 테스트**
   - `http://localhost:8000/docs` 접속
   - 각 엔드포인트를 개별적으로 테스트

2. **React 앱 테스트**
   - `http://localhost:3000` 접속
   - 할 일 추가, 수정, 삭제, 완료 토글 테스트

## 🔧 개발 워크플로우

### 1. 백엔드 개발

#### 새 엔드포인트 추가
```python
# main.py에 새 엔드포인트 추가
@app.post("/todos/{todo_id}/priority")
def update_priority(todo_id: str, priority: int):
    """할 일 우선순위 업데이트"""
    # 구현 로직
    pass
```

#### 모델 수정
```python
# models.py에 새 필드 추가
class TodoItem(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    completed: bool = False
    priority: int = Field(default=1, ge=1, le=5)  # 새 필드
    created_at: datetime
    updated_at: datetime
```

#### 테스트 추가
```python
# test_api.ps1 또는 test_api.sh에 새 테스트 추가
Test-Endpoint -Name "우선순위 업데이트" -Method "POST" -Url "$BaseUrl/todos/$script:TodoId/priority" -Body '{"priority": 3}'
```

### 2. 프론트엔드 개발

#### 새 컴포넌트 생성
```bash
# src/components/ 디렉토리에 새 컴포넌트 파일 생성
touch src/components/TodoPriority.tsx
touch src/components/TodoPriority.css
```

#### API 서비스 업데이트
```typescript
// TodoService.ts에 새 메서드 추가
export const TodoService = {
  // 기존 메서드들...
  
  // 새 메서드
  async updatePriority(id: string, priority: number): Promise<Todo> {
    const response = await axios.patch(`${API_BASE_URL}/todos/${id}/priority`, { priority });
    return response.data;
  }
};
```

#### 타입 정의 업데이트
```typescript
// Todo.ts에 새 필드 추가
export interface Todo {
  id: string;
  title: string;
  description?: string;
  completed: boolean;
  priority: number;  // 새 필드
  created_at: string;
  updated_at: string;
}
```

### 3. 테스트 및 검증

#### 백엔드 테스트
```bash
# API 테스트 실행
cd backend
.\test_api.ps1

# Validation Error 테스트
python test_validation_errors.py
```

#### 프론트엔드 테스트
```bash
# 브라우저에서 수동 테스트
# 1. 새 기능이 정상 작동하는지 확인
# 2. 에러 케이스 테스트
# 3. UI/UX 확인
```

#### 통합 테스트
```bash
# 1. 백엔드 서버 실행
cd backend && uvicorn main:app --reload

# 2. 프론트엔드 서버 실행
cd frontend && npm start

# 3. 브라우저에서 전체 플로우 테스트
```

## 🐛 디버깅 가이드

### 1. 백엔드 디버깅

#### 로그 확인
```bash
# 서버 로그에서 에러 확인
uvicorn main:app --reload --log-level debug
```

#### API 응답 확인
```bash
# curl로 API 테스트
curl -X GET http://localhost:8000/todos
curl -X POST http://localhost:8000/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "테스트", "description": "테스트"}'
```

#### Validation Error 디버깅
```bash
# Validation Error 테스트 실행
python test_validation_errors.py
```

### 2. 프론트엔드 디버깅

#### 브라우저 개발자 도구
1. **Console 탭**: JavaScript 에러 확인
2. **Network 탭**: API 요청/응답 확인
3. **Elements 탭**: DOM 구조 확인

#### TypeScript 에러
```bash
# 타입 체크
npm run type-check

# 타입 에러 수정 후 재시작
npm start
```

### 3. 통합 디버깅

#### CORS 오류
- 백엔드 CORS 설정 확인
- 프론트엔드 URL이 허용 목록에 포함되어 있는지 확인

#### 연결 오류
- 백엔드 서버가 실행 중인지 확인
- 포트 번호가 올바른지 확인
- 방화벽 설정 확인

## 📚 문서 관리

### 1. 코드 문서화

#### Python (백엔드)
```python
@app.post("/todos", response_model=TodoItem)
def create_todo(todo_data: dict):
    """
    새로운 할 일을 생성합니다.
    
    Args:
        todo_data (dict): 할 일 데이터
        
    Returns:
        TodoItem: 생성된 할 일
        
    Raises:
        HTTPException: 데이터 검증 실패 시
    """
    # 구현 로직
    pass
```

#### TypeScript (프론트엔드)
```typescript
/**
 * 할 일을 생성합니다.
 * @param todoData - 생성할 할 일 데이터
 * @returns 생성된 할 일 객체
 * @throws API 에러 시 예외 발생
 */
async function createTodo(todoData: NewTodo): Promise<Todo> {
  // 구현 로직
}
```

### 2. API 문서 업데이트

#### Swagger UI 자동 생성
- FastAPI의 자동 문서화 기능 활용
- `http://localhost:8000/docs`에서 실시간 확인

#### README 업데이트
- 새로운 기능 추가 시 README.md 업데이트
- API 엔드포인트 변경 시 문서 반영

## 🚀 배포 준비

### 1. 백엔드 배포

#### 프로덕션 빌드
```bash
# 의존성 확인
pip freeze > requirements.txt

# 서버 실행 (프로덕션 모드)
uvicorn main:app --host 0.0.0.0 --port 8000
```

#### 환경 변수 설정
```bash
# .env 파일 생성
export DATABASE_URL="your_database_url"
export SECRET_KEY="your_secret_key"
```

### 2. 프론트엔드 배포

#### 프로덕션 빌드
```bash
# 빌드 실행
npm run build

# 빌드 결과 확인
ls -la build/
```

#### 환경 변수 설정
```bash
# .env 파일 생성
REACT_APP_API_URL=https://your-api-domain.com
```

## 🤝 협업 가이드

### 1. Git 워크플로우

```bash
# 새 기능 브랜치 생성
git checkout -b feature/new-feature

# 변경사항 커밋
git add .
git commit -m "feat: 새로운 기능 추가"

# 브랜치 푸시
git push origin feature/new-feature

# Pull Request 생성
```

### 2. 코드 리뷰

#### 리뷰 체크리스트
- [ ] 코드가 요구사항을 만족하는가?
- [ ] 테스트가 포함되어 있는가?
- [ ] 문서가 업데이트되었는가?
- [ ] 에러 처리가 적절한가?
- [ ] 성능에 문제가 없는가?

### 3. 테스트 커버리지

#### 백엔드 테스트
- 모든 엔드포인트 테스트
- 에러 케이스 테스트
- Validation Error 테스트

#### 프론트엔드 테스트
- 컴포넌트 렌더링 테스트
- 사용자 인터랙션 테스트
- API 연동 테스트

## 📖 추가 리소스

### 문서
- [FastAPI 공식 문서](https://fastapi.tiangolo.com/)
- [React 공식 문서](https://reactjs.org/docs/)
- [TypeScript 공식 문서](https://www.typescriptlang.org/docs/)

### 도구
- [Postman](https://www.postman.com/) - API 테스트
- [VS Code](https://code.visualstudio.com/) - 코드 편집기
- [Chrome DevTools](https://developers.google.com/web/tools/chrome-devtools) - 브라우저 디버깅

---

**Happy Development! 🎉**
