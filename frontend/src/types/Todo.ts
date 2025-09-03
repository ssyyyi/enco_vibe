// Todo 인터페이스 - 완전한 Todo 객체
export interface Todo {
  id: string;
  title: string;
  description?: string;
  completed: boolean;
  created_at: string; // ISO 8601 형식의 날짜 문자열
  updated_at: string; // ISO 8601 형식의 날짜 문자열
}

// NewTodo 인터페이스 - 새 TODO 생성용 (id와 createdAt 제외)
export interface NewTodo {
  title: string;
  description?: string;
  completed?: boolean; // 선택적 필드, 기본값은 false
}

// TodoUpdate 인터페이스 - 업데이트용 (모든 필드가 선택적)
export interface TodoUpdate {
  title?: string;
  description?: string;
  completed?: boolean;
}
