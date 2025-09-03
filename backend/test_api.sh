#!/bin/bash

# Todo API 자동 테스트 스크립트 (Bash)
# 사용법: ./test_api.sh

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 색상 함수들
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${CYAN}$1${NC}"; }
print_header() { echo -e "${BLUE}$1${NC}"; }
print_magenta() { echo -e "${MAGENTA}$1${NC}"; }

# 기본 설정
BASE_URL=${1:-"http://localhost:8000"}
VERBOSE=${2:-false}

# 테스트 결과 카운터
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TODO_ID=""

# 테스트 함수
test_endpoint() {
    local name="$1"
    local method="$2"
    local url="$3"
    local body="$4"
    local expected_status="${5:-200}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo
    print_info "[테스트 $TOTAL_TESTS] $name"
    print_info "  $method $url"
    
    # curl 옵션 설정
    local curl_opts=(
        -s
        -w "\n%{http_code}"
        -X "$method"
        -H "Content-Type: application/json"
    )
    
    if [ -n "$body" ]; then
        curl_opts+=(-d "$body")
    fi
    
    # API 호출
    local response
    response=$(curl "${curl_opts[@]}" "$url" 2>/dev/null)
    
    # 응답과 상태 코드 분리
    local http_code
    http_code=$(echo "$response" | tail -n1)
    local response_body
    response_body=$(echo "$response" | head -n -1)
    
    # 결과 확인
    if [ "$http_code" -eq "$expected_status" ]; then
        print_success "성공"
        if [ "$VERBOSE" = "true" ] && [ -n "$response_body" ]; then
            print_info "  응답: $response_body"
        fi
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "$response_body"
    else
        print_error "실패 - 상태: $http_code, 예상: $expected_status"
        if [ -n "$response_body" ]; then
            print_error "  오류: $response_body"
        fi
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo ""
    fi
}

# 메인 테스트 실행
run_api_tests() {
    print_magenta "🚀 Todo API 자동 테스트 시작"
    print_magenta "📍 기본 URL: $BASE_URL"
    print_magenta "⏰ 시작 시간: $(date)"
    
    # 1. 기본 엔드포인트 테스트
    print_header "📋 1. 기본 엔드포인트 테스트"
    
    test_endpoint "API 상태 확인" "GET" "$BASE_URL/"
    
    # 2. CRUD 엔드포인트 테스트
    print_header "📋 2. CRUD 엔드포인트 테스트"
    
    # 초기 상태 확인
    test_endpoint "초기 할 일 목록 조회" "GET" "$BASE_URL/todos"
    
    # 새 할 일 생성
    local new_todo='{"title": "Bash 테스트 할 일", "description": "Bash 스크립트로 생성된 테스트 할 일", "completed": false}'
    local created_response
    created_response=$(test_endpoint "새 할 일 생성" "POST" "$BASE_URL/todos" "$new_todo")
    
    # 생성된 할 일 ID 추출
    if [ -n "$created_response" ]; then
        TODO_ID=$(echo "$created_response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$TODO_ID" ]; then
            print_info "  생성된 할 일 ID: $TODO_ID"
        fi
    fi
    
    # 생성된 할 일 조회
    if [ -n "$TODO_ID" ]; then
        test_endpoint "특정 할 일 조회" "GET" "$BASE_URL/todos/$TODO_ID"
    fi
    
    # 할 일 업데이트
    if [ -n "$TODO_ID" ]; then
        local update_data='{"title": "업데이트된 Bash 테스트 할 일", "description": "Bash로 업데이트된 할 일", "completed": true}'
        test_endpoint "할 일 업데이트" "PUT" "$BASE_URL/todos/$TODO_ID" "$update_data"
    fi
    
    # 할 일 완료 상태 토글
    if [ -n "$TODO_ID" ]; then
        test_endpoint "할 일 완료 상태 토글" "PATCH" "$BASE_URL/todos/$TODO_ID/toggle"
    fi
    
    # 3. 에러 케이스 테스트
    print_header "📋 3. 에러 케이스 테스트"
    
    test_endpoint "존재하지 않는 할 일 조회 (404)" "GET" "$BASE_URL/todos/non-existent-id" "" "404"
    
    local empty_title='{"title": "", "description": "빈 제목 테스트"}'
    test_endpoint "빈 제목으로 할 일 생성 (400)" "POST" "$BASE_URL/todos" "$empty_title" "400"
    
    local invalid_json='{"title": "잘못된 JSON", "description": "테스트", "completed": "not-a-boolean"}'
    test_endpoint "잘못된 JSON 형식 (422)" "POST" "$BASE_URL/todos" "$invalid_json" "422"
    
    local update_data='{"title": "업데이트 테스트", "description": "존재하지 않는 할 일"}'
    test_endpoint "존재하지 않는 할 일 업데이트 (404)" "PUT" "$BASE_URL/todos/non-existent-id" "$update_data" "404"
    
    test_endpoint "존재하지 않는 할 일 삭제 (404)" "DELETE" "$BASE_URL/todos/non-existent-id" "" "404"
    
    # 4. 테스트 전용 엔드포인트
    print_header "📋 4. 테스트 전용 엔드포인트"
    
    test_endpoint "테스트 상태 확인" "GET" "$BASE_URL/test/status"
    
    test_endpoint "샘플 데이터 추가" "POST" "$BASE_URL/test/sample-data"
    
    # 업데이트된 상태 확인
    test_endpoint "샘플 데이터 추가 후 상태 확인" "GET" "$BASE_URL/todos"
    
    # 5. 정리 테스트
    print_header "📋 5. 정리 테스트"
    
    # 생성된 할 일 삭제
    if [ -n "$TODO_ID" ]; then
        test_endpoint "생성된 할 일 삭제" "DELETE" "$BASE_URL/todos/$TODO_ID"
    fi
    
    test_endpoint "모든 데이터 삭제" "DELETE" "$BASE_URL/test/clear-all"
    
    # 최종 상태 확인
    test_endpoint "최종 상태 확인" "GET" "$BASE_URL/todos"
}

# 메인 실행
main() {
    # curl 설치 확인
    if ! command -v curl &> /dev/null; then
        print_error "curl이 설치되어 있지 않습니다. 설치 후 다시 시도해주세요."
        exit 1
    fi
    
    # 서버 연결 확인
    if ! curl -s "$BASE_URL/" > /dev/null 2>&1; then
        print_error "서버에 연결할 수 없습니다. 서버가 실행 중인지 확인해주세요: $BASE_URL"
        exit 1
    fi
    
    # 테스트 실행
    run_api_tests
    
    # 결과 출력
    echo
    print_magenta "=================================================="
    print_magenta "📊 테스트 결과 요약"
    print_magenta "=================================================="
    echo -e "${WHITE}총 테스트: $TOTAL_TESTS${NC}"
    print_success "성공: $PASSED_TESTS"
    print_error "실패: $FAILED_TESTS"
    
    # 성공률 계산
    if [ $TOTAL_TESTS -gt 0 ]; then
        local success_rate
        success_rate=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l 2>/dev/null || echo "0")
        if (( $(echo "$success_rate >= 80" | bc -l) )); then
            echo -e "${GREEN}성공률: ${success_rate}%${NC}"
        elif (( $(echo "$success_rate >= 60" | bc -l) )); then
            echo -e "${YELLOW}성공률: ${success_rate}%${NC}"
        else
            echo -e "${RED}성공률: ${success_rate}%${NC}"
        fi
    fi
    
    print_magenta "⏰ 종료 시간: $(date)"
    
    # 종료 코드 설정
    if [ $FAILED_TESTS -eq 0 ]; then
        print_success "🎉 모든 테스트가 성공했습니다!"
        exit 0
    else
        print_error "❌ 일부 테스트가 실패했습니다."
        exit 1
    fi
}

# 스크립트 실행
main "$@"
