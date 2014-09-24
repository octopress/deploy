require 'octopress-docs'

Octopress::Docs.add({
  name:        "Octopress Deploy",
  slug:        "deploy",
  dir:         File.expand_path(File.join(File.dirname(__FILE__), "../../")),
  base_url:    "docs/deploy"
})
