# Copyright (c) Roman Neuhauser
# Distributed under the MIT license (see LICENSE file)
# vim: sw=2 sts=2 ts=2 et

children()
{
  find "${1?}" -mindepth 1 -maxdepth 1 -name "${2?}" | sort
}
outputs()
{
  local testdir="${1?}"
  {
    children "$testdir" \*.expected | sed 's#expected$#actual#'
    children "$testdir" \*.actual
  } | sort -u
}

myname="$(basename "$0")"

curdir="${PWD%/}"
testdir="$1"; shift
testdir="${testdir#$PWD/}"

test -d "$testdir" && cd "$testdir" || {
  echo "$myname: not a dir: $testdir"
  exit 1
} >&2

test -f ./cmd || {
  echo "$myname $testdir: missing $testdir/cmd"
  exit 2
} >&2

rm -f $(children . \*.actual)
rm -f $(children . \*.diff)

$SHELL ./cmd ${1+"$@"} >out.actual 2>err.actual
echo $? > exit.actual
test -f ./post && {
  $SHELL ./post ${1+"$@"} >post.actual 2>&1
}
cd "$curdir"
diffs=
ex=0
tab="$(printf '\t')"
for act in $(outputs "$testdir"); do
  exp="${act%.actual}.expected"
  diff="${act%.actual}.diff"
  diff -Nu --strip-trailing-cr "$exp" "$act" > "$diff.tmp"
  dex=$?
  ex=$(($ex + $dex))
  if test 0 -ne $dex; then
    sed '1,2s/'"$tab"'.*$//' < "$diff.tmp" > "$diff"
    diffs="$diffs $diff"
  fi
  rm -f "$diff.tmp"
done

test $ex -eq 0 && test -n "$diffs" && kill -ABRT $$
test $ex -ne 0 && test -z "$diffs" && kill -ABRT $$

if test 0 -eq $ex; then
  rm -f $(children "$testdir" \*.actual)
else
  printf "FAIL $testdir\n\n"
  test -f "$testdir/README" && sed 's,^,# ,' "$testdir/README" && echo
  children $testdir \*.diff | xargs cat
  printf "\n"
fi

exit $ex
