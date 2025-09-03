import React, { useState, useEffect } from 'react';
import { Todo, NewTodo, TodoUpdate } from './types/Todo';
import { todoAPI } from './services/TodoService';
import TodoList from './components/TodoList';
import TodoForm from './components/TodoForm';
import './App.css';

function App() {
  // 상태 관리
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState<boolean>(false);
  const [editingTodo, setEditingTodo] = useState<Todo | null>(null);

  // 초기 데이터 로드
  useEffect(() => {
    loadTodos();
  }, []);

  // TODO 목록 로드
  const loadTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoAPI.getAll();
      setTodos(data);
    } catch (err) {
      setError('할 일 목록을 불러오는데 실패했습니다.');
      console.error('Error loading todos:', err);
    } finally {
      setLoading(false);
    }
  };

  // 새 TODO 생성
  const handleCreateTodo = async (newTodo: NewTodo) => {
    try {
      setError(null);
      const createdTodo = await todoAPI.create(newTodo);
      setTodos(prev => [createdTodo, ...prev]);
      setShowForm(false);
    } catch (err) {
      setError('새 할 일을 생성하는데 실패했습니다.');
      console.error('Error creating todo:', err);
      throw err; // 폼에서 에러 처리할 수 있도록 재던지기
    }
  };

  // TODO 업데이트
  const handleUpdateTodo = async (id: string, updates: TodoUpdate) => {
    try {
      setError(null);
      const updatedTodo = await todoAPI.update(id, updates);
      setTodos(prev => 
        prev.map(todo => 
          todo.id === id ? updatedTodo : todo
        )
      );
      setEditingTodo(null);
      setShowForm(false);
    } catch (err) {
      setError('할 일을 업데이트하는데 실패했습니다.');
      console.error('Error updating todo:', err);
      throw err;
    }
  };

  // TODO 완료 상태 토글
  const handleToggleTodo = async (id: string, completed: boolean) => {
    try {
      setError(null);
      const updatedTodo = await todoAPI.update(id, { completed });
      setTodos(prev => 
        prev.map(todo => 
          todo.id === id ? updatedTodo : todo
        )
      );
    } catch (err) {
      setError('할 일 상태를 변경하는데 실패했습니다.');
      console.error('Error toggling todo:', err);
    }
  };

  // TODO 삭제
  const handleDeleteTodo = async (id: string) => {
    try {
      setError(null);
      await todoAPI.delete(id);
      setTodos(prev => prev.filter(todo => todo.id !== id));
    } catch (err) {
      setError('할 일을 삭제하는데 실패했습니다.');
      console.error('Error deleting todo:', err);
    }
  };

  // 수정 모드 진입
  const handleEditTodo = (todo: Todo) => {
    setEditingTodo(todo);
    setShowForm(true);
  };

  // 폼 제출 처리 (생성 또는 수정)
  const handleFormSubmit = async (todoData: NewTodo) => {
    if (editingTodo) {
      // 수정 모드
      await handleUpdateTodo(editingTodo.id, todoData);
    } else {
      // 생성 모드
      await handleCreateTodo(todoData);
    }
  };

  // 폼 취소
  const handleFormCancel = () => {
    setShowForm(false);
    setEditingTodo(null);
  };

  // 에러 메시지 초기화
  const clearError = () => {
    setError(null);
  };

  // 로딩 중 표시
  if (loading) {
    return (
      <div className="App">
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>할 일 목록을 불러오는 중...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>📝 TODO 관리 앱</h1>
        <p>할 일을 체계적으로 관리해보세요!</p>
      </header>

      <main className="App-main">
        {/* 에러 메시지 */}
        {error && (
          <div className="error-banner">
            <span>{error}</span>
            <button onClick={clearError} className="error-close">×</button>
          </div>
        )}

        {/* 새 TODO 추가 버튼 */}
        {!showForm && (
          <div className="add-todo-section">
            <button 
              onClick={() => setShowForm(true)}
              className="add-todo-btn"
            >
              ➕ 새 할 일 추가
            </button>
          </div>
        )}

        {/* TODO 폼 */}
        {showForm && (
          <TodoForm
            onSubmit={handleFormSubmit}
            onCancel={handleFormCancel}
            todo={editingTodo || undefined}
            isEditing={!!editingTodo}
          />
        )}

        {/* TODO 목록 */}
        <TodoList
          todos={todos}
          onToggle={handleToggleTodo}
          onEdit={handleEditTodo}
          onDelete={handleDeleteTodo}
        />
      </main>
    </div>
  );
}

export default App;
