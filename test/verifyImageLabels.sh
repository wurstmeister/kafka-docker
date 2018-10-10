#!/bin/bash -e

VCS_REF=$(docker inspect -f '{{ index .Config.Labels "org.label-schema.vcs-ref"}}' wurstmeister/kafka)
echo "VCS_REF=$VCS_REF"
if [ -z "$VCS_REF" ] || [ "$VCS_REF" = "unspecified" ]; then
  echo "org.label-schema.vcs-ref is empty or unspecified"
  exit 1
fi
if ! git cat-file -e "$VCS_REF^{commit}"; then
  echo "$VCS_REF Not a valid git commit"
  exit 1
fi

BUILD_DATE=$(docker inspect -f '{{ index .Config.Labels "org.label-schema.build-date"}}' wurstmeister/kafka)
echo "BUILD_DATE=$BUILD_DATE"
if ! date -d "$BUILD_DATE"; then
  echo "$BUILD_DATE Not a valid date"
  exit 1
fi
exit 0
