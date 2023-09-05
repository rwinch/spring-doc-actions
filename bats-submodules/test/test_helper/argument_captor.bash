__get_capture_path() {
  if [ -z "$BATS_TEMP_DIR" ]; then
    echo "Ensure to set \$BATS_TEMP_DIR"
    exit 1
  fi
  local program="$1"
  if [ -z "$program" ]; then
    echo "Missing argument: program"
    exit 1
  fi
  echo "${BATS_TEMP_DIR}/${program}-args"
}


capture_program_args() {
  local path=$(__get_capture_path "$1")
  echo "echo \${@} > $path"
}

get_program_args() {
  local path="$(__get_capture_path "$1")"
  echo "$(cat ${path})"
}

assert_program_args() {
  local args="$(get_program_args $1)"
  assert [ "$args" = "$2" ]
}