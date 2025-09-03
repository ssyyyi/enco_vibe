import axios from 'axios';
import { Todo, NewTodo, TodoUpdate } from '../types/Todo';

// API 기본 URL (환경에 따라 변경 가능)
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

// Todo API 서비스 객체
export const todoAPI = {
  // 모든 TODO 가져오기
  async getAll(): Promise<Todo[]> {
    try {
      const response = await axios.get<Todo[]>(`${API_BASE_URL}/todos`);
      return response.data;
    } catch (error) {
      console.error('Error fetching todos:', error);
      throw error;
    }
  },

  // 특정 TODO 가져오기
  async getById(id: string): Promise<Todo> {
    try {
      const response = await axios.get<Todo>(`${API_BASE_URL}/todos/${id}`);
      return response.data;
    } catch (error) {
      console.error(`Error fetching todo with id ${id}:`, error);
      throw error;
    }
  },

  // 새 TODO 만들기
  async create(todo: NewTodo): Promise<Todo> {
    try {
      const response = await axios.post<Todo>(`${API_BASE_URL}/todos`, todo);
      return response.data;
    } catch (error) {
      console.error('Error creating todo:', error);
      throw error;
    }
  },

  // TODO 업데이트하기
  async update(id: string, updates: TodoUpdate): Promise<Todo> {
    try {
      const response = await axios.put<Todo>(`${API_BASE_URL}/todos/${id}`, updates);
      return response.data;
    } catch (error) {
      console.error(`Error updating todo with id ${id}:`, error);
      throw error;
    }
  },

  // TODO 삭제하기
  async delete(id: string): Promise<void> {
    try {
      await axios.delete(`${API_BASE_URL}/todos/${id}`);
    } catch (error) {
      console.error(`Error deleting todo with id ${id}:`, error);
      throw error;
    }
  }
};
