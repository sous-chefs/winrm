# frozen_string_literal: true

control 'winrm-listener-01' do
  impact 1.0
  title 'WinRM ports listen'

  describe port(5985) do
    it { should be_listening }
  end

  describe port(5986) do
    it { should be_listening }
  end
end

control 'winrm-firewall-01' do
  impact 1.0
  title 'WinRM firewall rules allow traffic'

  describe windows_firewall_rule('WINRM HTTP Static Port') do
    it { should be_enabled }
    it { should be_allowed }
    it { should be_tcp }
    its('local_port') { should cmp 5985 }
  end

  describe windows_firewall_rule('WINRM HTTPS Static Port') do
    it { should be_enabled }
    it { should be_allowed }
    it { should be_tcp }
    its('local_port') { should cmp 5986 }
  end
end
