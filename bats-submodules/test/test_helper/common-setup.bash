#!/usr/bin/env bash

BATS_TEMP_DIR="/tmp/bats-$(uuidgen)"

_common_setup() {
  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  # make executables in src/ visible to PATH
  PATH="$DIR/../src:$PATH"
  load 'test_helper/bats-support/load' # this is required by bats-assert!
  load 'test_helper/bats-assert/load'
  load 'helpers/mocks/stub'
  load 'test_helper/argument_captor'
  mkdir -p $BATS_TEMP_DIR
}

_common_teardown() {
   rm -rf $BATS_TEMP_DIR
}
