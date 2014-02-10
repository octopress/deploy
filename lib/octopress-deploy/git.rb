module Octopress
  module Deploy
    class Git
      def initialize(options={})
        @config_file = options[:config_file] || '_deploy.yml'
        if !File.exists? @config_file
          init_config if ask_bool("Deployment config file not found. Create #{@config_file}?")         
        else
          config = YAML.load(File.open(@config_file))
          @site_dir    = options[:site_dir]   || config['site']
          @repo        = options[:git_url]    || config['git']['url']
          @branch      = options[:git_branch] || config['git']['branch']
          @deploy_dir  = options[:deploy_dir] || config['git']['deploy_dir'] || '.deploy'
          @remote      = options[:remote]     || config['git']['remote'] || 'deploy'

          abort "Deploy Failed: You must provide a repository URL before deploying. Check your #{@config_file}.".red if @repo.nil?
        end
      end

      # Create a config file
      #
      def init_config
        config = <<-FILE
site: _site
git:
  url:
  branch: master
FILE
        File.open(@config_file, 'w') { |f| f.write(config) }
        puts "File #{@config_file} created.".green
        puts "------------------"
        puts config
        puts "------------------"
        puts "Please update it with your settings."
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


      # If necessary create deploy directory and initialize it with deployment remote
      #
      def init_repo
        FileUtils.mkdir_p @deploy_dir
        FileUtils.cd @deploy_dir do
          if Dir[@deploy_dir+'/*'].empty?

            # Attempt to clone from the remote
            #
            cmd = "git clone #{@repo} --origin #{@remote} --branch #{@branch} ."
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

      def ask_bool(message)
        ask(message, ['y','n']) == 'y'
      end

      def ask(message, valid_options)
        if valid_options
          options = valid_options.join '/'
          answer = get_stdin("#{message} [#{options}]: ").downcase.strip
          if valid_options.map{|o| o.downcase}.include?(answer)
            return answer
          else
            return false
          end
        else
          answer = get_stdin("#{message}: ")
        end
        answer
      end
            
      def get_stdin(message)
        print message
        STDIN.gets.chomp
      end
    end
  end
end
