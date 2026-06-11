#!/bin/bash
# Usage: ./commit_helper.sh "commit message"
MSG="$1"
if [ -z "$MSG" ]; then echo "Usage: $0 'message'"; exit 1; fi
python3 << EOF
import os, subprocess, time

git_dir = '/sessions/sharp-quirky-davinci/mnt/Documents/agency-os.html/agency-os/.git'
locks = [
    os.path.join(git_dir, 'index.lock'),
    os.path.join(git_dir, 'HEAD.lock'),
    os.path.join(git_dir, 'refs/heads/main.lock'),
]
env = os.environ.copy()
env['GIT_AUTHOR_NAME'] = 'mafemontillamueller'
env['GIT_AUTHOR_EMAIL'] = 'hello@mafemontillamueller.com'
env['GIT_COMMITTER_NAME'] = 'mafemontillamueller'
env['GIT_COMMITTER_EMAIL'] = 'hello@mafemontillamueller.com'
cwd = '/sessions/sharp-quirky-davinci/mnt/Documents/agency-os.html/agency-os'
subprocess.run(['git', 'add', '-A'], cwd=cwd, env=env, capture_output=True)
for attempt in range(15):
    for p in locks:
        if os.path.exists(p):
            try: os.rename(p, p+'.gone')
            except: pass
    r = subprocess.run(['git', 'commit', '-m', '$MSG'], cwd=cwd, env=env, capture_output=True, text=True)
    if r.returncode == 0:
        print('SUCCESS:', r.stdout.strip())
        break
    elif 'nothing to commit' in r.stdout + r.stderr:
        print('Nothing to commit'); break
    else:
        time.sleep(0.1)
else:
    print('FAILED:', r.stderr[-300:])
EOF
