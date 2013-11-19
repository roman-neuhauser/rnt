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
fcnt=0
trap 'rm -f $faillog' EXIT
faillog=$(mktemp)

list_tests()
(
  find "${1?}" -mindepth 1 -maxdepth 1 -type d \
  | grep -E '^'"$1/"'[0-9]{3}(-[a-z0-9]+)+$' \
  | sort -n
)

for d in $(list_tests "${testdir%/}"); do
  cnt=$((cnt + 1))
  "$SHELL" "$mypath/run-test.sh" "$d" ${1+"$@"} >> $faillog
  tex=$?
  if test 0 -eq $tex; then
    printf .
  else
    ex=$tex
    printf F
    fcnt=$(($fcnt + 1))
  fi
done

test $cnt -gt 0 && printf "\n\n"

cat "$faillog"

printf "tests: %d failed: %d\n" $cnt $fcnt
exit $ex
