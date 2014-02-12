require 'octopress-deploy/version'
require 'octopress-deploy/core_ext'
require 'colorator'

if defined? Octopress::Command
  require 'octopress-deploy/cli'
end


module Octopress
  module Deploy
    autoload :Git,    'octopress-deploy/git'
    autoload :Rsync,  'octopress-deploy/rsync'
    autoload :S3,     'octopress-deploy/s3'

    METHODS = {
      'git'=> Git,
      'rsync'=> Rsync,
      's3'=> S3
    }

    def self.push(options={})
      init_options(options)
      if !File.exists? @options[:config_file]
        init_config if ask_bool("Deployment config file not found. Create #{@options[:config_file]}?")
      else
        parse_options
        deploy_method.new(@options).push()
      end
    end

    def self.parse_options
      config  = YAML.load(File.open(@options[:config_file])).to_symbol_keys
      @options = @options.to_symbol_keys
      @options = config.deep_merge(@options)
    end

    def self.init_options(options={})
      @options = options.to_symbol_keys
      @options[:config_file] ||= '_deploy.yml'
      @options[:site_dir] ||= site_dir
    end

    def self.deploy_method
      METHODS[@options[:method].downcase]
    end

    def self.site_dir
      @options[:site_dir] || if File.exist? '_config.yml'
        YAML.load(File.open('_config.yml'))['destination'] || '_site'
      else
        '_site'
      end
    end

    # Create a config file
    #
    def self.init_config(method=nil, options={})
      init_options(options) unless @options
      @options[:method] ||= method

      unless @options[:method]
        @options[:method] = ask("How would you like to deploy your site?", METHODS.keys)
      end

      write_config
      check_gitignore
    end

    def self.write_config
      if File.exist?(@options[:config_file]) &&
       !ask_bool("A config file already exists at #{@options[:config_file]}. Overwrite?")
       return puts "No config file written."
      end

      config = get_config.strip
      File.open(@options[:config_file], 'w') { |f| f.write(config) }
      puts "File #{@options[:config_file]} created.".green
      puts "------------------"
      puts "#{config.yellow}"
      puts "------------------"
      puts "Please add your configurations to this file."
    end

    def self.get_config
      config = <<-FILE
method: #{@options[:method]}
site_dir: #{@options[:site_dir]}
#{deploy_method.default_config(@options)}
FILE
    end

    def self.check_gitignore
      gitignore = File.join(`git rev-parse --show-toplevel`.strip, ".gitignore")
      if !File.exist?(gitignore) ||
        Pathname.new(gitignore).read.match(/^#{@options[:config_file]}/i).nil?
        if ask_bool("Do you want to add #{@options[:config_file]} to your .gitignore?")
          git_ignore_config_file gitignore
          return true
        end
      else
        return true
      end
    end

    def self.git_ignore_config_file(gitignore)
      File.open(gitignore, 'a') { |f| f.write(@options[:config_file]) }
    end

    def self.ask_bool(message)
      ask(message, ['y','n']) == 'y'
    end

    def self.ask(message, valid_options)
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
          
    def self.get_stdin(message)
      print message
      STDIN.gets.chomp
    end
  end
end
