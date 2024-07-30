#!/usr/bin/bash
# todo: fix retrieve_existing_filename, compare against installed pacman packages for percentage, add xdg-ninja as dep, make aur pkg, complete readme
FIXABLE=0
UNFIXABLE=0

apply_shell_expansion() {
    data="$1"
    delimiter="__apply_shell_expansion_delimiter__"
    command=$(printf "cat <<%s\n%s\n%s" "$delimiter" "$data" "$delimiter")
    eval "$command"
}

has_pattern() {
    case $1 in
    *\** | *\?* | *\[*\]*)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

retrieve_existing_filename() {
    FILE_PATH=$(apply_shell_expansion "$1")

    # return filename if found, nothing else
    if has_pattern "$FILE_PATH"; then
        dir="$(dirname "$FILE_PATH")"
        part="$(basename "$FILE_PATH")"
        find "$dir" -maxdepth 1 -name "$part" -print -quit 2>/dev/null
    else
        if [ -e "$FILE_PATH" ]; then
            printf "%s" "$FILE_PATH"
        fi
    fi
}

check_file() {
    NAME="$1"
    FILENAME="$2"
    MOVABLE="$3"
    HELP="$4"

    file=$(retrieve_existing_filename "$FILENAME")

    if [ "$file" ]; then
        if [ "$MOVABLE" = true ]; then
            FIXABLE=$((FIXABLE+1))
        else
            UNFIXABLE=$((UNFIXABLE+1))
    fi
}

[ "$XN_PROGRAMS_DIR" ] ||
    XN_PROGRAMS_DIR="$(realpath "$0" | xargs dirname | sed 's:/bin$:/share/xdg-ninja:g')/programs"

while IFS="
" read -r name; read -r filename; read -r movable; read -r help; do
    check_file "$name" "$filename" "$movable" "$help"
done <<EOF
$(jq '.files[] as $file | .name, $file.path, $file.movable, $file.help' "$XN_PROGRAMS_DIR"/* | sed -e 's/^"//' -e 's/"$//')
EOF

printf "$FIXABLE fixable programs found, $UNFIXABLE unfixable programs found.\nYour system has $(($FIXABLE + $UNFIXABLE)) pacakged that do not conform the to the XDG Base Directory Specification
