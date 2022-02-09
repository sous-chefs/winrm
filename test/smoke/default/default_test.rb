# Inspec test for recipe test::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe port(5985) do
  it { should be_listening }
end

describe port(5986) do
  it { should be_listening }
end

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
