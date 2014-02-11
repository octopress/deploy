require 'octopress-deploy'

def test_git
  FileUtils.mkdir 'deploy_target'
  FileUtils.cd 'deploy_target' do
    system 'git init --bare'
  end
  Octopress::Deploy.init_config('git', git_url: File.expand_path("deploy_target"))
  Octopress::Deploy.push()
  FileUtils.rm_r 'deploy_target'
end

def test_rsync
  FileUtils.mkdir_p "deploy-rsync"
  Octopress::Deploy.init_config('rsync', remote_path: 'deploy-rsync')
  Octopress::Deploy.push()
  FileUtils.rm_r 'deploy-rsync'
end

def test_s3
  Octopress::Deploy.push(config_file: '_s3_deploy.yml')
end

test_git
test_rsync
test_s3

