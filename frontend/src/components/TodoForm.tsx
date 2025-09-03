import React, { useState, useEffect } from 'react';
import { Todo, NewTodo } from '../types/Todo';
import './TodoForm.css';

interface TodoFormProps {
  onSubmit: (todo: NewTodo) => void;
  onCancel: () => void;
  todo?: Todo; // 수정 모드일 때 전달되는 기존 todo
  isEditing?: boolean;
}

const TodoForm: React.FC<TodoFormProps> = ({ 
  onSubmit, 
  onCancel, 
  todo, 
  isEditing = false 
}) => {
  const [formData, setFormData] = useState<NewTodo>({
    title: '',
    description: '',
    completed: false
  });
  
  const [errors, setErrors] = useState<{ [key: string]: string }>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  // 수정 모드일 때 기존 데이터로 폼 초기화
  useEffect(() => {
    if (todo && isEditing) {
      setFormData({
        title: todo.title,
        description: todo.description,
        completed: todo.completed
      });
    }
  }, [todo, isEditing]);

  // 실시간 유효성 검사
  const validateField = (name: string, value: string): string => {
    switch (name) {
      case 'title':
        if (!value.trim()) {
          return '제목을 입력해주세요';
        }
        if (value.trim().length < 2) {
          return '제목은 2자 이상 입력해주세요';
        }
        if (value.trim().length > 100) {
          return '제목은 100자 이하로 입력해주세요';
        }
        break;
      case 'description':
        if (value.trim().length > 500) {
          return '설명은 500자 이하로 입력해주세요';
        }
        break;
    }
    return '';
  };

  // 입력 필드 변경 처리
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));

    // 실시간 유효성 검사
    const error = validateField(name, value);
    setErrors(prev => ({
      ...prev,
      [name]: error
    }));
  };

  // 폼 제출 처리
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
        // 전체 폼 유효성 검사
    const titleError = validateField('title', formData.title);
    const descriptionError = validateField('description', formData.description || '');

    const newErrors = {
      title: titleError,
      description: descriptionError
    };

    setErrors(newErrors);

    // 에러가 있으면 제출 중단
    if (titleError || descriptionError) {
      return;
    }

    setIsSubmitting(true);

    try {
      await onSubmit({
        title: formData.title.trim(),
        description: formData.description?.trim() || '',
        completed: formData.completed
      });
      
      // 성공 시 폼 초기화
      setFormData({
        title: '',
        description: '',
        completed: false
      });
      setErrors({});
    } catch (error) {
      console.error('Todo 제출 중 오류:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  // 취소 처리
  const handleCancel = () => {
    setFormData({
      title: '',
      description: '',
      completed: false
    });
    setErrors({});
    onCancel();
  };

  return (
    <div className="todo-form-container">
      <h2 className="form-title">
        {isEditing ? 'TODO 수정' : '새 TODO 추가'}
      </h2>
      
      <form onSubmit={handleSubmit} className="todo-form">
        <div className="form-group">
          <label htmlFor="title" className="form-label">
            제목 <span className="required">*</span>
          </label>
          <input
            type="text"
            id="title"
            name="title"
            value={formData.title}
            onChange={handleInputChange}
            className={`form-input ${errors.title ? 'error' : ''}`}
            placeholder="할 일의 제목을 입력하세요"
            disabled={isSubmitting}
          />
          {errors.title && (
            <span className="error-message">{errors.title}</span>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="description" className="form-label">
            설명
          </label>
          <textarea
            id="description"
            name="description"
            value={formData.description}
            onChange={handleInputChange}
            className={`form-textarea ${errors.description ? 'error' : ''}`}
            placeholder="할 일에 대한 상세 설명을 입력하세요 (선택사항)"
            rows={4}
            disabled={isSubmitting}
          />
          {errors.description && (
            <span className="error-message">{errors.description}</span>
          )}
        </div>

        <div className="form-actions">
          <button
            type="button"
            onClick={handleCancel}
            className="cancel-btn"
            disabled={isSubmitting}
          >
            취소
          </button>
          <button
            type="submit"
            className="submit-btn"
            disabled={isSubmitting || !!errors.title || !!errors.description}
          >
            {isSubmitting ? '처리 중...' : (isEditing ? '수정' : '추가')}
          </button>
        </div>
      </form>
    </div>
  );
};

export default TodoForm;
