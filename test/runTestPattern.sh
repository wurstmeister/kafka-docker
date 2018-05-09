#!/bin/bash -e

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

# Modified from https://stackoverflow.com/a/4025065
compareVersion() {
    # Only care about major / minor
    LEFT=$(echo "$1" | cut -d. -f1-2)
    RIGHT=$(echo "$2" | cut -d. -f1-2)
    if [[ "$LEFT" != "$RIGHT" ]]
    then
        local IFS=.
        local i ver1=($LEFT) ver2=($RIGHT)
        for ((i=0; i<${#ver1[@]}; i++))
        do
            if (( "${ver1[i]}" > "${ver2[i]}" ))
            then
                echo ">"
                return
            fi
            if (( "${ver1[i]}" < "${ver2[i]}" ))
            then
                echo "<"
                return
            fi
        done
    fi
    echo "="
}

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
      # shellcheck disable=SC1090
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
