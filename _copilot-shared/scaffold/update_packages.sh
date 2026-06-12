#!/bin/bash
# ============================================================================
#  update_packages.sh
#
#  Convenience wrapper to safely upgrade all Python dependencies.
#
#  This script:
#    1. Activates the virtual environment (if not already active)
#    2. Runs scripts/update_packages.py, which:
#       - Recompiles requirements.in and requirements-dev.in with --upgrade
#       - Shows what changed
#       - Asks for confirmation
#       - Installs the new versions
#       - Runs sanity.sh to verify nothing broke
#
#  Security: Upgrading dependencies protects against known vulnerabilities.
#  Always run the test suite after upgrading to catch breaking changes.
#
# ============================================================================

set -e

# Move to the project root
cd "$(dirname "$0")"

# Activate the venv if it's not already active
if [[ -z "$VIRTUAL_ENV" ]]; then
    if [[ -f ".venv/bin/activate" ]]; then
        echo "[INFO] Activating virtual environment..."
        source .venv/bin/activate
    else
        echo ""
        echo "[ERROR] No .venv folder found."
        echo ""
        echo "Create one with:"
        echo "  python3 -m venv .venv"
        echo "  source .venv/bin/activate"
        echo "  pip install -r requirements.txt"
        echo ""
        exit 1
    fi
fi

# Run the upgrade orchestrator
python scripts/update_packages.py
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo ""
    echo "[ERROR] Upgrade failed. See output above for details."
    echo ""
    exit 1
fi

exit 0
