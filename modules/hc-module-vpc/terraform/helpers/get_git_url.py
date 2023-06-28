"""
Get current folder git repo URL, if not a git repo, empty string repo_url is return.
Outputs a json map with {'git_url': repo_url}.
Expects to find git command in the PATH.
"""
import json
import subprocess


with subprocess.Popen(['git', 'remote', '-v', 'get-url', 'origin'],
                      stdout=subprocess.PIPE, stderr=subprocess.PIPE) as proc:
    STDOUT, STDERR = proc.communicate()
    OUTPUT = {'git_url': STDOUT.decode('utf-8').strip()}
    print(json.dumps(OUTPUT))
