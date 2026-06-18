# frozen_string_literal: true

require 'spec_helper'

describe 'winrm_listener_config' do
  step_into :winrm_listener_config
  platform 'windows', '2022'

  before do
    stub_command(/.*/).and_return(false)
  end

  context 'with default properties' do
    recipe do
      winrm_listener_config 'default'
    end

    it { is_expected.to run_powershell_script('winrm-enable') }
    it { is_expected.to run_powershell_script('winrm-create-self-signed-certificate') }
    it { is_expected.to run_powershell_script('winrm-create-https-listener') }
    it { is_expected.to run_powershell_script('winrm-create-http-listener') }
    it { is_expected.to create_windows_firewall_rule('WINRM HTTP Static Port') }
    it { is_expected.to create_windows_firewall_rule('WINRM HTTPS Static Port') }
  end

  context 'with HTTP disabled' do
    recipe do
      winrm_listener_config 'https-only' do
        listen_http false
        allow_unencrypted false
        allow_basic_auth false
      end
    end

    it { is_expected.to_not run_powershell_script('winrm-create-http-listener') }
    it { is_expected.to run_powershell_script('winrm-create-https-listener') }
    it { is_expected.to run_powershell_script('winrm-auth') }
    it { is_expected.to run_powershell_script('winrm-unencrypted') }
  end

  context 'delete action' do
    before do
      stub_command(/Transport.*HTTPS/).and_return(true)
      stub_command(/Transport.*HTTP\\s/).and_return(true)
    end

    recipe do
      winrm_listener_config 'default' do
        action :delete
      end
    end

    it { is_expected.to run_powershell_script('winrm-delete-https-listener') }
    it { is_expected.to run_powershell_script('winrm-delete-http-listener') }
    it { is_expected.to delete_windows_firewall_rule('WINRM HTTP Static Port') }
    it { is_expected.to delete_windows_firewall_rule('WINRM HTTPS Static Port') }
  end
end
