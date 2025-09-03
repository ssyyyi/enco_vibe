#!/usr/bin/env python3
"""
FastAPI Validation Error 테스트 스크립트
사용법: python test_validation_errors.py
"""

import requests
import json
from typing import Dict, Any

BASE_URL = "http://localhost:8000"

def test_validation_error(name: str, data: Dict[str, Any], expected_status: int = 422):
    """검증 에러 테스트 함수"""
    print(f"\n🧪 테스트: {name}")
    print(f"📤 요청 데이터: {json.dumps(data, ensure_ascii=False, indent=2)}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/todos",
            json=data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"📥 응답 상태: {response.status_code}")
        
        if response.status_code == expected_status:
            print("✅ 예상된 검증 에러 발생")
            error_data = response.json()
            print("📋 에러 상세:")
            for error in error_data.get("detail", []):
                print(f"   - 필드: {error.get('loc', [])[-1] if error.get('loc') else 'unknown'}")
                print(f"   - 타입: {error.get('type', 'unknown')}")
                print(f"   - 메시지: {error.get('msg', 'unknown')}")
                print(f"   - 입력값: {error.get('input', 'unknown')}")
        else:
            print(f"❌ 예상과 다른 상태 코드: {response.status_code}")
            print(f"응답: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ 요청 실패: {e}")

def main():
    """메인 테스트 실행"""
    print("🚀 FastAPI Validation Error 테스트 시작")
    print("=" * 50)
    
    # 1. 타입 불일치 테스트
    test_validation_error(
        "Boolean 타입 불일치",
        {
            "title": "테스트 할 일",
            "description": "테스트 설명",
            "completed": "true"  # 문자열이 아닌 boolean이어야 함
        }
    )
    
    # 2. 필수 필드 누락 테스트
    test_validation_error(
        "필수 필드 누락 (title)",
        {
            "description": "테스트 설명",
            "completed": False
        }
    )
    
    # 3. 빈 문자열 테스트
    test_validation_error(
        "빈 제목",
        {
            "title": "",
            "description": "테스트 설명",
            "completed": False
        }
    )
    
    # 4. 잘못된 JSON 형식 테스트
    test_validation_error(
        "잘못된 JSON 형식",
        {
            "title": "테스트 할 일",
            "description": "테스트 설명",
            "completed": "not-a-boolean"  # boolean이 아닌 문자열
        }
    )
    
    # 5. 추가 필드 테스트
    test_validation_error(
        "추가 필드 포함",
        {
            "title": "테스트 할 일",
            "description": "테스트 설명",
            "completed": False,
            "extra_field": "추가 필드"  # 모델에 정의되지 않은 필드
        }
    )
    
    # 6. null 값 테스트
    test_validation_error(
        "null 값 포함",
        {
            "title": None,  # null 값
            "description": "테스트 설명",
            "completed": False
        }
    )
    
    # 7. 정상 요청 테스트 (대조군)
    print(f"\n🧪 테스트: 정상 요청 (대조군)")
    print("📤 요청 데이터: {'title': '정상 할 일', 'description': '정상 설명', 'completed': False}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/todos",
            json={
                "title": "정상 할 일",
                "description": "정상 설명",
                "completed": False
            },
            headers={"Content-Type": "application/json"}
        )
        
        print(f"📥 응답 상태: {response.status_code}")
        if response.status_code == 200:
            print("✅ 정상 요청 성공")
            result = response.json()
            print(f"📋 생성된 할 일 ID: {result.get('id', 'unknown')}")
        else:
            print(f"❌ 예상과 다른 상태 코드: {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ 요청 실패: {e}")
    
    print("\n" + "=" * 50)
    print("🏁 Validation Error 테스트 완료")

if __name__ == "__main__":
    main()
