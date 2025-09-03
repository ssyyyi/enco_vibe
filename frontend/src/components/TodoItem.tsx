import React from 'react';
import { Todo } from '../types/Todo';
import './TodoItem.css';

interface TodoItemProps {
  todo: Todo;
  onToggle: (id: string, completed: boolean) => void;
  onEdit: (todo: Todo) => void;
  onDelete: (id: string) => void;
}

const TodoItem: React.FC<TodoItemProps> = ({ todo, onToggle, onEdit, onDelete }) => {
  const handleToggle = () => {
    onToggle(todo.id, !todo.completed);
  };

  const handleEdit = () => {
    onEdit(todo);
  };

  const handleDelete = () => {
    onDelete(todo.id);
  };

  return (
    <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
      <div className="todo-content">
        <input
          type="checkbox"
          checked={todo.completed}
          onChange={handleToggle}
          className="todo-checkbox"
        />
        <div className="todo-text">
          <h3 className={`todo-title ${todo.completed ? 'completed' : ''}`}>
            {todo.title}
          </h3>
          <p className={`todo-description ${todo.completed ? 'completed' : ''}`}>
            {todo.description}
          </p>
          <span className="todo-date">
            생성일: {new Date(todo.created_at).toLocaleDateString()}
          </span>
        </div>
      </div>
      <div className="todo-actions">
        <button 
          onClick={handleEdit}
          className="edit-btn"
          disabled={todo.completed}
        >
          수정
        </button>
        <button 
          onClick={handleDelete}
          className="delete-btn"
        >
          삭제
        </button>
      </div>
    </div>
  );
};

export default TodoItem;
