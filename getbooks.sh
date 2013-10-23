#!/bin/bash

function show_help()
{
    echo "Usage: `basename $0` [-v] [-f FILE] [-o FOLDER]"
    echo "       `basename $0` [-v] [-b BOOK] [-o FOLDER] [[-m] URL]"
    echo "       `basename $0` [-v] [-n NUM]  [-o FOLDER] [[-m] URL]"
    echo "Retrieve book(s) from Project Gutenberg catalog and strip the file"
    echo "of all characters except A-Z and <space>."
    echo
    echo "  -f FILE        open and partse the book found at FILE"
    echo "                   (this will ignore options -b -n -m)"
    echo "  -b BOOK        download and parse book number BOOK from PG catalog"
    echo "                   (this will ignore option -n)"
    echo "  -n NUM         download NUM random books (default 1)"
    echo "  -o FOLDER      save results to FOLDER (default \"./books\")"
    echo "  -m URL         retrieve books from mirror at URL"
    echo "                   (default \"ftp://mirrors.xmission.com/gutenberg\")"
    echo "  -v             show verbose output (for debugging)"
    echo "  -h, --help     display this message and exit"
    echo 
    echo "  Report bugs to josh+git@nispio.net"
}

# Check for --help option
if [ "$1" = "--help" ]; then show_help; exit 0; fi

# Set default values
MIRROR="ftp://mirrors.xmission.com/gutenberg/"
BOOK_FOLDER="./books"
ITERS=10
BOOK_NUM=0
LANG="ENGLISH"

# NOTE: The Project Gutenberg Terms of Service state that the site is intended
# for human users only. For that reason, this script uses a mirror site rather
# than downloading directly from gutenberg.org.  For more info see:
#
#  www.gutenberg.org/wiki/Gutenberg:Information_About_Robot_Access_to_our_Pages
#

OPTIND=1                        # Reset in case getopts has been used previously
opts="hvf:b:n:o:m:"                  # Options for call to getopts
# Parse input arguments
while getopts "$opts" opt; do
    case "$opt" in
        h)  show_help; exit 0 ;;
        v)  set -x ;;
        f)  BOOK_FILE="$OPTARG" ;;
        n)  ITERS="$OPTARG" ;;
        b)  BOOK_NUM="$OPTARG"; ITERS=1 ;;
        o)  BOOK_FOLDER="$OPTARG" ;;
        m)  MIRROR="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
        :)  echo "Option -$OPTARG requires an argument"; exit 1 ;;
    esac
done

# The folder in which the modified files should be placed
OUTPUT_FOLDER="${BOOK_FOLDER%%/}/words"

if [ ! -d "$BOOK_FOLDER" ]; then mkdir "$BOOK_FOLDER"; fi
if [ ! -d "${BOOK_FOLDER%%/}/words" ]; then mkdir "${BOOK_FOLDER%%/}/words"; fi

# Function that strips the headers/footers and punctuation
function strip_book()
{
    BOOK="$1"
    OUTFILE="$2"

    # Make sure the book is in the selected language
    book_lang=$(grep -m 1 -i -E '^Language:' "$BOOK" | cut -f2 -d' ' )
    if [ -z "$book_lang" ]
    then
	echo "This book's language could not be determined. Skipping."
	echo;
	return 1;
    elif [ ! $LANG=$(echo "$book_lang" | tr 'a-z' 'A-Z' ) ]
    then
	echo "This book is not in English. Language is $book_lang. Skipping."
	echo;
	return 1;
    fi

    # Find where the book actually begins and ends
    #  
    #   Each Project Gutenberg book has a header and footer with copyright
    #   and other information.  Since this text is (nearly) identical in
    #   every book, it would introduce a bias in our training data.  For
    #   that reason, we trim it out of the file. We also discard some
    #   pre-determined number of lines at the beginning and end of the book,
    #   since these lines often contain tables of contents and indices whose
    #   content is atypical of English prose.
    #  
    HEADER_START="START OF (THE|THIS) PROJECT GUTENBERG EBOOK"
    FOOTER_START="END OF (THE|THIS) PROJECT GUTENBERG EBOOK"
    bookstart=$(grep -n -m 1 -i -E "$HEADER_START" "$BOOK" | cut -f1 -d':')
    bookend=$(grep -n -m 1 -i -E "$FOOTER_START" "$BOOK" | cut -f1 -d':')
    prescript=100
    postscript=100
    total_lines=$(wc -l "$BOOK" | cut -f1 -d' ')

    # Trim Gutenberg headers and footers and remove DOS line endings
    t=$(($total_lines - $bookstart - $prescript))
    h=$(($bookend - $bookstart - $prescript - $postscript))
    tail -n $t "$BOOK" | head -n $h | tr -d '\r' > "$OUTFILE"

    # Use sed to achieve the following (in order):
    #   Set a label
    #   Read in the next line
    #   If we aren't at the end of the file go back to label 'a'
    #   Replace line endings with a space
    #   Convert all letters to upper-case
    #   Trim apostrophes (otherwise we see lots of orphaned s chars
    #   Throw out any characters that aren't a-z or <space>
    #   Convert any amount of whitespace into a single @ character
    sed -i \
        -e ':a' \
        -e 'N' \
        -e '$!ba' \
        -e 'y/\n/ /' \
        -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' \
        -e 's/\([A-Z]\)'"'"'\([A-Z]\)/\1\2/g' \
        -e 's/[^A-Z ]/ /g' \
        -e 's/\s\+/@/g' \
        "$OUTFILE"

    echo Words saved to file "$OUTFILE"
    echo;
    return 0;
}

# If a specific file was given to process, run the processing and then exit
if [ -r "$BOOK_FILE" ]
then
    filename=$(basename "$BOOK_FILE")
    OUTFILE="$OUTPUT_FOLDER/${filename%.*}.out"
    strip_book "$BOOK_FILE" "$OUTFILE"
    exit $?
elif [ -n "$BOOK_FILE" ]
then
    echo File not found: "$BOOK_FILE"
    exit 1
fi

# Download the number of books specified by the user and process each one
for i in $(seq 1 $ITERS)
do 
    # Choose a random number between 10000 and 42767
    #   
    #   Project Gutenberg has assigned a unique identifier to every book in
    #   their catalog. These numbers run from 1 to ~44000. We can only generate
    #   random numbers with a range of 32768, so we choose to draw numbers in a 
    #   range that guarantess exactly 5 digits in order to simplify later steps.
    #   
    let "n = (10000+$RANDOM) %100000"
    
    # If a specific book number was given, override the random n
    if [ ! $BOOK_NUM -eq 0 ]; then let "n = $BOOK_NUM % 100000"; fi

    # Separate the decimal digits of n
    let "a4 = $n/10000 %10"
    let "a3 = $n/1000  %10"
    let "a2 = $n/100   %10"
    let "a1 = $n/10    %10"
    let "a0 = $n/10    %10"

    # Generate the appropriate URL and filename for the given book number
    BOOK_URL="${MIRROR%%/}/${a4}/${a3}/${a2}/${a1}/${n}/${n}.txt"
    BOOK="$BOOK_FOLDER/${n}.txt"
    OUTFILE="$OUTPUT_FOLDER/${n}.out"

    # Fetch the book from the mirror site
    wget "$BOOK_URL" --output-document="$BOOK" || rm "$BOOK"

    # If the file wasn't found on the server, break here
    if [ ! -e "$BOOK" ] 
    then
        echo "Project Gutenberg book #$n not found. Try again."
	echo;
	continue;
    fi

    strip_book "$BOOK" "$OUTFILE"
done


# Copyright 2013 Josh Hunsaker (josh+git@nispio.net)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
