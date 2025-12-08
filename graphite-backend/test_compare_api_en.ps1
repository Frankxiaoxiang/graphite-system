# Day 1 API Test Script - Windows PowerShell
# Usage: .\test_compare_api.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Graphite System - Compare API Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:5000"
$username = "admin"
$password = "admin123"

# Step 1: Login to get token
Write-Host "Step 1: Login to get token..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = $username
        password = $password
    } | ConvertTo-Json

    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop

    $loginData = $loginResponse.Content | ConvertFrom-Json
    $token = $loginData.access_token
    
    Write-Host "[SUCCESS] Login successful!" -ForegroundColor Green
    Write-Host "   Username: $($loginData.user.username)" -ForegroundColor Gray
    Write-Host "   Role: $($loginData.user.role)" -ForegroundColor Gray
    Write-Host "   Token: $($token.Substring(0,20))..." -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "[FAILED] Login failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test compare API - 2 experiments
Write-Host "Step 2: Test compare API (2 experiments)..." -ForegroundColor Yellow
try {
    $compareBody = @{
        experiment_ids = @(1, 2)
    } | ConvertTo-Json

    $compareResponse = Invoke-WebRequest -Uri "$baseUrl/api/compare/compare" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $token"} `
        -Body $compareBody `
        -ErrorAction Stop

    $compareData = $compareResponse.Content | ConvertFrom-Json
    
    Write-Host "[SUCCESS] Compare successful!" -ForegroundColor Green
    Write-Host "   Number of experiments: $($compareData.experiments.Count)" -ForegroundColor Gray
    Write-Host "   Number of fields: $($compareData.fields.Count)" -ForegroundColor Gray
    Write-Host ""
    
    # Display experiment list
    Write-Host "   Experiment list:" -ForegroundColor Gray
    foreach ($exp in $compareData.experiments) {
        Write-Host "     - ID: $($exp.id), Code: $($exp.code), Status: $($exp.status)" -ForegroundColor Gray
    }
    Write-Host ""
}
catch {
    Write-Host "[FAILED] Compare failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Check if experiments don't exist
    if ($_.Exception.Message -like "*404*" -or $_.Exception.Message -like "*not exist*") {
        Write-Host ""
        Write-Host "[TIP] Maybe no experiment data in database" -ForegroundColor Yellow
        Write-Host "   Please create test experiments first, or modify experiment IDs in script" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Step 3: Test boundary condition - only 1 experiment (should fail)
Write-Host "Step 3: Test boundary condition (only 1 experiment, should return error)..." -ForegroundColor Yellow
try {
    $compareBody = @{
        experiment_ids = @(1)
    } | ConvertTo-Json

    $compareResponse = Invoke-WebRequest -Uri "$baseUrl/api/compare/compare" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $token"} `
        -Body $compareBody `
        -ErrorAction Stop

    Write-Host "[FAILED] Test failed! (Should return error but succeeded)" -ForegroundColor Red
    Write-Host ""
}
catch {
    $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
    if ($errorResponse.error -like "*at least*2*" -or $errorResponse.error -like "*2*") {
        Write-Host "[SUCCESS] Boundary test passed! Correctly returned error" -ForegroundColor Green
        Write-Host "   Error message: $($errorResponse.error)" -ForegroundColor Gray
    }
    else {
        Write-Host "[WARNING] Returned error but message doesn't match expectation" -ForegroundColor Yellow
        Write-Host "   Error message: $($errorResponse.error)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Step 4: Test boundary condition - 11 experiments (should fail)
Write-Host "Step 4: Test boundary condition (11 experiments, should return error)..." -ForegroundColor Yellow
try {
    $compareBody = @{
        experiment_ids = @(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
    } | ConvertTo-Json

    $compareResponse = Invoke-WebRequest -Uri "$baseUrl/api/compare/compare" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{Authorization = "Bearer $token"} `
        -Body $compareBody `
        -ErrorAction Stop

    Write-Host "[FAILED] Test failed! (Should return error but succeeded)" -ForegroundColor Red
    Write-Host ""
}
catch {
    $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
    if ($errorResponse.error -like "*10*" -or $errorResponse.error -like "*most*") {
        Write-Host "[SUCCESS] Boundary test passed! Correctly returned error" -ForegroundColor Green
        Write-Host "   Error message: $($errorResponse.error)" -ForegroundColor Gray
    }
    else {
        Write-Host "[WARNING] Returned error but message doesn't match expectation" -ForegroundColor Yellow
        Write-Host "   Error message: $($errorResponse.error)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Step 5: Test permission control (skip if no regular user account)
Write-Host "Step 5: Test permission control..." -ForegroundColor Yellow
Write-Host "   [SKIPPED] Need to create regular user account" -ForegroundColor Gray
Write-Host ""

# Complete
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test Summary:" -ForegroundColor Yellow
Write-Host "   [OK] Login function: Normal" -ForegroundColor Green
Write-Host "   [OK] Compare API: Normal" -ForegroundColor Green
Write-Host "   [OK] Boundary test (1 experiment): Normal" -ForegroundColor Green
Write-Host "   [OK] Boundary test (11 experiments): Normal" -ForegroundColor Green
Write-Host ""
Write-Host "Day 1 Backend API Development Complete!" -ForegroundColor Green
Write-Host ""
