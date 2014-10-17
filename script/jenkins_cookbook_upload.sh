#!/bin/bash

set -e
set +x

COOKBOOK=$(echo $JOB_NAME | sed 's/_cookbook//')

echo "Uploading cookbook $COOKBOOK on Chef servers..."


cd ..
cur_dir=$(pwd)
ln -f -s "$cur_dir/$JOB_NAME" "$cur_dir/$COOKBOOK"
cd "$cur_dir/$COOKBOOK"


echo "Uploading to chef01.staging $COOKBOOK..."
bundle exec knife cookbook upload $COOKBOOK -o ../ --freeze

echo "Uploading to chef-hosted $COOKBOOK..."
bundle exec knife cookbook upload $COOKBOOK -c /var/lib/jenkins/.chef/hosted_chef-knife.rb -o ../ --freeze

