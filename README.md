gutenbergwords
==============

Script used to download random books from Project Gutenberg's catalog and strip out all punctuation.

    Usage: ./getbooks.sh [-f FILE] [[-d FOLDER] | [-o OUT]]
           ./getbooks.sh [-n NUM] [-m URL] [-d FOLDER]
           ./getbooks.sh [-b BOOK] [-m URL] [[-d FOLDER] | [-o OUT]]
    Retrieve book(s) from Project Gutenberg catalog and strip the file
    of all characters except A-Z and <space>.
      -f FILE        open and partse the book found at FIL
                       (this will ignore options -b -n -m)
      -b BOOK        download and parse book number BOOK from PG catalog
                       (this will ignore option -n)
      -n NUM         download NUM random books (default 1)
      -d FOLDER      save results to FOLDER (default \"./words/\")
      -o FILE        save results to output file FILE
                       (do not use with option -n)
      -m URL         retrieve books from mirror at URL
                       (default \"ftp://mirrors.xmission.com/gutenberg\")
      -u             do not strip header and footer
      -l             language-agnostic download
      -v             show verbose output (for debugging)
      -h, --help     display this message and exit
    
Report bugs to josh+git@nispio.net
