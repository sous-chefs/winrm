#
# Cookbook:: winrm
# Recipe:: default
#
# Copyright:: 2012, Peter Crossley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if platform_family?('windows')
  Chef::Log.warn('winrm::default recipe has been deprecated. Please use the winrm_listener_config resource directory instead.')

  winrm_listener_config 'default'
else
  Chef::Log.warn('WinRM can only be enabled on the Windows platform.')
end
