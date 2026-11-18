#!/usr/bin/env python3
"""Notas de QA basadas en cambios posteriores a la última publicación exitosa."""
import json
import os
import re
import subprocess
import urllib.request


def format_notes(subjects):
    changes = []
    for subject in subjects:
        title = re.sub(r'^(?:feat|fix|chore|ci|build|docs|refactor|perf|test|style|revert)(?:\([^)]*\))?!?:\s*', '', subject.strip(), flags=re.I)
        if title:
            title = title[0].upper() + title[1:]
            if title not in changes:
                changes.append(title)
    if not changes:
        return 'Recompilación de la versión de pruebas, sin cambios adicionales en la aplicación.'
    notes = 'Cambios incluidos en esta versión:\n' + '\n'.join('- ' + title for title in changes)
    if len(notes) > 20000:
        raise RuntimeError('Las notas superan 20.000 caracteres; resumir los cambios antes de publicar.')
    return notes


def generate_notes(base, head):
    if not re.fullmatch(r'[a-f0-9]{40}', head) or (base and not re.fullmatch(r'[a-f0-9]{40}', base)):
        raise ValueError('Referencia Git inválida')
    if base:
        subprocess.run(['git', 'merge-base', '--is-ancestor', base, head], check=True)
        revision = [base + '..' + head]
    else:
        revision = ['-1', head]
    output = subprocess.check_output(['git', 'log', '--no-merges', '--reverse', '--format=%s', *revision], text=True, encoding='utf-8')
    return format_notes(output.splitlines())


def main():
    request = urllib.request.Request(
        'https://api.github.com/repos/TuvalSystems/appmovil/actions/workflows/deploy-qa.yml/runs?branch=develop&status=success&per_page=1',
        headers={'Authorization': 'Bearer ' + os.environ['GH_TOKEN'], 'Accept': 'application/vnd.github+json'})
    with urllib.request.urlopen(request, timeout=30) as response:
        runs = json.load(response)['workflow_runs']
    base = runs[0]['head_sha'] if runs else None
    print(generate_notes(base, os.environ['GITHUB_SHA']))


if __name__ == '__main__':
    main()
