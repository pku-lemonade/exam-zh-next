#!/usr/bin/env bash
# Build the folder to submit to typst/packages, then test it the way users
# get it: the bundle (submission minus `exclude`) as `@preview/<name>:<version>`,
# `typst init` from the template, and the README's examples.
#
#   scripts/package.sh [--font-path DIR]
#
# Output: out/submit/<name>/<version> (copy it to packages/preview/ in a
# checkout of typst/packages) and out/release/{guide,reference}.pdf (attach
# them to the GitHub release; the README links to them).
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
font_args=()
if [ "${1:-}" = "--font-path" ]; then font_args=(--font-path "$2"); fi

read -r name version repository < <(python3 -I -c '
import sys, tomllib
p = tomllib.load(open(sys.argv[1], "rb"))["package"]
print(p["name"], p["version"], p["repository"])' "$root/typst.toml")

submit="$root/out/submit/$name/$version"
cache="$root/out/cache"
bundle="$cache/preview/$name/$version"
project="$root/out/init-test"
rm -rf -- "$submit" "$cache" "$project"
mkdir -p "$submit" "$bundle"

# The submission holds the package and the files its README links to; the
# examples, tests, scripts and doc sources stay in the repository (the README
# links to them at the release tag). Only files git tracks or would track.
git -C "$root" ls-files --cached --others --exclude-standard | python3 -I -c '
import re, sys
readme = open(sys.argv[1]).read()
linked = {m for m in re.findall(r"\]\(([^)#]+)\)", readme) if "://" not in m}
dev = ("examples/", "tests/", "scripts/", "docs/", ".gitignore")
for path in sys.stdin.read().split("\n"):
    if path and (not path.startswith(dev) or path in linked):
        print(path)
missing = [m for m in linked if not __import__("os").path.exists(m)]
assert not missing, f"README links to missing files: {missing}"
repo = re.escape(sys.argv[2])
stale = [u for u in re.findall(repo + r"/(?:blob|tree|releases/download)/([^/)]+)", readme) if u != "v" + sys.argv[3]]
assert not stale, f"README links to {stale} instead of the tag v{sys.argv[3]}"
' "$root/README.md" "$repository" "$version" | (cd "$root" && xargs -d '\n' cp --parents -t "$submit")

# The bundle drops `exclude` (anchored top-level paths) and the thumbnail.
cp -r "$submit/." "$bundle"
python3 -I -c '
import sys, tomllib
m = tomllib.load(open(sys.argv[1], "rb"))
for glob in m["package"].get("exclude", []):
    assert glob.startswith("/") and "*" not in glob, f"unsupported exclude glob: {glob}"
    print(glob[1:])
print(m["template"]["thumbnail"])' "$root/typst.toml" | while read -r path; do rm -rf -- "${bundle:?}/$path"; done

if grep -rn --include='*.typ' '"\.\./\|"/src/' "$bundle"; then
    echo "the bundle imports files outside the package" >&2; exit 1
fi

check() {
    local log
    if ! log=$("$@" 2>&1) || grep -q '^warning' <<<"$log"; then echo "FAIL  ${*: -2}"; echo "$log"; exit 1; fi
}
typst init --package-cache-path "$cache" "@preview/$name:$version" "$project" >/dev/null 2>&1
check typst compile --package-cache-path "$cache" "${font_args[@]}" "$project/main.typ" "$project/main.pdf"
check typst compile --package-cache-path "$cache" "${font_args[@]}" --input exam-mode=teacher "$project/main.typ" "$project/main-teacher.pdf"
echo "ok    typst init + compile (student and teacher)"

# Every ```typ block of the README must compile against the bundle; blocks
# without an import get the first block's import (and `exam` if they lack it).
python3 -I -c '
import re, sys
blocks = re.findall(r"```typ\n(.*?)```", open(sys.argv[1]).read(), re.S)
imp = next(l for l in blocks[0].splitlines() if l.startswith("#import"))
for i, b in enumerate(blocks):
    if "#import" not in b:
        b = imp + "\n" + ("" if "#show: exam" in b else "#show: exam\n") + b
    open(f"{sys.argv[2]}/readme-{i}.typ", "w").write(b)' "$root/README.md" "$project"
for src in "$project"/readme-*.typ; do
    check typst compile --package-cache-path "$cache" "${font_args[@]}" "$src" "${src%.typ}.pdf"
done
echo "ok    README examples"

mkdir -p "$root/out/release"
for doc in guide reference; do
    check typst compile --root "$root" "${font_args[@]}" "$root/docs/$doc.typ" "$root/out/release/$doc.pdf"
done
echo "ok    out/release/guide.pdf, out/release/reference.pdf"

du -sh "$submit" "$bundle" "$root/out/release" | sed "s|$root/||"
