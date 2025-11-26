# Quick questions seeding script
Write-Host "Adding sample questions to database..." -ForegroundColor Yellow

try {
    # Call the seed endpoint
    $result = Invoke-RestMethod -Uri "http://localhost:3000/questions/seed" -Method POST
    
    Write-Host "Success! Questions seeded" -ForegroundColor Green
    Write-Host "Added $($result.count) questions" -ForegroundColor Cyan
    Write-Host "$($result.message)" -ForegroundColor White
    
    # Verify questions were added
    Write-Host ""
    Write-Host "Verifying..." -ForegroundColor Yellow
    $allQuestions = Invoke-RestMethod -Uri "http://localhost:3000/questions"
    Write-Host "Total questions in database: $($allQuestions.Count)" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Done! You can now play Solo Mode!" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure backend is running: npm run start:dev" -ForegroundColor White
    Write-Host "2. Check if http://localhost:3000 is accessible" -ForegroundColor White
    Write-Host "3. Make sure database is connected" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

