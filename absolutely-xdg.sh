#!/usr/bin/bash
# todo: fix retrieve_existing_filename, compare against installed pacman packages for percentage, add xdg-ninja as dep, make aur pkg, complete readme
# Reads files from programs/, calls check_file on each file specified for each program
do_check_programs() {
    while IFS="
" read -r name; read -r filename; read -r movable; read -r help; do
        check_file "$name" "$filename" "$movable" "$help"
    done <<EOF
$(jq '.files[] as $file | .name, $file.path, $file.movable, $file.help' "$XN_PROGRAMS_DIR"/* | sed -e 's/^"//' -e 's/"$//')
EOF
# sed is to trim quotes
}

check_programs() {
    NAME="$1"
    FILENAME="$2"
    MOVABLE="$3"
    HELP="$4"

    file=$(retrieve_existing_filename "$FILENAME")

    FIXABLE=0
    UNFIXABLE=0
    if [ "$file" ]; then
        if [ "$MOVABLE" = true ]; then
            FIXABLE=$((FIXABLE+1))
        else
            UNFIXABLE=$((UNFIXABLE+1))
    fi

    printf "$FIXABLE fixable programs found, $UNFIXABLE unfixable programs found.\nYour system has $(($FIXABLE + $UNFIXABLE)) pacakged that do not conform the to the XDG Base Directory Specification
}

[ "$XN_PROGRAMS_DIR" ] ||
    XN_PROGRAMS_DIR="$(realpath "$0" | xargs dirname | sed 's:/bin$:/share/xdg-ninja:g')/programs"

check_programs
