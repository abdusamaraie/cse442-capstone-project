#!/bin/bash

python_version=3.6

for i in *.py; do
  if [[ "$i" != "__init__.py" ]]; then
    echo "running tests from file: $i"
    python${python_version} $i
  fi
done