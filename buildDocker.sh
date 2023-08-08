#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

 docker build --pull --rm -f "DockerfileHub" -t minifab:latest "."
 # docker build --pull --rm -f "Dockerfile" -t foodtrack:latest "."
