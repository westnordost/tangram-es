#!/bin/bash -eo pipefail
# USAGE
#   run_tests.sh [test_build_dir]
#
test_dir="build/tests/tests"
if [[ $1 ]]; then
    test_dir=$1
fi
echo "Running unit tests from: ${test_dir}"
pushd ${test_dir}
./allTests
popd
