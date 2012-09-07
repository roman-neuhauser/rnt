# Copyright (c) Roman Neuhauser
# Distributed under the MIT license (see LICENSE file)
# vim: sw=2 sts=2 ts=2 et

mypath="$(dirname "$0")"
myname="$(basename "$0")"

testdir="${1:?}"; shift
testdir="${testdir#$PWD/}"

test -d "$testdir" && (cd "$testdir") || {
  echo "$myname: not a dir: $testdir"
  exit 1
} >&2

cnt=0
ex=0
failures=

list_tests()
(
  find "${1?}" -mindepth 1 -maxdepth 1 -type d \
  | grep -E '^'"$1/"'[0-9]{3}(-[a-z0-9]+)+$'
)

for d in $(list_tests "${testdir%/}"); do
  cnt=$((cnt + 1))
  "$SHELL" "$mypath/run-test.sh" "$d" ${1+"$@"}
  tex=$?
  if test 0 -eq $tex; then
    printf .
  else
    ex=$tex
    printf F
    failures="$failures $d"
  fi
done

test $cnt -gt 0 && printf "\n\n"

fcnt=0
for f in $failures; do
  fcnt=$(($fcnt + 1))
  printf "FAIL $f\n\n"
  test -f "$f/README" && sed 's,^,# ,' "$f/README" && echo
  find $f -mindepth 1 -maxdepth 1 -name \*.diff | xargs cat
  printf "\n"
done

printf "tests: %d failed: %d\n" $cnt $fcnt
exit $ex
