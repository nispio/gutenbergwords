gutenbergwords
==============

Script used to download random books from Project Gutenberg's catalog and strip out all punctuation.

    Usage: ./getbooks.sh [-v] [-f FILE] [-o FOLDER]
           ./getbooks.sh [-v] [-b BOOK] [-o FOLDER] [[-m] URL]
           ./getbooks.sh [-v] [-n NUM]  [-o FOLDER] [[-m] URL]
    Retrieve book(s) from Project Gutenberg catalog and strip the file
    of all characters except A-Z and <space>.
      -f FILE        open and partse the book found at FILE
                       (this will ignore options -b -n -m)
      -b BOOK        download and parse book number BOOK from PG catalog
                       (this will ignore option -n)
      -n NUM         download NUM random books (default 1)
      -o FOLDER      save results to FOLDER (default \"./books\")
      -m URL         retrieve books from mirror at URL
                       (default \"ftp://mirrors.xmission.com/gutenberg\")
      -v             show verbose output (for debugging)
      -h, --help     display this message and exit
    
Report bugs to josh+git@nispio.net
