#!/bin/bash
set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR=`mktemp -d  "/tmp/tmp.XXXXXXXXXX"`
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi
function cleanup {      
  echo "I want to delete ${WORK_DIR}. It was populated with data from docker as root so I will need your sudo permissions."
  sudo rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}
trap cleanup EXIT


docker run --rm -i -v $WORK_DIR:/output $IMAGE_NAME sh /opt/resource/out /output <<EOF
{
  "source": {
    "bucket": "ibm-kubecf-ci",
    "bucket_subfolder": "build-queue",
    "aws_access_key_id": "$AWS_KEY_ID",
    "aws_secret_access_key": "$AWS_SECRET_ACCESS_KEY",
    "remote": "HCL-Cloud-Native-Labs/kubecf"
  },
  "params": {
    "commit_path": "/commit_sha",
    "remote": "HCL-Cloud-Native-Labs/kubecf",
    "state": "passed",
    "trigger": "PR"
  }
}
EOF

# TODO: Change to something else
if [ ! -d "${WORK_DIR}/src" ]; then
  echo "repository wasn't checked out"
  exit 1
fi
