#!/bin/bash

# Declare an array of project paths
PROJECT_PATHS=(
#  "/home/ubuntu/code/github/raviautopilot/rWork/shared/twin-db"
#  "/home/ubuntu/code/github/raviautopilot/rWork/shared/digi-twin"
#  "/home/ubuntu/code/github/raviautopilot/rWork/services/rutils"
#  "/home/ubuntu/code/github/raviautopilot/rWork/services/rtwin"
#  "/home/ubuntu/code/github/raviautopilot/rWork/services/rconfig"
#  "/home/ubuntu/code/github/raviautopilot/rWork/services/rcore"
#  "/home/ubuntu/code/github/raviasutopilot/rWork/services/rtest"
#  "/home/ubuntu/code/github/raviautopilot/rWork/shared/rdocker"
  "/home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh"
)

# Loop through each project path
for project_path in "${PROJECT_PATHS[@]}"; do
  echo "Processing project: $project_path"

  # Copy the graphify scripts
  cp "/home/ubuntu/code/github/raviautopilot/rWork/scripts/lib/graphify/graphify-setup.sh" "$project_path/"
  cp "/home/ubuntu/code/github/raviautopilot/rWork/scripts/lib/graphify/query-graphify.sh" "$project_path/"
  cp "/home/ubuntu/code/github/raviautopilot/rWork/scripts/lib/project/.gitignore" "$project_path/.gitignore"

  # Add execute permissions
  chmod +x "$project_path/graphify-setup.sh"
  chmod +x "$project_path/query-graphify.sh"

  # Update .gitignore
  if [ -f "$project_path/.gitignore" ]; then
    if ! grep -q "graphify-out/" "$project_path/.gitignore"; then
      echo "graphify-out/" >> "$project_path/.gitignore"
    fi
  else
    echo "graphify-out/" > "$project_path/.gitignore"
  fi

  # Copy, execute, and remove the remove-graphify.sh script
  echo "Running remove-graphify.sh in $project_path"
  cp "/home/ubuntu/code/github/raviautopilot/rWork/scripts/lib/graphify/remove-graphify.sh" "$project_path/"
  chmod +x "$project_path/remove-graphify.sh"
  (cd "$project_path" && ./remove-graphify.sh)
  rm "$project_path/remove-graphify.sh"

done

echo "Graphify setup complete."