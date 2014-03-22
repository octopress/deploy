# Octopress Deploy Changelog

## HEAD


#### Minor Enhancements
- NEW: Default rsync flags are now `-rltDvz` so they no
  longer try to set file permissions or preserve owner and
  group name on remote. Issue: #19
- NEW: `flags` config for rsync allows customization of flags.
- FIX: No longer stripping forward slashes on remote_path. Issue #18
- FIX: `pull` command no longer promises a default directory.

## Release Candidates

### 1.0.0 RC2 - 2014-03-18
- Changed `add_bucket` command to `add-bucket` 

### 1.0.0 RC1 - 2014-03-17
- Initial release
