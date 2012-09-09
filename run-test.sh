# Copyright (c) Roman Neuhauser
# Distributed under the MIT license (see LICENSE file)
# vim: sw=2 sts=2 ts=2 et

expected()
{
  find "${1?}" -mindepth 1 -maxdepth 1 -name \*.expected | sort
}

myname="$(basename "$0")"

curdir="${PWD%/}"
testdir="$1"; shift
testdir="${testdir#$PWD/}"

test -d "$testdir" && cd "$testdir" || {
  echo "$myname: not a dir: $testdir"
  exit 1
} >&2

rm -f err.actual out.actual exit.actual
test -f ./cmd || {
  echo "$myname $testdir: missing $testdir/cmd"
  exit 2
} >&2
$SHELL ./cmd ${1+"$@"} >out.actual 2>err.actual
echo $? > exit.actual
cd "$curdir"
ex=0
for exp in $(expected "$testdir"); do
  act="${exp%.expected}.actual"
  diff="${exp%.expected}.diff"
  diff -Nu --strip-trailing-cr "$exp" "$act" > "$diff.tmp"
  dex=$?
  sed '1,2s/\t.*$//' < "$diff.tmp" > "$diff"
  rm -f "$diff.tmp"
  if test 0 -ne $dex; then
    ex=$dex
  else
    rm -f "$diff"
  fi
done

if test 0 -eq $ex; then
  cd "$testdir" && rm -f err.actual out.actual exit.actual
fi

exit $ex
