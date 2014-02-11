#!/bin/sh

# each argument is one of:
# * an *.actual, or an *.expected, or a *.diff file path
#   - this will update the corresponding *.expected file into
#     from its *.actual file
# * a test directory path
#   - this will update all *.expected files under the directory
#     from their *.actual ones

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
