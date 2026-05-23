#!/usr/bin/env node
/**
 * merge-settings.js — Node.js equivalent of merge-settings.py
 * Merges a Claude Code settings fragment into a target settings.json.
 * Idempotent — safe to run multiple times.
 *
 * Usage: node merge-settings.js <fragment.json> <target-settings.json>
 */
const fs = require('fs');
const path = require('path');

const [, , fragmentPath, settingsPath] = process.argv;
if (!fragmentPath || !settingsPath) {
  console.error(`Usage: node merge-settings.js <fragment.json> <target-settings.json>`);
  process.exit(1);
}

const fragment = JSON.parse(fs.readFileSync(fragmentPath, 'utf8'));

let existing = {};
try {
  existing = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
} catch (_) {
  // File missing or invalid JSON — start fresh
}

// Merge Stop hooks
if (fragment.hooks?.Stop) {
  if (!existing.hooks) existing.hooks = {};
  if (!existing.hooks.Stop) existing.hooks.Stop = [];
  const existingStop = existing.hooks.Stop;

  for (const fragEntry of fragment.hooks.Stop) {
    const matcher = fragEntry.matcher ?? '';
    for (const hook of fragEntry.hooks ?? []) {
      const cmd = hook.command;
      const alreadyPresent = existingStop.some(e =>
        (e.hooks ?? []).some(h => h.command === cmd)
      );
      if (alreadyPresent) continue;

      const target = existingStop.find(e => (e.matcher ?? '') === matcher);
      if (target) {
        target.hooks = target.hooks ?? [];
        target.hooks.push(hook);
      } else {
        existingStop.push({ matcher, hooks: [hook] });
      }
    }
  }
}

// Merge permissions.allow
if (fragment.permissions?.allow) {
  if (!existing.permissions) existing.permissions = {};
  if (!existing.permissions.allow) existing.permissions.allow = [];
  for (const item of fragment.permissions.allow) {
    if (!existing.permissions.allow.includes(item)) {
      existing.permissions.allow.push(item);
    }
  }
}

fs.mkdirSync(path.dirname(path.resolve(settingsPath)), { recursive: true });
fs.writeFileSync(settingsPath, JSON.stringify(existing, null, 4) + '\n');
console.log(`Merged into ${settingsPath}`);
