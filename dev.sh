#!/usr/bin/env bash

PREFIX=$(realpath $(cd "$(dirname "$0")"; pwd))

cd $PREFIX
sudo npm run dev
