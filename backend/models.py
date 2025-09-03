from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import uuid
from datetime import datetime

# Pydantic 모델들
class TodoItem(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    completed: bool = False
    created_at: datetime
    updated_at: datetime

class TodoUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None

# 메모리 내 데이터 저장소
todos_list: List[TodoItem] = []

# CRUD 함수들
def get_all_todos() -> List[TodoItem]:
    """모든 할 일 목록을 반환합니다."""
    return todos_list

def get_todo_by_id(id: str) -> Optional[TodoItem]:
    """ID로 특정 할 일을 찾아 반환합니다."""
    for todo in todos_list:
        if todo.id == id:
            return todo
    return None

def add_todo(title: str, description: Optional[str] = None) -> TodoItem:
    """새로운 할 일을 추가합니다."""
    now = datetime.now()
    todo = TodoItem(
        id=str(uuid.uuid4()),
        title=title,
        description=description,
        completed=False,
        created_at=now,
        updated_at=now
    )
    todos_list.append(todo)
    return todo

def update_todo(id: str, **updates: Any) -> Optional[TodoItem]:
    """할 일을 업데이트합니다."""
    for i, todo in enumerate(todos_list):
        if todo.id == id:
            # 업데이트할 필드들만 변경
            update_data = {}
            for key, value in updates.items():
                if hasattr(todo, key) and value is not None:
                    update_data[key] = value
            
            if update_data:
                update_data['updated_at'] = datetime.now()
                updated_todo = todo.model_copy(update=update_data)
                todos_list[i] = updated_todo
                return updated_todo
            return todo
    return None

def delete_todo(id: str) -> bool:
    """할 일을 삭제합니다."""
    for i, todo in enumerate(todos_list):
        if todo.id == id:
            todos_list.pop(i)
            return True
    return False
