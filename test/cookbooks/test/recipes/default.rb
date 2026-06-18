# frozen_string_literal: true

winrm_listener_config 'default' do
  listen_http true
  listen_https true
  trusted_hosts '*'
  allow_unencrypted true
  allow_basic_auth true
end
