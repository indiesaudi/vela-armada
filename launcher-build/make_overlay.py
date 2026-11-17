"""Packs the launcher-games test build: only the plugin files that differ from the base Vela release, with install.sh.

    cd plugin && pnpm install && pnpm build && cd .. && python launcher-build/make_overlay.py

Writes launcher-build/out/vela-launcher-games-<base>.tar.gz and its sha256. MANIFEST lines: <md5 in the base release>
<md5 in this build> <path>; "new" = the base has no such file, "-" = not compared (the built panel bundle)."""
import hashlib
import io
import os
import subprocess
import sys
import tarfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
BASE_REF = sys.argv[1] if len(sys.argv) > 1 else "origin/main"   # the commit of the base release
BASE_VERSION = "0.8.22"
NAME = f"vela-launcher-games-{BASE_VERSION}"
RUNTIME = ("plugin/main.py", "plugin/py_modules/")              # what the installed plugin runs
BUILT = "plugin/dist/index.js"


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, check=True).stdout


def md5(data):
    return hashlib.md5(data).hexdigest()


def main():
    changed = [p for p in git("diff", "--name-only", BASE_REF, "HEAD", "--", *RUNTIME).decode().split() if p.endswith(".py")]
    if not os.path.isfile(os.path.join(REPO, BUILT)):
        raise SystemExit(f"{BUILT} is missing: run pnpm build in plugin/ first")
    if b"Game folder: " not in open(os.path.join(REPO, BUILT), "rb").read():
        raise SystemExit(f"{BUILT} was not built from this branch (its launcher-game texts are missing): run pnpm build")
    dirty = git("status", "--porcelain", "--", *RUNTIME, "plugin/src").decode().strip()
    if dirty:
        raise SystemExit("uncommitted changes in the plugin: commit them first\n" + dirty)
    entries, manifest = [], []
    for path in sorted(changed) + [BUILT]:
        rel = path[len("plugin/"):]
        data = open(os.path.join(REPO, path), "rb").read()
        if path == BUILT:
            base = "-"
        else:
            had = subprocess.run(["git", "-C", REPO, "show", f"{BASE_REF}:{path}"], capture_output=True)
            base = md5(had.stdout) if had.returncode == 0 else "new"
        manifest.append(f"{base} {md5(data)} {rel}")
        entries.append((f"files/{rel}", data, 0o644))
    for script in ("install.sh", "uninstall.sh"):
        entries.append((script, open(os.path.join(HERE, script), "rb").read(), 0o755))
    entries.append(("MANIFEST", ("\n".join(manifest) + "\n").encode(), 0o644))
    head = git("rev-parse", "HEAD").decode().strip()
    entries.append(("SOURCE", f"base: Vela {BASE_VERSION} ({git('rev-parse', BASE_REF).decode().strip()})\nbuilt from: {head}\n".encode(), 0o644))
    os.makedirs(os.path.join(HERE, "out"), exist_ok=True)
    target = os.path.join(HERE, "out", NAME + ".tar.gz")
    with tarfile.open(target, "w:gz") as tar:
        for name, data, mode in entries:
            info = tarfile.TarInfo(f"vela-launcher-games/{name}")
            info.size, info.mode, info.mtime = len(data), mode, 0
            tar.addfile(info, io.BytesIO(data))
    digest = hashlib.sha256(open(target, "rb").read()).hexdigest()
    with open(target + ".sha256", "w") as f:
        f.write(f"{digest}  {NAME}.tar.gz\n")
    print(f"{target} ({os.path.getsize(target)} bytes, sha256 {digest})")
    print("\n".join(manifest))


if __name__ == "__main__":
    main()
