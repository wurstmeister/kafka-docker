#!/bin/bash -e

source version.functions

PATTERN=$1
VERSION=$KAFKA_VERSION

# Allow version to be overridden by -v/--version flag
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -v|--version)
      VERSION="$2";
      shift
      ;;
    *)
      PATTERN="$1"
      ;;
  esac
  shift
done

echo ""
echo ""
echo "Running tests for Kafka $VERSION with pattern $PATTERN"

runPattern() {
  for t in $PATTERN; do
    echo
    echo "===================================="

    # only run tests compatible with this version of Kafka
    TARGET=$(echo "$t" | cut -d/ -f1)
    RESULT=$(compareVersion "$VERSION" "$TARGET")
    echo "Kafka $VERSION is '$RESULT' target $TARGET of test $t"
    if [[ "$RESULT" != "<" ]]; then
      echo "  testing '$t'"
      ( source "$t" )
      status=$?
      if [[ -z "$status" || ! "$status" -eq 0 ]]; then
        return $status
      fi
    fi
  done

  return $?
}

runPattern

exit $?
