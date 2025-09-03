import React from 'react';
import { Todo } from '../types/Todo';
import TodoItem from './TodoItem';
import './TodoList.css';

interface TodoListProps {
  todos: Todo[];
  onToggle: (id: string, completed: boolean) => void;
  onEdit: (todo: Todo) => void;
  onDelete: (id: string) => void;
}

const TodoList: React.FC<TodoListProps> = ({ 
  todos, 
  onToggle, 
  onEdit, 
  onDelete 
}) => {
  // 완료/미완료 상태별로 분류
  const completedTodos = todos.filter(todo => todo.completed);
  const activeTodos = todos.filter(todo => !todo.completed);

  // 빈 목록일 때 표시할 메시지
  const EmptyMessage = ({ message }: { message: string }) => (
    <div className="empty-message">
      <div className="empty-icon">📝</div>
      <p className="empty-text">{message}</p>
    </div>
  );

  // 전체 목록이 비어있을 때
  if (todos.length === 0) {
    return (
      <div className="todo-list-container">
        <EmptyMessage message="아직 등록된 할 일이 없습니다. 새로운 할 일을 추가해보세요!" />
      </div>
    );
  }

  return (
    <div className="todo-list-container">
      {/* 진행 중인 할 일들 */}
      <div className="todo-section">
        <h3 className="section-title">
          진행 중인 할 일 
          <span className="todo-count">({activeTodos.length})</span>
        </h3>
        {activeTodos.length === 0 ? (
          <EmptyMessage message="진행 중인 할 일이 없습니다. 모든 할 일을 완료했네요! 🎉" />
        ) : (
          <div className="todo-items">
            {activeTodos.map(todo => (
              <TodoItem
                key={todo.id}
                todo={todo}
                onToggle={onToggle}
                onEdit={onEdit}
                onDelete={onDelete}
              />
            ))}
          </div>
        )}
      </div>

      {/* 완료된 할 일들 */}
      {completedTodos.length > 0 && (
        <div className="todo-section completed-section">
          <h3 className="section-title completed-title">
            완료된 할 일
            <span className="todo-count">({completedTodos.length})</span>
          </h3>
          <div className="todo-items completed-items">
            {completedTodos.map(todo => (
              <TodoItem
                key={todo.id}
                todo={todo}
                onToggle={onToggle}
                onEdit={onEdit}
                onDelete={onDelete}
              />
            ))}
          </div>
        </div>
      )}

      {/* 전체 통계 */}
      <div className="todo-stats">
        <div className="stat-item">
          <span className="stat-label">전체</span>
          <span className="stat-value">{todos.length}</span>
        </div>
        <div className="stat-item">
          <span className="stat-label">진행 중</span>
          <span className="stat-value active">{activeTodos.length}</span>
        </div>
        <div className="stat-item">
          <span className="stat-label">완료</span>
          <span className="stat-value completed">{completedTodos.length}</span>
        </div>
        {todos.length > 0 && (
          <div className="stat-item">
            <span className="stat-label">진행률</span>
            <span className="stat-value progress">
              {Math.round((completedTodos.length / todos.length) * 100)}%
            </span>
          </div>
        )}
      </div>
    </div>
  );
};

export default TodoList;
