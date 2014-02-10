require "octopress-deploy/version"
require "YAML"
require 'colorator'
require 'open3'

module Octopress
  module Deploy
    autoload :Git,  'octopress-deploy/git'
  end
end
