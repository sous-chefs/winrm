# AGENTS.md

## Cookbook Purpose

This cookbook manages WinRM listener configuration on Windows hosts through the
`winrm_listener_config` custom resource. It does not install WinRM; WinRM is a
Windows operating system component.

## Agent Findings

* Full migration removes the public `winrm::default` recipe. Consumers should call
  `winrm_listener_config` directly from wrapper cookbooks.
* The legacy `provides :winrm` alias is retained for the resource so existing resource-style
  consumers are not forced through the removed recipe API.
* The old bundled `selfssl.exe` helper was removed. Certificate generation now uses the
  Windows PowerShell `New-SelfSignedCertificate` cmdlet available on supported Windows Server
  releases.
* This is Windows-only. Do not reintroduce Linux/Dokken Kitchen platforms for this cookbook.

## Platform Availability

WinRM is included with supported Windows Server releases. This cookbook targets currently
supported Windows Server versions that can run Chef Infra Client and PowerShell certificate
management:

* Windows Server 2016: extended support ends 2027-01-12.
* Windows Server 2019: extended support ends 2029-01-09.
* Windows Server 2022: extended support ends 2031-10-14.
* Windows Server 2025: extended support ends 2034-11-14.

Windows Server 2012 and 2012 R2 are not active support targets. Microsoft extended support ended
2023-10-10, with paid ESU only through 2026-10-13.

## Architecture Limitations

WinRM availability follows Windows Server architecture support. This cookbook does not publish or
install architecture-specific packages.

## Source/Compiled Installation

No source or compiled installation path exists. The resource configures Windows built-in WinRM,
certificate store, and firewall state.

## Known Issues

* `winrm_listener_config :delete` removes listeners and firewall rules created by the resource,
  but it does not attempt to restore prior global WinRM service authentication settings because the
  previous values are not known.
* Kitchen verification requires a Windows runner. macOS/Linux local hosts can run style and
  ChefSpec, but not the exec Kitchen suite meaningfully.

## Test and CI Notes

* Use `kitchen.exec.yml` on `windows-latest` for CI.
* Keep `chef_omnibus_install: false` so Kitchen uses Chef installed by the workflow.
* Keep the default suite pointed at `recipe[test::default]`.
* The Windows exec suite uses the shell verifier because `kitchen-inspec` crashes after loading
  the profile on the GitHub `windows-latest` runner with `undefined method strip for nil:NilClass`.
  Keep the InSpec profile in `test/integration/default`, but use direct PowerShell assertions for
  the CI exec verifier unless that upstream verifier bug is fixed.
