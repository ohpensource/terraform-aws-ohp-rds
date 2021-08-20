#!/bin/bash
git config --global user.email "${AUTOMATION_EMAIL}"
git config --global user.name "${AUTOMATION_USER}"
export ACCESS_TOKEN=$(curl -s -X POST -u "${AUTOMATION_CLIENT_ID}:${AUTOMATION_CLIENT_SECRET}" https://bitbucket.org/site/oauth2/access_token -d grant_type=client_credentials -d scopes="repository"| jq --raw-output '.access_token')
git remote set-url origin "https://x-token-auth:${ACCESS_TOKEN}@bitbucket.org/${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}"

# Install Terraform-docs if not installed
TFM_DOCS_VER="0.13.0"
MOD_DIR="modules"

if ! command -v terraform-docs >/dev/null 2>&1; then
  echo -e "\n ## Installing terraform-docs"
  curl -Lo ./terraform-docs.tar.gz "https://github.com/terraform-docs/terraform-docs/releases/download/v${TFM_DOCS_VER}/terraform-docs-v${TFM_DOCS_VER}-linux-amd64.tar.gz"
  tar -xzf terraform-docs.tar.gz 
  chmod +x terraform-docs 
  mv terraform-docs /usr/local/bin/terraform-docs
fi

# Create docs for each module
if [ -d "$MOD_DIR" ]; then
  for f in $(ls -d ./$MOD_DIR/*); do
      # cycle through each module dir and create docs
      echo -e "\n ## Creating terraform docs for module $f"
      terraform-docs markdown table "./$f" --sort-by required --output-file README.md 
      git add "./$f/README.md"
  done
else
  echo -e "\n ## Creating terraform docs for root module"
  terraform-docs markdown table . --sort-by required --output-file  README.md
fi  

node ./scripts/generate-version-and-release-notes.js