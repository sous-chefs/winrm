#
# Cookbook:: winrm
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'winrm::default' do
  context 'Windows' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(file_cache_path: Chef::Config[:file_cache_path], platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
