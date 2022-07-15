#!/bin/bash
set -e
cd $HOME/sophia
bundle exec rake admin:rm_personal_data
bundle exec rake admin:truncate_log_tables
bundle exec rake admin:create_users_with_roles
bundle exec rake admin:stub_api_client_token_shared_secret
