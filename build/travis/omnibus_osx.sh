#!/bin/sh

cd cli/omnibus
export USE_SYSTEM_GECODE=1
sudo apt-get install -qq libarchive12 libarchive-dev libgecode-dev graphviz
bundle install
bundle exec omnibus build kontena
