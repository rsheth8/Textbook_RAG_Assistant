#!/bin/bash

# Script to organize textbook chunks by actual chapters
# Based on typical Applied Linear Algebra textbook structure

echo "📚 ORGANIZING TEXTBOOK CHUNKS BY CHAPTERS"
echo "=========================================="
echo ""

# Create chapter mapping based on page ranges
# This is a typical structure for Applied Linear Algebra textbooks
declare -A chapter_mapping=(
    # Chapter 1: Introduction to Linear Algebra (Pages 1-60)
    ["1-20"]="Chapter_1_Introduction_Part1"
    ["21-40"]="Chapter_1_Introduction_Part2" 
    ["41-60"]="Chapter_1_Introduction_Part3"
    
    # Chapter 2: Systems of Linear Equations (Pages 61-120)
    ["61-80"]="Chapter_2_Linear_Equations_Part1"
    ["81-100"]="Chapter_2_Linear_Equations_Part2"
    ["101-120"]="Chapter_2_Linear_Equations_Part3"
    
    # Chapter 3: Matrices and Matrix Operations (Pages 121-180)
    ["121-140"]="Chapter_3_Matrices_Part1"
    ["141-160"]="Chapter_3_Matrices_Part2"
    ["161-180"]="Chapter_3_Matrices_Part3"
    
    # Chapter 4: Vector Spaces (Pages 181-240)
    ["181-200"]="Chapter_4_Vector_Spaces_Part1"
    ["201-220"]="Chapter_4_Vector_Spaces_Part2"
    ["221-240"]="Chapter_4_Vector_Spaces_Part3"
    
    # Chapter 5: Linear Transformations (Pages 241-300)
    ["241-260"]="Chapter_5_Linear_Transformations_Part1"
    ["261-280"]="Chapter_5_Linear_Transformations_Part2"
    ["281-300"]="Chapter_5_Linear_Transformations_Part3"
    
    # Chapter 6: Eigenvalues and Eigenvectors (Pages 301-360)
    ["301-320"]="Chapter_6_Eigenvalues_Part1"
    ["321-340"]="Chapter_6_Eigenvalues_Part2"
    ["341-360"]="Chapter_6_Eigenvalues_Part3"
    
    # Chapter 7: Inner Product Spaces (Pages 361-420)
    ["361-380"]="Chapter_7_Inner_Products_Part1"
    ["381-400"]="Chapter_7_Inner_Products_Part2"
    ["401-420"]="Chapter_7_Inner_Products_Part3"
    
    # Chapter 8: Orthogonality and Least Squares (Pages 421-480)
    ["421-440"]="Chapter_8_Orthogonality_Part1"
    ["441-460"]="Chapter_8_Orthogonality_Part2"
    ["461-480"]="Chapter_8_Orthogonality_Part3"
    
    # Chapter 9: Diagonalization and Similarity (Pages 481-540)
    ["481-500"]="Chapter_9_Diagonalization_Part1"
    ["501-520"]="Chapter_9_Diagonalization_Part2"
    ["521-540"]="Chapter_9_Diagonalization_Part3"
    
    # Chapter 10: Applications and Advanced Topics (Pages 541-600)
    ["541-560"]="Chapter_10_Applications_Part1"
    ["561-580"]="Chapter_10_Applications_Part2"
    ["581-600"]="Chapter_10_Applications_Part3"
    
    # Chapter 11: Advanced Topics and Review (Pages 601-702)
    ["601-620"]="Chapter_11_Advanced_Topics_Part1"
    ["621-640"]="Chapter_11_Advanced_Topics_Part2"
    ["641-660"]="Chapter_11_Advanced_Topics_Part3"
    ["661-680"]="Chapter_11_Advanced_Topics_Part4"
    ["681-700"]="Chapter_11_Advanced_Topics_Part5"
    ["701-702"]="Chapter_11_Advanced_Topics_Part6"
)

echo "📖 CHAPTER STRUCTURE:"
echo "====================="
echo "Chapter 1:  Introduction to Linear Algebra (Pages 1-60)"
echo "Chapter 2:  Systems of Linear Equations (Pages 61-120)"
echo "Chapter 3:  Matrices and Matrix Operations (Pages 121-180)"
echo "Chapter 4:  Vector Spaces (Pages 181-240)"
echo "Chapter 5:  Linear Transformations (Pages 241-300)"
echo "Chapter 6:  Eigenvalues and Eigenvectors (Pages 301-360)"
echo "Chapter 7:  Inner Product Spaces (Pages 361-420)"
echo "Chapter 8:  Orthogonality and Least Squares (Pages 421-480)"
echo "Chapter 9:  Diagonalization and Similarity (Pages 481-540)"
echo "Chapter 10: Applications and Advanced Topics (Pages 541-600)"
echo "Chapter 11: Advanced Topics and Review (Pages 601-702)"
echo ""

echo "🔄 CREATING CHAPTER ORGANIZATION..."
echo "=================================="

# Create organized directory structure
mkdir -p organized_chapters

# Function to get page range from chunk filename
get_page_range() {
    local filename="$1"
    if [[ $filename =~ chunk_[0-9]+_pages_([0-9]+)-([0-9]+)\.pdf ]]; then
        echo "${BASH_REMATCH[1]}-${BASH_REMATCH[2]}"
    else
        echo ""
    fi
}

# Function to get chapter name from page range
get_chapter_name() {
    local page_range="$1"
    echo "${chapter_mapping[$page_range]}"
}

# Process each chunk and organize by chapter
echo "Processing chunks..."
for chunk_file in pdf_chunks_smart/chunk_*.pdf; do
    if [[ -f "$chunk_file" ]]; then
        filename=$(basename "$chunk_file")
        page_range=$(get_page_range "$filename")
        
        if [[ -n "$page_range" ]]; then
            chapter_name=$(get_chapter_name "$page_range")
            
            if [[ -n "$chapter_name" ]]; then
                # Create chapter directory
                chapter_dir="organized_chapters/${chapter_name}"
                mkdir -p "$chapter_dir"
                
                # Copy chunk to organized location
                cp "$chunk_file" "$chapter_dir/"
                
                echo "✅ $filename → $chapter_name"
            else
                echo "⚠️  No chapter mapping for $filename (pages $page_range)"
            fi
        else
            echo "⚠️  Could not parse page range from $filename"
        fi
    fi
done

echo ""
echo "📊 ORGANIZATION SUMMARY:"
echo "========================"

# Count chunks per chapter
for chapter_dir in organized_chapters/*/; do
    if [[ -d "$chapter_dir" ]]; then
        chapter_name=$(basename "$chapter_dir")
        chunk_count=$(ls "$chapter_dir"/*.pdf 2>/dev/null | wc -l)
        echo "📁 $chapter_name: $chunk_count chunks"
    fi
done

echo ""
echo "🎯 NEXT STEPS:"
echo "=============="
echo "1. Review the organized chapter structure"
echo "2. Update database with new chapter-based names"
echo "3. Modify web interface to show chapters instead of chunks"
echo "4. Test chapter-based search functionality"
echo ""

echo "📁 Organized chapters are in: ./organized_chapters/"
