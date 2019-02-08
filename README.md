# Simple tool to "fix" zenodo.json

Figuring out the creators of a package should be easy, but the contributor list is
possibly large.
This simple tool verifies .zenodo.json and the git log for contributors, and adds them.
It also tries to guess the license.

This script is written in Julia, and tested with Julia 1.1.
