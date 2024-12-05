#!/bin/bash
#https://unix.stackexchange.com/questions/70615/bash-script-echo-output-in-box

function box_out() {
    input_char=$(echo "$@" | wc -c)
    line=$(for i in `seq 0 $input_char`; do printf "-"; done)
    # tput This should be the best option. what tput does is it will
    # read the terminal info and render the correctly escaped ANSI code
    # for you.
    # Code like \033[31m will break the readline library in some of the
    # terminals.
    tput bold
    line="$(tput setaf 3)${line}"
    space=${line//-/ }
    echo " ${line}"
    printf '|' ; echo -n "$space" ; printf "%s\n" '|';
    printf '| ' ;tput setaf 4; echo -n "$@"; tput setaf 3 ; printf "%s\n" ' |';
    printf '|' ; echo -n "$space" ; printf "%s\n" '|';
    echo " ${line}"
    tput sgr 0
}

box_out $@
