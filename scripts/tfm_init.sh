#!/bin/bash
WKDIR=$PWD

cd ./modules || exit
for f in *; do
  if [ -d "$f" ]; then
    # cycle through each module dir and initialize
    cd "$f" || exit
    echo -e "\n## Init module $f"
    if ! terraform init -input=false -backend=false; then exit $?; fi
    source "$WKDIR"/scripts/lint.sh
    source "$WKDIR"/scripts/validate.sh
    cd ..
  fi
done
cd ..