#!/usr/bin/env bash

set -eou pipefail

systemctl enable journald2cloudwatch.service
systemctl start journald2cloudwatch.service

