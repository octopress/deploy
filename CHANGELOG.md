# Octopress Deploy Changelog


## Current version

###  1.0.0 RC7 - 2014-05-02

- Fixed: `--version` flag.
- Fixed: Moved requiring `pry-debugger` to tests.

### 1.0.0 RC6 - 2014-04-17

- Fixed: CLI options now override config file settings.

## Past versions

### 1.0.0 RC5 - 2014-04-01

- Fixed: `site_dir` config didn't work.


### 1.0.0 RC4 - 2014-03-25

- Added: Octopress Ink documentation site support

### 1.0.0 RC3 - 2014-03-22

#### Minor Enhancements
- Default rsync flags are now `-rltDvz` so they no
  longer try to set file permissions or preserve owner and
  group name on remote. Issue: #19
- Added `flags` config for rsync allows customization of flags.
- Added support for octopress-ink documentation system.
- Added a `update_docs` Rake task to update assets/docs/index.markdown from README.md.

#### Bug Fixes
- No longer stripping forward slashes on remote_path. Issue #18
- `pull` command no longer promises a default directory.


### 1.0.0 RC2 - 2014-03-18
- CHANGE: `add_bucket` command becomes `add-bucket` 

### 1.0.0 RC1 - 2014-03-17
- Initial release
