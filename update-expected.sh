#!/bin/sh

### HELP START # {{{
# usage: $0 <path>...
#
# each argument is one of:
# * an *.actual, or an *.expected, or a *.diff file path
#   - this will update the corresponding *.expected file
#     from its *.actual file
# * a test directory path
#   - this will update all *.expected files in the directory
#     from their corresponding *.actual files
### HELP END # }}}

print_section() # {{{
{
  local -r s="${1?}" self=${0##*/}
  sed -rnf - ${0} <<EOSED
    /^### $s START/,/^### $s END/ {
      s:\\\$0:$self:
      s:^#( |$)::p
    }
EOSED
} # }}}

if [ $# -eq 0 ] || [ "x$1" = x--help ] || [ "x$1" = x-h ]; then
  print_section HELP
  exit
fi

for arg in "$@"; do
  case "$arg" in
  *.actual|*.expected|*.diff)
    a="${arg%.*}.actual"
    e="${arg%.*}.expected"
    ;;
  *)
    find "$arg" -mindepth 1 -maxdepth 1 -name \*.diff | xargs -n1 "$0"
    continue
    ;;
  esac
  if [ -z "$a" ] || [ -z "$e" ]; then
    kill -ABRT $$
  fi
  cp "$a" "$e"
done
