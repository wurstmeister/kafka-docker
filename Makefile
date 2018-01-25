# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

.PHONY: build
ARCH ?= amd64
QEMUVERSION=v2.9.1
TEMP_DIR:=$(shell mktemp -d)
BUILD_IMAGE ?= wurstmeister/kafka-docker:1.0.0

ifeq ($(ARCH),amd64)
        BASEIMAGE?=anapsix/alpine-java
endif
ifeq ($(ARCH),ppc64le)
	BASEIMAGE?=openjdk:jdk-alpine
        QEMUARCH=ppc64le
        BUILD_IMAGE = wurstmeister/kafka-docker-$(ARCH):1.0.0
endif

build: 

ifeq ($(ARCH),amd64)
	cp ./* $(TEMP_DIR)
	cat Dockerfile.crossbuild \
                | sed "s|BASEIMAGE|$(BASEIMAGE)|g" \
                | sed "/CROSS_BUILD_COPY/d" \
                > $(TEMP_DIR)/Dockerfile.crossbuild
	# We just build it using the usual process.
	docker build -t $(BUILD_IMAGE) -f $(TEMP_DIR)/Dockerfile.crossbuild $(TEMP_DIR)
	rm -rf $(TEMP_DIR)

else
	cp ./* $(TEMP_DIR)
	cat Dockerfile.crossbuild \
 	        | sed "s|BASEIMAGE|$(BASEIMAGE)|g" \
                | sed "s|ARCH|$(QEMUARCH)|g" \
                > $(TEMP_DIR)/Dockerfile.crossbuild
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	curl -sSL https://github.com/multiarch/qemu-user-static/releases/download/$(QEMUVERSION)/x86_64_qemu-$(QEMUARCH)-static.tar.gz | tar -xz -C $(TEMP_DIR)
	sed "s/CROSS_BUILD_//g" $(TEMP_DIR)/Dockerfile.crossbuild > $(TEMP_DIR)/Dockerfile.crossbuild.tmp
	mv $(TEMP_DIR)/Dockerfile.crossbuild.tmp $(TEMP_DIR)/Dockerfile.crossbuild
	docker build -t $(BUILD_IMAGE) -f $(TEMP_DIR)/Dockerfile.crossbuild $(TEMP_DIR)
	rm -rf $(TEMP_DIR)
 
endif
