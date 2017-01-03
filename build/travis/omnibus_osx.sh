#!/bin/sh

cd cli/omnibus
bundle install
bundle exec omnibus build kontena
