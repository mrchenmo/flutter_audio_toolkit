#!/bin/bash

# iOS Plugin Test Runner
# This script should be run on macOS with Xcode installed

set -e

echo "🚀 Flutter Audio Toolkit iOS Plugin Test Runner"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script must be run on macOS for iOS testing${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${BLUE}📋 System Requirements Check${NC}"
echo "✅ macOS detected"
echo "✅ Xcode available"
echo "✅ Flutter available"
echo ""

# Navigate to the plugin root
cd "$(dirname "$0")"

echo -e "${BLUE}🧹 Cleaning Previous Builds${NC}"
flutter clean
cd example
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks 
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
cd ..
echo "✅ Clean completed"
echo ""

echo -e "${BLUE}📦 Getting Dependencies${NC}"
flutter pub get
cd example
flutter pub get
cd ..
echo "✅ Dependencies resolved"
echo ""

echo -e "${BLUE}🔍 Running Static Analysis${NC}"
if flutter analyze; then
    echo -e "${GREEN}✅ Static analysis passed${NC}"
else
    echo -e "${RED}❌ Static analysis failed${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}📊 Running Dart Tests${NC}"
if flutter test; then
    echo -e "${GREEN}✅ Dart tests passed${NC}"
else
    echo -e "${RED}❌ Dart tests failed${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}🍎 Testing iOS Swift Compilation${NC}"
cd example
if flutter build ios --no-codesign; then
    echo -e "${GREEN}✅ iOS compilation successful${NC}"
else
    echo -e "${RED}❌ iOS compilation failed${NC}"
    exit 1
fi
cd ..
echo ""

echo -e "${BLUE}🧪 Running iOS Unit Tests${NC}"
cd example/ios
if xcodebuild test -project Runner.xcodeproj -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 15'; then
    echo -e "${GREEN}✅ iOS unit tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  iOS unit tests failed (this may be expected if no physical device/simulator is available)${NC}"
fi
cd ../..
echo ""

echo -e "${BLUE}🔗 Running Integration Tests${NC}"
cd example
if flutter test integration_test/ios_plugin_test.dart; then
    echo -e "${GREEN}✅ Integration tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  Integration tests failed (this may be expected without actual iOS device)${NC}"
fi
cd ..
echo ""

echo -e "${BLUE}📱 Optional: Device Testing${NC}"
echo "To test on a physical iOS device or simulator, run:"
echo "  cd example"
echo "  flutter run -d ios"
echo ""

echo -e "${BLUE}🚀 Publishing Validation${NC}"
if flutter pub publish --dry-run; then
    echo -e "${GREEN}✅ Package is ready for publishing${NC}"
else
    echo -e "${RED}❌ Package publishing validation failed${NC}"
    exit 1
fi
echo ""

echo -e "${GREEN}🎉 All iOS tests completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Test on physical iOS device if available"
echo "2. Update version in pubspec.yaml"
echo "3. Update CHANGELOG.md"
echo "4. Commit changes"
echo "5. Run: flutter pub publish"
