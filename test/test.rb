require File.expand_path("../../lib/octopress-deploy.rb", __FILE__)
require 'fileutils'
require 'find'
require 'pry-byebug'

@has_failed = false
@failures = {}

def setup_tests
  `rm -rf build` # clean up from previous tests
  generate_site
end

def generate_site
  system "cp -r source/ build"
  Find.find('build').to_a.each do |f| 
    system("echo '#{garbage}' >> #{f}") unless File.directory?(f)
  end
end

def pout(str)
  print str
  $stdout.flush
end

def garbage
  o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
  (0...50).map { o[rand(o.length)] }.join
end

def diff_dir(dir1, dir2)
  dir_files(dir1).each do |f1|
    if diff = diff_file(f1, f1.sub(dir1, dir2))
      @failures["#{@testing}: #{f1}"] = diff
      pout "F".red
      @has_failed = true
    else
      pout ".".green
    end
  end
end

def diff_file(file1, file2)
  if File.exist?(file2)
    diff = `diff #{file1} #{file2}`
    if diff.size > 0
      diff
    else
      false
    end
  else
    "File: #{file2}: No such file or directory."
  end
end

def dir_files(dir)
  Find.find(dir).to_a.reject!{|f| File.directory?(f) }
end

def test_remote_git
  @testing = 'remote git'
  repo = "git@github.com:octopress/deploy"
  config = "_git_deploy.yml"
  
  # Clean up from previous tests
  #
  `rm -rf .deploy pull-git`
  
  # Test remote git deployment
  #
  Octopress::Deploy.init_config(method: 'git', config_file: config, force: true, site_dir: 'build', git_branch: 'test_git_deploy', git_url: repo)
  Octopress::Deploy.push(config_file: config)
  Octopress::Deploy.pull(dir: 'pull-git', config_file: config)
  diff_dir('build', 'pull-git')
end

def test_local_git
  @testing = 'local git'
  config = "_git_deploy.yml"

  # Clean up from previous tests
  #
  `rm -rf .deploy local-git pull-git`
  `git init --bare local-git`
  repo = "local-git"

  # Test local git deployment
  #
  Octopress::Deploy.init_config(method: 'git', config_file: config, force: true, site_dir: 'build', git_branch: 'test_git_deploy', git_url: File.expand_path(repo), remote_path: 'site')
  Octopress::Deploy.push(config_file: config)
  Octopress::Deploy.pull(dir: 'pull-git', config_file: config, git_url: File.expand_path(repo), remote_path: 'site')
  diff_dir('build', 'pull-git/site')
end

def test_remote_rsync
  @testing = 'remote rsync'
  config = '_rsync_deploy.yml'

  # Clean up from previous tests
  `rm -rf local-rsync pull-rsync`
  
  # Test remote git deployment
  #
  Octopress::Deploy.init_config(method: 'rsync', config_file: config, site_dir: 'build', force: true, user: 'imathis@imathis.com', remote_path: '~/octopress-deploy/rsync/')
  Octopress::Deploy.push(config_file: config)
  Octopress::Deploy.pull(dir: 'pull-rsync', config_file: config)
  diff_dir('build', 'pull-rsync')

end

def test_local_rsync
  @testing = 'local rsync'
  config = '_rsync_deploy.yml'
  
  # Clean up from previous tests
  `rm -rf local-rsync pull-rsync`

  # Test local git deployment
  #
  Octopress::Deploy.init_config(method: 'rsync', config_file: config, site_dir: 'build', force: true, remote_path: 'local-rsync')
  Octopress::Deploy.push(config_file: config)
  Octopress::Deploy.pull(dir: 'pull-rsync', config_file: config, user: false, remote_path: 'local-rsync')
  diff_dir('build', 'pull-rsync')
end

def test_s3
  @testing = 's3'
  config = "_s3_deploy.yml"
  `rm -rf pull-s3`
  Octopress::Deploy.push(config_file: config)
  Octopress::Deploy.pull(dir: 'pull-s3', config_file: config)
  diff_dir('build', 'pull-s3')
end

def print_test_results
  puts "\n"
  if @has_failed
    @failures.each do |name, diff|
      puts "Failure in #{name}:".red
      puts "---------"
      puts diff
      puts "---------"
    end
    abort
  else
    puts "All passed!".green
  end
end


setup_tests

# local tests
test_local_rsync
test_local_git

# remote tests
test_remote_git
test_remote_rsync
test_s3

print_test_results

