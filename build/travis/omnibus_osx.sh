#!/bin/sh

cd cli/omnibus
export USE_SYSTEM_GECODE=1
brew install gecode
bundle install
bundle exec omnibus build kontena
