#!/bin/bash
# scripts/02-ssh/getJwt.sh
# Retrieves the machine identity JWT token by running ~/.getId() or falls back to a mock/simulated JWT.

set -euo pipefail

# Path to the local identity script
ID_SCRIPT="$HOME/.getId"

if [ -x "$ID_SCRIPT" ]; then
  # Execute the identity script to retrieve the actual JWT
  JWT=$("$ID_SCRIPT")
  if [ -z "$JWT" ]; then
    echo "Error: Identity script $ID_SCRIPT returned an empty JWT." >&2
    exit 1
  fi
  echo "$JWT"
else
  # Fallback: Check if ssh-agent or ssh key is requested or simulate JWT
  # If a mock JWT token is acceptable, we print it to stdout
  # We also print a warning to stderr so the logs reflect that a mock JWT was used.
  echo "Warning: Identity script $ID_SCRIPT not found/executable. Using fallback mock JWT." >&2
  # A realistic looking mock JWT structure: header.payload.signature
  echo "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzc2gtaWRlbnRpdHkiLCJzdWIiOiJtYWNoaW5lLTEyMyIsImV4cCI6OTk5OTk5OTk5OX0.mock_signature_from_ssh_key"
fi
