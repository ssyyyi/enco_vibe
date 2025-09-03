#!/usr/bin/env powershell

# Todo API 자동 테스트 스크립트 (PowerShell)
# 사용법: .\test_api.ps1

param(
    [string]$BaseUrl = "http://localhost:8000",
    [switch]$Verbose
)

# 색상 함수들
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

# 테스트 결과 카운터
$script:TotalTests = 0
$script:PassedTests = 0
$script:FailedTests = 0

# 테스트 함수
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [string]$Body = $null,
        [int]$ExpectedStatus = 200
    )
    
    $script:TotalTests++
    Write-Info "`n[테스트 $script:TotalTests] $Name"
    Write-Info "  $Method $Url"
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $headers
        }
        
        if ($Body) {
            $params.Body = $Body
        }
        
        $response = Invoke-RestMethod @params -ErrorAction Stop
        
        if ($response -and $ExpectedStatus -eq 200) {
            Write-Success "  ✓ 성공"
            if ($Verbose) {
                Write-Info "  응답: $($response | ConvertTo-Json -Depth 2)"
            }
            $script:PassedTests++
            return $response
        } else {
            Write-Error "  ✗ 실패 - 예상 상태: $ExpectedStatus"
            $script:FailedTests++
            return $null
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq $ExpectedStatus) {
            Write-Success "  ✓ 성공 (예상된 에러: $statusCode)"
            $script:PassedTests++
        } else {
            Write-Error "  ✗ 실패 - 상태: $statusCode, 예상: $ExpectedStatus"
            Write-Error "  오류: $($_.Exception.Message)"
            $script:FailedTests++
        }
        return $null
    }
}

# 메인 테스트 실행
function Start-APITests {
    Write-Host "`n🚀 Todo API 자동 테스트 시작" -ForegroundColor Magenta
    Write-Host "📍 기본 URL: $BaseUrl" -ForegroundColor Magenta
    Write-Host "⏰ 시작 시간: $(Get-Date)" -ForegroundColor Magenta
    
    # 전역 변수로 todo_id 저장
    $script:TodoId = ""
    
    # 1. 기본 엔드포인트 테스트
    Write-Host "`n📋 1. 기본 엔드포인트 테스트" -ForegroundColor Blue
    
    Test-Endpoint -Name "API 상태 확인" -Method "GET" -Url "$BaseUrl/"
    
    # 2. CRUD 엔드포인트 테스트
    Write-Host "`n📋 2. CRUD 엔드포인트 테스트" -ForegroundColor Blue
    
    # 초기 상태 확인
    $initialTodos = Test-Endpoint -Name "초기 할 일 목록 조회" -Method "GET" -Url "$BaseUrl/todos"
    
    # 새 할 일 생성
    $newTodo = @{
        title = "PowerShell 테스트 할 일"
        description = "PowerShell 스크립트로 생성된 테스트 할 일"
        completed = $false
    } | ConvertTo-Json
    
    $createdTodo = Test-Endpoint -Name "새 할 일 생성" -Method "POST" -Url "$BaseUrl/todos" -Body $newTodo
    
    if ($createdTodo) {
        $script:TodoId = $createdTodo.id
        Write-Info "  생성된 할 일 ID: $script:TodoId"
    }
    
    # 생성된 할 일 조회
    if ($script:TodoId) {
        Test-Endpoint -Name "특정 할 일 조회" -Method "GET" -Url "$BaseUrl/todos/$script:TodoId"
    }
    
    # 할 일 업데이트
    if ($script:TodoId) {
        $updateData = @{
            title = "업데이트된 PowerShell 테스트 할 일"
            description = "PowerShell로 업데이트된 할 일"
            completed = $true
        } | ConvertTo-Json
        
        Test-Endpoint -Name "할 일 업데이트" -Method "PUT" -Url "$BaseUrl/todos/$script:TodoId" -Body $updateData
    }
    
    # 할 일 완료 상태 토글
    if ($script:TodoId) {
        Test-Endpoint -Name "할 일 완료 상태 토글" -Method "PATCH" -Url "$BaseUrl/todos/$script:TodoId/toggle"
    }
    
    # 3. 에러 케이스 테스트
    Write-Host "`n📋 3. 에러 케이스 테스트" -ForegroundColor Blue
    
    Test-Endpoint -Name "존재하지 않는 할 일 조회 (404)" -Method "GET" -Url "$BaseUrl/todos/non-existent-id" -ExpectedStatus 404
    
    $emptyTitle = @{
        title = ""
        description = "빈 제목 테스트"
    } | ConvertTo-Json
    
    Test-Endpoint -Name "빈 제목으로 할 일 생성 (400)" -Method "POST" -Url "$BaseUrl/todos" -Body $emptyTitle -ExpectedStatus 400
    
    $invalidJson = @{
        title = "잘못된 JSON"
        description = "테스트"
        completed = "not-a-boolean"
    } | ConvertTo-Json
    
    Test-Endpoint -Name "잘못된 JSON 형식 (422)" -Method "POST" -Url "$BaseUrl/todos" -Body $invalidJson -ExpectedStatus 422
    
    Test-Endpoint -Name "존재하지 않는 할 일 업데이트 (404)" -Method "PUT" -Url "$BaseUrl/todos/non-existent-id" -Body $updateData -ExpectedStatus 404
    
    Test-Endpoint -Name "존재하지 않는 할 일 삭제 (404)" -Method "DELETE" -Url "$BaseUrl/todos/non-existent-id" -ExpectedStatus 404
    
    # 4. 테스트 전용 엔드포인트
    Write-Host "`n📋 4. 테스트 전용 엔드포인트" -ForegroundColor Blue
    
    Test-Endpoint -Name "테스트 상태 확인" -Method "GET" -Url "$BaseUrl/test/status"
    
    Test-Endpoint -Name "샘플 데이터 추가" -Method "POST" -Url "$BaseUrl/test/sample-data"
    
    # 업데이트된 상태 확인
    Test-Endpoint -Name "샘플 데이터 추가 후 상태 확인" -Method "GET" -Url "$BaseUrl/todos"
    
    # 5. 정리 테스트
    Write-Host "`n📋 5. 정리 테스트" -ForegroundColor Blue
    
    # 생성된 할 일 삭제
    if ($script:TodoId) {
        Test-Endpoint -Name "생성된 할 일 삭제" -Method "DELETE" -Url "$BaseUrl/todos/$script:TodoId"
    }
    
    Test-Endpoint -Name "모든 데이터 삭제" -Method "DELETE" -Url "$BaseUrl/test/clear-all"
    
    # 최종 상태 확인
    Test-Endpoint -Name "최종 상태 확인" -Method "GET" -Url "$BaseUrl/todos"
}

# 테스트 실행 및 결과 출력
try {
    Start-APITests
    
    Write-Host "`n" + "="*50 -ForegroundColor Magenta
    Write-Host "📊 테스트 결과 요약" -ForegroundColor Magenta
    Write-Host "="*50 -ForegroundColor Magenta
    Write-Host "총 테스트: $script:TotalTests" -ForegroundColor White
    Write-Success "성공: $script:PassedTests"
    Write-Error "실패: $script:FailedTests"
    
    $successRate = [math]::Round(($script:PassedTests / $script:TotalTests) * 100, 2)
    Write-Host "성공률: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 60) { "Yellow" } else { "Red" })
    
    Write-Host "`n⏰ 종료 시간: $(Get-Date)" -ForegroundColor Magenta
    
    if ($script:FailedTests -eq 0) {
        Write-Success "`n🎉 모든 테스트가 성공했습니다!"
        exit 0
    } else {
        Write-Error "`n❌ 일부 테스트가 실패했습니다."
        exit 1
    }
}
catch {
    Write-Error "`n💥 테스트 실행 중 오류 발생: $($_.Exception.Message)"
    exit 1
}
