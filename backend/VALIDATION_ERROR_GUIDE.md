# FastAPI Validation Error 가이드

## 개요
FastAPI는 Pydantic을 사용하여 자동으로 요청 데이터를 검증하고 직렬화합니다. 잘못된 데이터가 전송되면 HTTP 422 Unprocessable Entity 에러가 발생합니다.

## Pydantic 검증 작동 원리

### 1. 자동 검증 프로세스
```python
# 요청이 들어오면 FastAPI는 다음과 같이 처리합니다:
# 1. JSON 데이터 파싱
# 2. Pydantic 모델로 변환 시도
# 3. 검증 실패 시 422 에러 반환
# 4. 검증 성공 시 함수 실행
```

### 2. 검증 단계
1. **타입 검증**: 데이터 타입이 모델과 일치하는지 확인
2. **필수 필드 검증**: 필수 필드가 누락되지 않았는지 확인
3. **제약 조건 검증**: 길이, 범위, 패턴 등 제약 조건 확인
4. **커스텀 검증**: 사용자 정의 검증 함수 실행

## 422 에러 발생 시점

### 1. 타입 불일치
```python
# 모델 정의
class TodoItem(BaseModel):
    id: str
    title: str
    completed: bool

# 잘못된 요청 (completed가 문자열)
{
    "id": "123",
    "title": "테스트",
    "completed": "true"  # ❌ boolean이어야 함
}
```

### 2. 필수 필드 누락
```python
# 모델 정의
class TodoItem(BaseModel):
    id: str
    title: str  # 필수 필드
    description: Optional[str] = None  # 선택적 필드

# 잘못된 요청 (title 누락)
{
    "id": "123",
    "description": "설명"  # ❌ title이 누락됨
}
```

### 3. 제약 조건 위반
```python
# 모델 정의
class TodoItem(BaseModel):
    id: str
    title: str = Field(..., min_length=1, max_length=100)
    priority: int = Field(..., ge=1, le=5)

# 잘못된 요청
{
    "id": "123",
    "title": "",  # ❌ 최소 길이 1 미만
    "priority": 10  # ❌ 최대값 5 초과
}
```

### 4. 잘못된 JSON 형식
```python
# 잘못된 JSON
{
    "id": "123",
    "title": "테스트",
    "completed": true,  # ❌ JSON에서 boolean은 따옴표 없음
    "tags": ["tag1", "tag2",]  # ❌ trailing comma
}
```

## 실제 테스트 예시

### 1. 기본 타입 검증 테스트
```bash
# 정상 요청
curl -X POST "http://localhost:8000/todos" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "테스트 할 일",
    "description": "테스트 설명",
    "completed": false
  }'

# 잘못된 타입 요청
curl -X POST "http://localhost:8000/todos" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "테스트 할 일",
    "description": "테스트 설명",
    "completed": "false"  # 문자열이 아닌 boolean이어야 함
  }'
```

### 2. 필수 필드 검증 테스트
```bash
# 필수 필드 누락
curl -X POST "http://localhost:8000/todos" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "테스트 설명",
    "completed": false
  }'  # title 필드 누락
```

### 3. 제약 조건 검증 테스트
```bash
# 빈 제목
curl -X POST "http://localhost:8000/todos" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "",
    "description": "테스트 설명",
    "completed": false
  }'
```

## 일반적인 에러 타입들

### 1. missing_field_error
```json
{
  "detail": [
    {
      "type": "missing",
      "loc": ["body", "title"],
      "msg": "Field required",
      "input": {}
    }
  ]
}
```

### 2. type_error
```json
{
  "detail": [
    {
      "type": "boolean_type",
      "loc": ["body", "completed"],
      "msg": "Input should be a valid boolean",
      "input": "true"
    }
  ]
}
```

### 3. value_error
```json
{
  "detail": [
    {
      "type": "value_error",
      "loc": ["body", "title"],
      "msg": "String should have at least 1 character",
      "input": ""
    }
  ]
}
```

### 4. json_decode_error
```json
{
  "detail": [
    {
      "type": "json_decode_error",
      "loc": ["body"],
      "msg": "Expecting ',' delimiter",
      "input": "{\"title\": \"test\"}"
    }
  ]
}
```

## 에러 처리 방법

### 1. 클라이언트 측 처리
```javascript
// JavaScript/TypeScript
async function createTodo(todoData) {
  try {
    const response = await fetch('/todos', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(todoData)
    });
    
    if (response.status === 422) {
      const errorData = await response.json();
      console.log('Validation errors:', errorData.detail);
      // 사용자에게 에러 메시지 표시
      return;
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error:', error);
  }
}
```

### 2. 서버 측 커스텀 에러 처리
```python
from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

app = FastAPI()

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={
            "message": "입력 데이터가 올바르지 않습니다",
            "errors": [
                {
                    "field": error["loc"][-1] if error["loc"] else "unknown",
                    "message": error["msg"],
                    "type": error["type"]
                }
                for error in exc.errors()
            ]
        }
    )
```

## 모범 사례

### 1. 명확한 모델 정의
```python
from pydantic import BaseModel, Field, validator
from typing import Optional

class TodoCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=100, description="할 일 제목")
    description: Optional[str] = Field(None, max_length=500, description="할 일 설명")
    completed: bool = Field(False, description="완료 여부")
    
    @validator('title')
    def title_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('제목은 비어있을 수 없습니다')
        return v.strip()
```

### 2. 적절한 에러 메시지
```python
# 모델에 에러 메시지 추가
class TodoCreate(BaseModel):
    title: str = Field(
        ..., 
        min_length=1, 
        max_length=100,
        description="할 일 제목 (1-100자)",
        error_messages={
            "missing": "제목은 필수입니다",
            "min_length": "제목은 최소 1자 이상이어야 합니다",
            "max_length": "제목은 최대 100자까지 가능합니다"
        }
    )
```

### 3. 테스트 케이스 작성
```python
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_create_todo_validation():
    # 잘못된 데이터로 테스트
    response = client.post("/todos", json={
        "title": "",  # 빈 제목
        "completed": "not-a-boolean"  # 잘못된 타입
    })
    
    assert response.status_code == 422
    errors = response.json()["detail"]
    
    # 에러 검증
    assert any(error["loc"] == ["body", "title"] for error in errors)
    assert any(error["loc"] == ["body", "completed"] for error in errors)
```

## 디버깅 팁

### 1. 에러 로그 확인
```python
# 개발 환경에서 상세한 에러 정보 확인
import logging
logging.basicConfig(level=logging.DEBUG)
```

### 2. 요청 데이터 검증
```python
# 요청 데이터 로깅
@app.middleware("http")
async def log_requests(request: Request, call_next):
    if request.method == "POST":
        body = await request.body()
        print(f"Request body: {body}")
    response = await call_next(request)
    return response
```

### 3. Pydantic 설정
```python
# Pydantic 설정으로 더 나은 에러 메시지
from pydantic import BaseModel

class Config:
    error_msg_templates = {
        'value_error.missing': '필수 필드입니다',
        'type_error.none.not_allowed': 'null 값은 허용되지 않습니다',
        'value_error.any_str.min_length': '최소 {limit_value}자 이상이어야 합니다'
    }
```

## 결론

FastAPI의 Validation Error는 데이터 무결성을 보장하는 중요한 기능입니다. 적절한 모델 정의와 에러 처리를 통해 사용자에게 명확한 피드백을 제공할 수 있습니다.

### 주요 포인트:
- ✅ 422 에러는 데이터 검증 실패를 나타냄
- ✅ Pydantic이 자동으로 타입과 제약 조건을 검증
- ✅ 명확한 에러 메시지로 사용자 경험 개선
- ✅ 테스트 케이스로 검증 로직 확인
- ✅ 적절한 에러 처리로 안정적인 API 제공
