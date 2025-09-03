# Todo React Frontend

React와 TypeScript로 구현된 Todo 관리 애플리케이션의 프론트엔드입니다.

## 🚀 시작하기

### 필수 조건
- Node.js 16.0.0 이상
- npm 8.0.0 이상

### 설치

```bash
# 의존성 설치
npm install
```

### 개발 서버 실행

```bash
# 개발 서버 시작
npm start
```

브라우저에서 [http://localhost:3000](http://localhost:3000)을 열어 애플리케이션을 확인하세요.

### 빌드

```bash
# 프로덕션용 빌드
npm run build
```

## 🛠️ 기술 스택

- **React 18** - 사용자 인터페이스 라이브러리
- **TypeScript** - 타입 안전성
- **Axios** - HTTP 클라이언트
- **CSS3** - 스타일링

## 📁 프로젝트 구조

```
src/
├── components/          # React 컴포넌트
│   ├── TodoForm.tsx    # 할 일 입력 폼
│   ├── TodoItem.tsx    # 할 일 아이템
│   └── TodoList.tsx    # 할 일 목록
├── services/           # API 서비스
│   └── TodoService.ts  # Todo API 클라이언트
├── types/              # TypeScript 타입 정의
│   └── Todo.ts         # Todo 인터페이스
├── App.tsx             # 메인 앱 컴포넌트
└── index.tsx           # 앱 진입점
```

## 🔧 환경 설정

### API URL 설정

`src/services/TodoService.ts`에서 API 기본 URL을 설정할 수 있습니다:

```typescript
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';
```

환경 변수로 설정하려면 `.env` 파일을 생성하세요:

```env
REACT_APP_API_URL=http://localhost:8000
```

## 🧪 테스트

### 백엔드 연결 테스트

백엔드 서버가 실행 중인지 확인하세요:

```bash
# 백엔드 디렉토리에서
cd ../backend
uvicorn main:app --reload
```

### 브라우저 테스트

1. **할 일 추가**: 폼을 사용하여 새 할 일 추가
2. **할 일 수정**: 할 일 클릭하여 제목/설명 수정
3. **완료 토글**: 체크박스로 완료 상태 변경
4. **할 일 삭제**: 삭제 버튼으로 할 일 제거

## 🐛 문제 해결

### 일반적인 문제

#### 백엔드 연결 실패
- 백엔드 서버가 `http://localhost:8000`에서 실행 중인지 확인
- CORS 설정이 올바른지 확인
- 네트워크 탭에서 요청/응답 확인

#### TypeScript 오류
```bash
# 타입 체크
npm run type-check

# 타입 오류 수정 후 재시작
npm start
```

#### 빌드 오류
```bash
# 캐시 클리어
npm run build -- --reset-cache
```

## 📚 API 연동

### TodoService 사용법

```typescript
import { TodoService } from './services/TodoService';

// 모든 할 일 조회
const todos = await TodoService.getAllTodos();

// 새 할 일 생성
const newTodo = await TodoService.createTodo({
  title: "새 할 일",
  description: "설명",
  completed: false
});

// 할 일 수정
const updatedTodo = await TodoService.updateTodo(id, {
  title: "수정된 제목",
  completed: true
});

// 할 일 삭제
await TodoService.deleteTodo(id);
```

## 🎨 스타일링

CSS 파일들은 각 컴포넌트와 함께 위치합니다:
- `TodoForm.css` - 폼 스타일
- `TodoItem.css` - 아이템 스타일
- `TodoList.css` - 목록 스타일
- `App.css` - 전체 앱 스타일

## 📦 사용 가능한 스크립트

- `npm start` - 개발 서버 실행
- `npm run build` - 프로덕션 빌드
- `npm test` - 테스트 실행
- `npm run eject` - 설정 추출 (주의: 되돌릴 수 없음)

## 🤝 기여하기

1. 이 저장소를 포크합니다
2. 기능 브랜치를 생성합니다
3. 변경사항을 커밋합니다
4. 브랜치에 푸시합니다
5. Pull Request를 생성합니다

---

**Happy Coding! 🎉**
