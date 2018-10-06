#!/bin/bash -e

VCS_REF=$(docker inspect -f '{{ index .Config.Labels "org.label-schema.vcs-ref"}}' wurstmeister/kafka)
echo "VCS_REF=$VCS_REF"
if [ -z "$VCS_REF" ] || [ "$VCS_REF" = "unspecified" ]; then
  echo "org.label-schema.vcs-ref is empty or unspecified"
  exit 1
fi
exit 0
