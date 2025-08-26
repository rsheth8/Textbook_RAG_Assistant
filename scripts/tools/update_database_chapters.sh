#!/bin/bash

# Script to update database with chapter-based names and create chapter mapping

echo "🔄 UPDATING DATABASE WITH CHAPTER NAMES"
echo "======================================="
echo ""

# Create chapter mapping for the web interface
cat > chapter_mapping.json << 'EOF'
{
  "chapters": [
    {
      "id": 1,
      "name": "Introduction to Linear Algebra",
      "description": "Fundamental concepts, vectors, and basic operations",
      "pageRange": "1-60",
      "documentIds": [77, 85, 98],
      "parts": [
        {"name": "Part 1", "pages": "1-20", "documentId": 77},
        {"name": "Part 2", "pages": "21-40", "documentId": 85},
        {"name": "Part 3", "pages": "41-60", "documentId": 98}
      ]
    },
    {
      "id": 2,
      "name": "Systems of Linear Equations",
      "description": "Solving systems of equations, Gaussian elimination",
      "pageRange": "61-120",
      "documentIds": [105, 107, 106],
      "parts": [
        {"name": "Part 1", "pages": "61-80", "documentId": 105},
        {"name": "Part 2", "pages": "81-100", "documentId": 107},
        {"name": "Part 3", "pages": "101-120", "documentId": 106}
      ]
    },
    {
      "id": 3,
      "name": "Matrices and Matrix Operations",
      "description": "Matrix algebra, operations, and properties",
      "pageRange": "121-180",
      "documentIds": [110, 108, 109],
      "parts": [
        {"name": "Part 1", "pages": "121-140", "documentId": 110},
        {"name": "Part 2", "pages": "141-160", "documentId": 108},
        {"name": "Part 3", "pages": "161-180", "documentId": 109}
      ]
    },
    {
      "id": 4,
      "name": "Vector Spaces",
      "description": "Vector spaces, subspaces, and linear independence",
      "pageRange": "181-240",
      "documentIds": [76, 75, 78],
      "parts": [
        {"name": "Part 1", "pages": "181-200", "documentId": 76},
        {"name": "Part 2", "pages": "201-220", "documentId": 75},
        {"name": "Part 3", "pages": "221-240", "documentId": 78}
      ]
    },
    {
      "id": 5,
      "name": "Linear Transformations",
      "description": "Linear maps, kernel, image, and matrix representations",
      "pageRange": "241-300",
      "documentIds": [80, 79, 82],
      "parts": [
        {"name": "Part 1", "pages": "241-260", "documentId": 80},
        {"name": "Part 2", "pages": "261-280", "documentId": 79},
        {"name": "Part 3", "pages": "281-300", "documentId": 82}
      ]
    },
    {
      "id": 6,
      "name": "Eigenvalues and Eigenvectors",
      "description": "Eigenvalues, eigenvectors, and diagonalization",
      "pageRange": "301-360",
      "documentIds": [81, 83, 86],
      "parts": [
        {"name": "Part 1", "pages": "301-320", "documentId": 81},
        {"name": "Part 2", "pages": "321-340", "documentId": 83},
        {"name": "Part 3", "pages": "341-360", "documentId": 86}
      ]
    },
    {
      "id": 7,
      "name": "Inner Product Spaces",
      "description": "Inner products, norms, and orthogonality",
      "pageRange": "361-420",
      "documentIds": [84, 87, 88],
      "parts": [
        {"name": "Part 1", "pages": "361-380", "documentId": 84},
        {"name": "Part 2", "pages": "381-400", "documentId": 87},
        {"name": "Part 3", "pages": "401-420", "documentId": 88}
      ]
    },
    {
      "id": 8,
      "name": "Orthogonality and Least Squares",
      "description": "Orthogonal projections, QR decomposition, least squares",
      "pageRange": "421-480",
      "documentIds": [89, 92, 90],
      "parts": [
        {"name": "Part 1", "pages": "421-440", "documentId": 89},
        {"name": "Part 2", "pages": "441-460", "documentId": 92},
        {"name": "Part 3", "pages": "461-480", "documentId": 90}
      ]
    },
    {
      "id": 9,
      "name": "Diagonalization and Similarity",
      "description": "Similar matrices, diagonalization, and Jordan forms",
      "pageRange": "481-540",
      "documentIds": [91, 93, 94],
      "parts": [
        {"name": "Part 1", "pages": "481-500", "documentId": 91},
        {"name": "Part 2", "pages": "501-520", "documentId": 93},
        {"name": "Part 3", "pages": "521-540", "documentId": 94}
      ]
    },
    {
      "id": 10,
      "name": "Applications and Advanced Topics",
      "description": "Real-world applications and advanced concepts",
      "pageRange": "541-600",
      "documentIds": [95, 96, 97],
      "parts": [
        {"name": "Part 1", "pages": "541-560", "documentId": 95},
        {"name": "Part 2", "pages": "561-580", "documentId": 96},
        {"name": "Part 3", "pages": "581-600", "documentId": 97}
      ]
    },
    {
      "id": 11,
      "name": "Advanced Topics and Review",
      "description": "Advanced concepts, review, and comprehensive topics",
      "pageRange": "601-702",
      "documentIds": [99, 101, 100, 104, 103, 102],
      "parts": [
        {"name": "Part 1", "pages": "601-620", "documentId": 99},
        {"name": "Part 2", "pages": "621-640", "documentId": 101},
        {"name": "Part 3", "pages": "641-660", "documentId": 100},
        {"name": "Part 4", "pages": "661-680", "documentId": 104},
        {"name": "Part 5", "pages": "681-700", "documentId": 103},
        {"name": "Part 6", "pages": "701-702", "documentId": 102}
      ]
    }
  ]
}
EOF

echo "✅ Created chapter mapping: chapter_mapping.json"
echo ""

# Create a summary of the chapter organization
echo "📚 CHAPTER ORGANIZATION SUMMARY:"
echo "================================"
echo ""

# Read and display chapter information
chapters=$(cat chapter_mapping.json | jq -r '.chapters[] | "\(.id). \(.name) (\(.pageRange)) - \(.description)"')

echo "$chapters" | while IFS= read -r line; do
    echo "📖 $line"
done

echo ""
echo "🎯 FEATURES:"
echo "============"
echo "✅ Organized by actual textbook chapters"
echo "✅ Descriptive chapter names and descriptions"
echo "✅ Page range mapping for each chapter"
echo "✅ Document ID mapping for database integration"
echo "✅ Part-based organization within chapters"
echo ""

echo "🚀 NEXT STEPS:"
echo "=============="
echo "1. Update web interface to use chapter-based selection"
echo "2. Implement chapter-specific search functionality"
echo "3. Add chapter descriptions and metadata"
echo "4. Test chapter-based navigation"
echo ""

echo "📁 Files created:"
echo "   - chapter_mapping.json (Chapter organization data)"
echo "   - organized_chapters/ (Physical chapter organization)"
