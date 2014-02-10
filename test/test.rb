require 'octopress-deploy'

FileUtils.mkdir 'deploy_target'
FileUtils.cd 'deploy_target' do
  system 'git init --bare'
end

Octopress::Deploy::Git.new({git_url: File.expand_path('deploy_target')}).push
FileUtils.rm_r 'deploy_target'
