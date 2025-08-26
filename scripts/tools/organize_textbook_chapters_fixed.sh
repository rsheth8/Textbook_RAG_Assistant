#!/bin/bash

# Script to organize textbook chunks by actual chapters
# Based on typical Applied Linear Algebra textbook structure

echo "📚 ORGANIZING TEXTBOOK CHUNKS BY CHAPTERS"
echo "=========================================="
echo ""

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
    local start_page=$(echo "$page_range" | cut -d'-' -f1)
    
    case $start_page in
        1|21|41)   echo "Chapter_1_Introduction" ;;
        61|81|101) echo "Chapter_2_Linear_Equations" ;;
        121|141|161) echo "Chapter_3_Matrices" ;;
        181|201|221) echo "Chapter_4_Vector_Spaces" ;;
        241|261|281) echo "Chapter_5_Linear_Transformations" ;;
        301|321|341) echo "Chapter_6_Eigenvalues" ;;
        361|381|401) echo "Chapter_7_Inner_Products" ;;
        421|441|461) echo "Chapter_8_Orthogonality" ;;
        481|501|521) echo "Chapter_9_Diagonalization" ;;
        541|561|581) echo "Chapter_10_Applications" ;;
        601|621|641|661|681|701) echo "Chapter_11_Advanced_Topics" ;;
        *) echo "" ;;
    esac
}

# Function to get part number from page range
get_part_number() {
    local page_range="$1"
    local start_page=$(echo "$page_range" | cut -d'-' -f1)
    
    case $start_page in
        1|61|121|181|241|301|361|421|481|541|601) echo "Part1" ;;
        21|81|141|201|261|321|381|441|501|561|621) echo "Part2" ;;
        41|101|161|221|281|341|401|461|521|581|641) echo "Part3" ;;
        661) echo "Part4" ;;
        681) echo "Part5" ;;
        701) echo "Part6" ;;
        *) echo "Part1" ;;
    esac
}

# Process each chunk and organize by chapter
echo "Processing chunks..."
for chunk_file in pdf_chunks_smart/chunk_*.pdf; do
    if [[ -f "$chunk_file" ]]; then
        filename=$(basename "$chunk_file")
        page_range=$(get_page_range "$filename")
        
        if [[ -n "$page_range" ]]; then
            chapter_name=$(get_chapter_name "$page_range")
            part_number=$(get_part_number "$page_range")
            
            if [[ -n "$chapter_name" ]]; then
                # Create chapter directory
                chapter_dir="organized_chapters/${chapter_name}_${part_number}"
                mkdir -p "$chapter_dir"
                
                # Copy chunk to organized location with better name
                new_filename="${chapter_name}_${part_number}_${page_range}.pdf"
                cp "$chunk_file" "$chapter_dir/$new_filename"
                
                echo "✅ $filename → ${chapter_name}_${part_number}"
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
