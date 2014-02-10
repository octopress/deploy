module Octopress
  module Deploy
    class Git

      def initialize(options={})
        @options    = options
        @repo       = @options[:git_url]
        @branch     = @options[:git_branch]
        @site_dir   = @options[:site_dir]
        @remote     = @options[:remote]     || 'deploy'
        @deploy_dir = @options[:deploy_dir] || '.deploy'
        abort "Deploy Failed: You must provide a repository URL before deploying. Check your #{@options[:config_file]}.".red if @repo.nil?
      end

      # Initialize, pull, copy and deploy.
      # This is the method you're looking for.
      #
      def push
        init_repo unless check_repo
        git_pull
        copy_site
        git_push
      end

      # Check to see if local deployment dir configured to deploy
      #
      def check_repo
        return unless Dir.exist? @deploy_dir
        FileUtils.cd @deploy_dir do
          return `git remote -v`.include? @repo
        end
      end

      def self.default_config(options={})
        config = <<-CONFIG
git_url: #{options[:git_url]}
git_branch: #{options[:git_branch] || 'master'}
CONFIG
      end

      # If necessary create deploy directory and initialize it with deployment remote
      #
      def init_repo
        FileUtils.mkdir_p @deploy_dir
        FileUtils.cd @deploy_dir do
          if Dir[@deploy_dir+'/*'].empty?

            # Attempt to clone from the remote
            #
            cmd = "git clone #{@repo} --origin #{@remote} --branch #{@branch} ."
            puts cmd
            Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
              exit_status = wait_thr.value

              # If cloning fails, initialize the directory manually
              # This will occur if a remote has no commits
              #
              unless exit_status.success?
                `git init; git remote add #{@remote} #{@repo}`
                `echo "initialize deploy repo" > _`
                `git add .; git commit -m 'initial commit'`
                `git branch -m #{@branch}`
                `git rm _; git add -u; git commit -m 'cleanup'`
              end
            end
          end
        end
      end

      def git_push
        FileUtils.cd @deploy_dir do
          `git push #{@remote} #{@branch}`
        end
      end

      def git_pull
        FileUtils.cd @deploy_dir do
          output, error = Open3.capture3"git pull #{@remote} #{@branch}"
          FileUtils.rm_rf(Dir.glob('*'), secure: true) if error.empty?
        end
      end

      def copy_site
        FileUtils.cp_r @site_dir + '/.', @deploy_dir
        FileUtils.cd @deploy_dir do
          message = "Site updated at: #{Time.now.utc}"
          `git add --all :/; git commit -m '#{message}'`
        end
      end
    end
  end
end
