#!/usr/bin/env python3
"""
Merges a Claude Code settings fragment into a target settings.json.
Idempotent — safe to run multiple times. Used by both the local-machine
install.sh and the GeoHavenOS SessionStart hook.

Usage: python3 merge-settings.py <fragment.json> <target-settings.json>
"""
import json, os, sys


def merge_stop_hooks(existing, fragment):
    existing_hooks = existing.setdefault("hooks", {})
    fragment_hooks = fragment.get("hooks", {})

    if "Stop" not in fragment_hooks:
        return

    existing_stop = existing_hooks.setdefault("Stop", [])
    for fragment_entry in fragment_hooks["Stop"]:
        matcher = fragment_entry.get("matcher", "")
        for fragment_hook in fragment_entry.get("hooks", []):
            cmd = fragment_hook.get("command", "")
            # Skip if this exact command is already present anywhere in Stop hooks
            already_present = any(
                h.get("command") == cmd
                for entry in existing_stop
                for h in entry.get("hooks", [])
            )
            if already_present:
                continue
            # Append to existing entry with same matcher, or create a new entry
            found = False
            for entry in existing_stop:
                if entry.get("matcher", "") == matcher:
                    entry.setdefault("hooks", []).append(fragment_hook)
                    found = True
                    break
            if not found:
                existing_stop.append({"matcher": matcher, "hooks": [fragment_hook]})


def merge_permissions(existing, fragment):
    if "permissions" not in fragment:
        return
    existing_perms = existing.setdefault("permissions", {})
    for key, values in fragment["permissions"].items():
        if isinstance(values, list):
            existing_list = existing_perms.setdefault(key, [])
            for item in values:
                if item not in existing_list:
                    existing_list.append(item)


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <fragment.json> <target-settings.json>")
        sys.exit(1)

    fragment_path = sys.argv[1]
    settings_path = sys.argv[2]

    with open(fragment_path) as f:
        fragment = json.load(f)

    try:
        with open(settings_path) as f:
            existing = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        existing = {}

    merge_stop_hooks(existing, fragment)
    merge_permissions(existing, fragment)

    os.makedirs(os.path.dirname(os.path.abspath(settings_path)), exist_ok=True)
    with open(settings_path, "w") as f:
        json.dump(existing, f, indent=4)
        f.write("\n")

    print(f"Merged into {settings_path}")


if __name__ == "__main__":
    main()
