#!/usr/bin/env bash
# Usability Testing Automation Script
# Usage: ./run_usability_tests.sh

echo "🧪 Starting Usability Testing Suite for Info Warga"
echo "=================================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check Flutter is installed
echo -e "${BLUE}[1/6]${NC} Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Flutter found: $(flutter --version | head -1)${NC}"

# Get dependencies
echo ""
echo -e "${BLUE}[2/6]${NC} Getting dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to get dependencies${NC}"
    exit 1
fi

# Run Flutter analysis
echo ""
echo -e "${BLUE}[3/6]${NC} Running Flutter analysis..."
flutter analyze --fatal-infos
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Code analysis passed${NC}"
else
    echo -e "${YELLOW}⚠ Code analysis completed with warnings${NC}"
fi

# Run widget tests
echo ""
echo -e "${BLUE}[4/6]${NC} Running widget tests..."
flutter test test/widget_test.dart
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Widget tests passed${NC}"
else
    echo -e "${RED}✗ Widget tests failed${NC}"
fi

# Run usability integration tests
echo ""
echo -e "${BLUE}[5/6]${NC} Running usability integration tests..."
flutter test integration_test/app_test.dart --coverage
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Usability tests passed${NC}"
else
    echo -e "${RED}✗ Usability tests failed${NC}"
    exit 1
fi

# Generate coverage report
echo ""
echo -e "${BLUE}[6/6]${NC} Generating coverage report..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✓ Coverage report generated: coverage/html/index.html${NC}"
else
    echo -e "${YELLOW}⚠ genhtml not found. Coverage report not generated.${NC}"
    echo "  Install with: gem install lcov"
fi

# Summary
echo ""
echo "=================================================="
echo -e "${GREEN}✓ Usability Testing Suite Completed Successfully!${NC}"
echo "=================================================="
echo ""
echo "📊 Generated Reports:"
echo "  • usability_testing_report.md      (Markdown)"
echo "  • usability_testing_report.html    (Interactive)"
echo "  • usability_testing_results.csv    (Data)"
echo "  • usability_testing_data.json      (JSON)"
echo "  • coverage/html/index.html         (Coverage)"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review the HTML report: usability_testing_report.html"
echo "  2. Check test results: usability_testing_results.csv"
echo "  3. Read recommendations in the reports"
echo "  4. Implement HIGH priority items first"
echo ""
echo "📚 Documentation:"
echo "  • USABILITY_TESTING_README.md      (Guide)"
echo "  • USABILITY_TESTING_SUMMARY.md     (Overview)"
echo ""
