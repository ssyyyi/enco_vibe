from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
import models
from models import TodoItem, TodoUpdate

# FastAPI 애플리케이션 생성
app = FastAPI(title="Todo API", version="1.0.0")

# CORS 설정 (React와 통신용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # React 개발 서버
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 기본 엔드포인트
@app.get("/")
def read_root():
    return {"message": "Todo API is running!"}

# 모든 할 일 조회
@app.get("/todos", response_model=List[TodoItem])
def get_todos():
    """모든 할 일 목록을 반환합니다."""
    try:
        return models.get_all_todos()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

# 특정 할 일 조회
@app.get("/todos/{todo_id}", response_model=TodoItem)
def get_todo(todo_id: str):
    """ID로 특정 할 일을 조회합니다."""
    try:
        todo = models.get_todo_by_id(todo_id)
        if todo is None:
            raise HTTPException(status_code=404, detail="할 일을 찾을 수 없습니다")
        return todo
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

# 새로운 할 일 생성
@app.post("/todos", response_model=TodoItem)
def create_todo(todo_data: dict):
    """새로운 할 일을 생성합니다."""
    try:
        title = todo_data.get("title", "")
        description = todo_data.get("description")
        
        if not title or title.strip() == "":
            raise HTTPException(status_code=400, detail="제목은 필수입니다")
        
        return models.add_todo(title=title.strip(), description=description)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

# 할 일 업데이트
@app.put("/todos/{todo_id}", response_model=TodoItem)
def update_todo(todo_id: str, todo_update: TodoUpdate):
    """할 일을 업데이트합니다."""
    try:
        # 업데이트할 데이터 준비
        update_data = {}
        if todo_update.title is not None:
            if todo_update.title.strip() == "":
                raise HTTPException(status_code=400, detail="제목은 비어있을 수 없습니다")
            update_data["title"] = todo_update.title.strip()
        if todo_update.description is not None:
            update_data["description"] = todo_update.description
        if todo_update.completed is not None:
            update_data["completed"] = todo_update.completed
        
        # 업데이트 실행
        updated_todo = models.update_todo(todo_id, **update_data)
        if updated_todo is None:
            raise HTTPException(status_code=404, detail="할 일을 찾을 수 없습니다")
        
        return updated_todo
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

# 할 일 삭제
@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: str):
    """할 일을 삭제합니다."""
    try:
        success = models.delete_todo(todo_id)
        if not success:
            raise HTTPException(status_code=404, detail="할 일을 찾을 수 없습니다")
        return {"message": "할 일이 삭제되었습니다"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

# 할 일 완료 상태 토글
@app.patch("/todos/{todo_id}/toggle")
def toggle_todo(todo_id: str):
    """할 일의 완료 상태를 토글합니다."""
    try:
        todo = models.get_todo_by_id(todo_id)
        if todo is None:
            raise HTTPException(status_code=404, detail="할 일을 찾을 수 없습니다")
        
        updated_todo = models.update_todo(todo_id, completed=not todo.completed)
        return updated_todo
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

# ===== 테스트 전용 엔드포인트들 =====

@app.post("/test/sample-data")
def add_sample_data():
    """샘플 TODO 데이터 5개를 추가합니다."""
    try:
        sample_todos = [
            {"title": "React 공부하기", "description": "React 컴포넌트와 훅에 대해 학습"},
            {"title": "FastAPI 문서 읽기", "description": "FastAPI 공식 문서를 통해 API 개발 방법 학습"},
            {"title": "프로젝트 기획", "description": "새로운 프로젝트 아이디어 구체화"},
            {"title": "운동하기", "description": "30분 이상 유산소 운동 실시"},
            {"title": "독서하기", "description": "기술 서적 1시간 이상 읽기"}
        ]
        
        added_todos = []
        for todo_data in sample_todos:
            todo = models.add_todo(
                title=todo_data["title"],
                description=todo_data["description"]
            )
            added_todos.append(todo)
        
        return {
            "message": f"{len(added_todos)}개의 샘플 데이터가 추가되었습니다",
            "added_todos": added_todos
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"샘플 데이터 추가 중 오류: {str(e)}")

@app.delete("/test/clear-all")
def clear_all_todos():
    """모든 TODO를 삭제합니다 (테스트 초기화용)."""
    try:
        # 현재 모든 할 일 개수 확인
        current_todos = models.get_all_todos()
        count = len(current_todos)
        
        # todos_list를 빈 리스트로 초기화
        models.todos_list.clear()
        
        return {
            "message": f"모든 할 일이 삭제되었습니다 (총 {count}개)",
            "deleted_count": count
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"데이터 삭제 중 오류: {str(e)}")

@app.get("/test/status")
def get_test_status():
    """테스트 상태를 확인합니다."""
    try:
        todos = models.get_all_todos()
        return {
            "total_todos": len(todos),
            "completed_todos": len([todo for todo in todos if todo.completed]),
            "pending_todos": len([todo for todo in todos if not todo.completed]),
            "server_status": "running"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"상태 확인 중 오류: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
