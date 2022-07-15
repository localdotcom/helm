#!/bin/bash
set -e
cd $HOME/sophia
bundle exec rake admin:prepare_dev_dataset
