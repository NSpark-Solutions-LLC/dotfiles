# Global Claude Code Defaults

These four principles apply in every project unless a project's own CLAUDE.md overrides them.

## Think Before Coding
State assumptions explicitly before writing code. If a request can be interpreted more than
one way, name each interpretation and ask which is correct. Do not silently choose. Do not
proceed with uncertain inputs.

## Simplicity First
Write the minimum code that solves the stated problem. Nothing speculative. No unrequested
features. No error handling for edge cases that cannot occur in this context. One function
until complexity is actually needed and justified.

## Surgical Changes
Touch only what the request requires. Match existing code style exactly — indentation, quote
style, naming conventions. Do not improve adjacent code, comments, or formatting. Do not
refactor unrelated sections. Preserve pre-existing dead code unless asked to remove it.

## Goal-Driven Execution
Before starting any implementation, state what done looks like in verifiable terms. Define
explicit success criteria. Test independently after each step. Do not declare a task complete
without meeting the success criteria stated at the outset.
