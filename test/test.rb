require File.expand_path("../../lib/octopress-deploy.rb", __FILE__)
require 'fileutils'

def test_file(*subpaths)
  File.expand_path(File.join(*subpaths), File.dirname(__FILE__))
end

def test_git
  FileUtils.mkdir 'deploy_target'
  FileUtils.cd 'deploy_target' do
    system 'git init --bare'
  end
  Octopress::Deploy.init_config('git', git_url: File.expand_path("deploy_target"))
  Octopress::Deploy.push()
  FileUtils.rm_r 'deploy_target'
  FileUtils.rm_r test_file('_deploy.yml')
end

def test_rsync
  FileUtils.mkdir_p "deploy-rsync"
  Octopress::Deploy.init_config('rsync', remote_path: '.deploy')
  Octopress::Deploy.push()
  FileUtils.rm_r 'deploy-rsync'
  FileUtils.rm_r test_file('_deploy.yml')
end

test_git
test_rsync
