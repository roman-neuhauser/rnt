# Copyright (c) Roman Neuhauser
# Distributed under the MIT license (see LICENSE file)
# vim: sw=2 sts=2 ts=2 et

curdir="$PWD"
testdir="$1"; shift
cd "$testdir" || exit 1
rm -f err.actual out.actual exit.actual
test -f ./cmd || {
  echo "$0 $testdir: missing $testdir/cmd"
  exit 2
} >&2
$SHELL ./cmd ${1+"$@"} >out.actual 2>err.actual
echo $? > exit.actual
cd "$curdir"
ex=0
for exp in $(find "$testdir" -name \*.expected | sort); do
  act="${exp%.expected}.actual"
  diff="${exp%.expected}.diff"
  diff -Nu --strip-trailing-cr "$exp" "$act" > "$diff"
  dex=$?
  if test 0 -ne $dex; then
    ex=$dex
  else
    rm -f "$diff"
  fi
done
exit $ex
