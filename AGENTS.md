# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-oddjob` is a small SIMP Puppet module that provides basic management for
**OddJob** (`oddjobd`), the D-Bus service that lets unprivileged clients ask a
privileged daemon to run a limited set of tasks on their behalf. The base class
installs the `oddjob` package and ensures the `oddjobd` service is running and
enabled (`manifests/init.pp`). The `oddjob::mkhomedir` class layers on the
`oddjob-mkhomedir` helper — which creates users' home directories on first login
— and drops the daemon config snippet that wires up the
`com.redhat.oddjob_mkhomedir` D-Bus interface (`manifests/mkhomedir.pp`).

The module is a thin package/service/config wrapper: there is no SIMP feature
seam beyond the standard `simp_options::package_ensure` lookup, and no
conditional OS logic in the manifests.

### Business logic

The module has two classes, both public; there are no defines.

- **`oddjob` (`manifests/init.pp`)** — Public entry class (not
  `assert_private()`'d; consumers `include 'oddjob'`). Parameter
  (`init.pp`):
  - `$package_ensure` (`String`) — defaults to
    `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`
    (`init.pp`).

  Resources:
  - `package { 'oddjob' }` at `$package_ensure` (`init.pp`).
  - `service { 'oddjobd' }` — `ensure => 'running'`, `enable => true`,
    `require => Package['oddjob']` (`init.pp`).

- **`oddjob::mkhomedir` (`manifests/mkhomedir.pp`)** — Public class (not
  `assert_private()`'d). Parameters (`mkhomedir.pp`):
  - `$umask` (`Simplib::Umask`, type from `simp/simplib`) — default `'0027'`;
    interpolated into the mkhomedir helper command in the config template
    (`mkhomedir.pp`).
  - `$package_ensure` (`String`) — defaults to
    `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`
    (`mkhomedir.pp`).

  Control flow and resources:
  - `include 'oddjob'` (`mkhomedir.pp`) — pulls in the base package/service.
  - `package { 'oddjob-mkhomedir' }` at `$package_ensure` (`mkhomedir.pp`),
    chained with `->` to the config file so the package installs first.
  - `file { '/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf' }` (`mkhomedir.pp`)
    — mode `0644`, `notify => Service['oddjobd']` (defined in the base class),
    content rendered from
    `template('oddjob/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf.erb')`.

### Gotchas / non-obvious details

- **`oddjob::mkhomedir` implicitly `include`s `oddjob`** (`mkhomedir.pp`), so
  it can `notify` the base class's `Service['oddjobd']`. Do not declare
  `oddjob::mkhomedir` in a context where `oddjob` is declared with resource-like
  syntax elsewhere, or you'll get a duplicate-declaration conflict.
- **`$umask` is not validated against the D-Bus config semantics — only against
  the `Simplib::Umask` type** (`mkhomedir.pp`). It is injected verbatim into
  the helper `exec` string in the template
  (`templates/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf.erb`, `-u <%= @umask %>`).
- **The template hard-codes the helper path** `/usr/libexec/oddjob/mkhomedir`
  and the D-Bus service/interface name `com.redhat.oddjob_mkhomedir`
  (`.erb:14,25,28,35`) — these are Red-Hat-family paths, consistent with the
  EL-only OS matrix.
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  both manifests consume the `simp_options::package_ensure` seam via
  `simplib::lookup` (the function is provided by `simp/simplib`). `simp_options`
  is not even a fixture here — the `simplib::lookup` default keeps compilation
  working without it (`.fixtures.yml` lists only `simplib`).
- **The service is always forced running/enabled** (`init.pp`); there is
  no parameter to disable or stop `oddjobd`. Managing `oddjob` means managing a
  running daemon.
- **No `data/` or `hiera.yaml`** — unlike many SIMP modules, this one ships no
  module-level Hiera data; all defaults live in the manifests.

## The `simp_options` / `simplib::lookup` seam

This is the module's only SIMP feature seam (the natural target for a
lookup-path unit test):

| File | Key | `default_value` |
|------|-----|-----------------|
| `manifests/init.pp` | `simp_options::package_ensure` | `'installed'` |
| `manifests/mkhomedir.pp` | `simp_options::package_ensure` | `'installed'` |

Keep routing SIMP feature toggles through `simplib::lookup('simp_options::*', {
'default_value' => ... })` with an explicit default rather than assuming
`simp_options` is included.

## Dependencies

Module dependencies (from `metadata.json`):

- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0`
- `simp/simplib` `>= 4.9.0 < 6.0.0` (provides `simplib::lookup` and the
  `Simplib::Umask` data type used by `oddjob::mkhomedir`)

No optional dependencies (`metadata.json` has no `simp.optional_dependencies`
key).

Fixture-only dependency (from `.fixtures.yml`, present for test compilation, not
a runtime dep): `simplib` is checked out from source; the module itself is
symlinked in. Note `simp_options` is **not** a fixture despite the seam above.

Runtime requirement (from `metadata.json` `requirements`): `openvox >= 8.0.0
< 9.0.0`.

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — the `oddjob` base class (package + service).
- `manifests/mkhomedir.pp` — the `oddjob::mkhomedir` class (mkhomedir helper +
  config file).
- `templates/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf.erb` — the sole template;
  the `com.redhat.oddjob_mkhomedir` D-Bus config snippet, interpolating `@umask`.
- `metadata.json` — deps, OS matrix, OpenVox requirement.
- `spec/classes/init_spec.rb`, `spec/classes/mkhomedir_spec.rb` — rspec-puppet
  unit tests (compile + resource checks across `on_supported_os`).
- `spec/acceptance/suites/default/class_spec.rb` — beaker acceptance suite
  (applies `include '::oddjob'`, checks idempotence, package installed, service
  enabled/running); nodesets under `spec/acceptance/nodesets/`.
- `REFERENCE.md` — generated Puppet Strings reference.
- No `data/` or `hiera.yaml` — the module ships no module-level Hiera data.
- No `types/` or `lib/` — this module defines no custom Puppet data types and no
  Ruby types/providers/functions/facts. `Simplib::Umask` and `simplib::lookup`
  come from `simp/simplib`.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job (matrix `almalinux9`, `almalinux10`) whose final step runs
  `bundle exec rake beaker:suites[default,<node>]` under
  `BEAKER_HYPERVISOR=vagrant_libvirt` (with `VAGRANT_DEFAULT_PROVIDER=libvirt`).

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run a single class spec
bundle exec rspec spec/classes/init_spec.rb
bundle exec rspec spec/classes/mkhomedir_spec.rb

# Run specs in parallel (as CI does)
bundle exec rake parallel_spec

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`. Rubocop is pinned to `~> 1.88.0`. The `Gemfile`
loads both `openvox` and `puppet` gems in the `:test` group, defaulting to the
`>= 8 < 9` range. `spec/spec_helper.rb` uses
`require 'puppetlabs_spec_helper/module_spec_helper'`.

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on the classes —
  they drive `REFERENCE.md`. Regenerate `REFERENCE.md` after changing docs or
  parameters.
- Continue routing SIMP feature toggles through
  `simplib::lookup('simp_options::*', { 'default_value' => ... })` rather than
  assuming `simp_options` is included.
- Use the `Simplib::Umask` type (not a bare `String`) for umask-shaped
  parameters, as `oddjob::mkhomedir` does.
- `Gemfile`, `spec/spec_helper.rb`, `.gitignore`, `.pdkignore`, and
  `.github/workflows/pr_tests.yml` carry a **puppetsync** notice — they are
  baseline-managed and the next sync overwrites local edits. Push changes to
  those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in the manifests.
