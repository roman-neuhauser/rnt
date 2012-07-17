# Copyright (c) Roman Neuhauser
# Distributed under the MIT license (see LICENSE file)
# vim: sw=2 sts=2 ts=2 et

mypath="${0%/*}"

testdir="${1:?}"; shift

cnt=0
ex=0
failures=

for d in "$testdir"/???-*; do
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

printf "\n\n"

fcnt=0
for f in $failures; do
  fcnt=$(($fcnt + 1))
  printf "FAIL $f\n\n"
  find $f -name \*.diff | xargs cat
  printf "\n"
done

printf "tests: %d failed: %d\n" $cnt $fcnt
exit $ex
