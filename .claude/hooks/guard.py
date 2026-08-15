#!/usr/bin/env python3
"""Garde-fou PreToolUse pour l'outil Bash — bloque avant exécution,
indépendamment du mode de permission (actif même en bypassPermissions).

Règles bloquées :
- git commit / git push, sous quelque forme que ce soit
- git reset --hard (efface du travail non commité, irréversible)
- git clean (supprime des fichiers non trackés, irréversible)
- rm -rf (ou équivalent -r -f, --recursive --force, flags combinés) sur
  un chemin hors des zones explicitement autorisées

Voir docs/product/decisions-log.md et la mémoire Claude de ce projet pour
le contexte de cette décision (2026-08-14, à la demande de Gaelle après
le passage en bypassPermissions).
"""

import json
import os
import re
import shlex
import sys

PROJECT_DIR = "/home/yuki/projects/app-carnet-animaux"

# Zones où un `rm -rf` est légitime et autorisé. Tout le reste est refusé
# par défaut (allowlist, pas denylist — plus sûr pour une opération
# destructive et irréversible).
ALLOWED_RM_PREFIXES = [
    PROJECT_DIR,
    os.path.expanduser("~/.gradle/caches"),
    "/tmp/",
]

CONTROL_TOKENS = {"&&", "||", ";", "|"}


def deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    sys.exit(0)


def check_git(cmd: str) -> None:
    if re.search(r"\bgit\b.*\b(commit|push)\b", cmd):
        deny(
            "git commit/push bloqué par garde-fou : Gaelle gère seule le "
            "commit/push sur ce projet (voir mémoire no-git-commit-push)."
        )
    if re.search(r"\bgit\b.*\breset\b.*--hard\b", cmd):
        deny(
            "git reset --hard bloqué par garde-fou : efface du travail "
            "non commité de façon irréversible."
        )
    if re.search(r"\bgit\b.*\bclean\b", cmd):
        deny(
            "git clean bloqué par garde-fou : supprime des fichiers non "
            "trackés de façon irréversible."
        )


def _resolve(path: str) -> str:
    expanded = os.path.expanduser(path)
    if not os.path.isabs(expanded):
        expanded = os.path.join(PROJECT_DIR, expanded)
    return os.path.normpath(expanded)


def check_rm(cmd: str) -> None:
    try:
        tokens = shlex.split(cmd, posix=True)
    except ValueError:
        # Guillemets mal fermés ou autre commande qu'on ne sait pas
        # tokeniser proprement : mieux vaut refuser que mal analyser une
        # commande destructive.
        if re.search(r"\brm\b", cmd):
            deny(
                "Commande contenant 'rm' non analysable proprement "
                "(quoting), bloquée par précaution."
            )
        return

    i = 0
    while i < len(tokens):
        if tokens[i] == "rm":
            j = i + 1
            args = []
            while j < len(tokens) and tokens[j] not in CONTROL_TOKENS:
                args.append(tokens[j])
                j += 1

            flags = [a for a in args if a.startswith("-") and a != "--"]
            paths = [a for a in args if not a.startswith("-")]
            flag_str = "".join(flags).lower()
            has_recursive = "r" in flag_str or "--recursive" in flags
            has_force = "f" in flag_str or "--force" in flags

            if has_recursive and has_force:
                if not paths:
                    deny(
                        "rm -rf sans chemin explicite bloqué par "
                        "garde-fou (trop risqué à analyser en confiance)."
                    )
                for raw_path in paths:
                    resolved = _resolve(raw_path)
                    allowed = any(
                        resolved == prefix.rstrip("/")
                        or resolved.startswith(prefix.rstrip("/") + "/")
                        for prefix in ALLOWED_RM_PREFIXES
                    )
                    if not allowed:
                        deny(
                            f"rm -rf sur '{resolved}' bloqué par garde-fou : "
                            "hors des zones autorisées "
                            f"({', '.join(ALLOWED_RM_PREFIXES)})."
                        )
            i = j
        else:
            i += 1


def main() -> None:
    data = json.load(sys.stdin)
    cmd = data.get("tool_input", {}).get("command", "")
    check_git(cmd)
    check_rm(cmd)


if __name__ == "__main__":
    main()
