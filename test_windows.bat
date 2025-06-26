@echo off
echo 🚀 Flutter Audio Toolkit Windows Test Runner
echo ==========================================
echo.

REM Set color codes (limited in Windows batch)
set RED=[31m
set GREEN=[32m
set YELLOW=[33m
set BLUE=[34m
set NC=[0m

echo %BLUE%🧹 Cleaning Previous Builds%NC%
call flutter clean
cd example
call flutter clean
cd ..
echo ✅ Clean completed
echo.

echo %BLUE%📦 Getting Dependencies%NC%
call flutter pub get
cd example
call flutter pub get
cd ..
echo ✅ Dependencies resolved
echo.

echo %BLUE%🔍 Running Static Analysis%NC%
call flutter analyze
if %ERRORLEVEL% neq 0 (
    echo %RED%❌ Static analysis failed%NC%
    exit /b 1
)
echo %GREEN%✅ Static analysis passed%NC%
echo.

echo %BLUE%📊 Running Dart Tests%NC%
call flutter test
if %ERRORLEVEL% neq 0 (
    echo %RED%❌ Dart tests failed%NC%
    exit /b 1
)
echo %GREEN%✅ Dart tests passed%NC%
echo.

echo %BLUE%🚀 Publishing Validation%NC%
call flutter pub publish --dry-run
if %ERRORLEVEL% neq 0 (
    echo %RED%❌ Package publishing validation failed%NC%
    exit /b 1
)
echo %GREEN%✅ Package is ready for publishing%NC%
echo.

echo %GREEN%🎉 All Windows tests completed successfully!%NC%
echo.
echo Next steps:
echo 1. Run iOS tests on macOS using test_ios.sh
echo 2. Test on physical devices if available
echo 3. Update version in pubspec.yaml
echo 4. Update CHANGELOG.md
echo 5. Commit changes
echo 6. Run: flutter pub publish
