# Octopress Deploy Changelog

## Current released version

### 1.0.0 RC3 - 2014-03-22

#### Minor Enhancements
- Default rsync flags are now `-rltDvz` so they no
  longer try to set file permissions or preserve owner and
  group name on remote. Issue: #19
- Added `flags` config for rsync allows customization of flags.

#### Bug Fixes
- No longer stripping forward slashes on remote_path. Issue #18
- `pull` command no longer promises a default directory.

## Past version

### 1.0.0 RC2 - 2014-03-18
- CHANGE: `add_bucket` command becomes `add-bucket` 

### 1.0.0 RC1 - 2014-03-17
- Initial release
