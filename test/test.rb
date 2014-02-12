require 'octopress-deploy'
require 'find'

def setup_tests
  system "cp -r source/ _site"
  Find.find('_site').to_a.each do |f| 
    system("echo '#{garbage}' >> #{f}") unless File.directory?(f)
  end
end

def garbage
  o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
  (0...50).map { o[rand(o.length)] }.join
end

def cleanup
  system "rm -rf .deploy _site"
end

def test_git
  #Octopress::Deploy.init_config('git', config_file: '_deploy_git.yml', git_branch: 'test_git_deploy', git_url: "git@github.com:octopress/deploy")
  Octopress::Deploy.push(config_file: '_deploy_git.yml')
end

def test_rsync
  #Octopress::Deploy.init_config('rsync', config_file: '_deploy_rsync.yml')
  Octopress::Deploy.push(config_file: '_deploy_rsync.yml')
end

def test_s3
  Octopress::Deploy.push(config_file: '_s3_deploy.yml')
end

setup_tests
test_git
test_rsync
#test_s3
cleanup

