$LOAD_PATH.unshift File.expand_path("../", __FILE__)

require 'octopress-deploy/version'
require 'octopress-deploy/core_ext'
require 'colorator'
require 'yaml'

if defined? Octopress::Command
  require 'octopress-deploy/commands'
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
        abort "No deployment config found. Create one with: octopress deploy init #{@options[:config_file]}"
      else
        parse_options
        deploy_method.new(@options).push()
      end
    end

    def self.pull(options={})
      init_options(options)
      if !File.exists? @options[:config_file]
        abort "No deployment config found. Create one with: octopress deploy init #{@options[:config_file]}"
      else
        parse_options
        if !File.exists? @options[:dir]
          FileUtils.mkdir_p @options[:dir]
        end
        deploy_method.new(@options).pull()
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
    def self.init_config(options={})

      if !options[:method]
        puts options[:method]
        raise "Please provide a deployment method.", METHODS.keys
      end

      init_options(options)
      write_config
      check_gitignore
    end

    def self.write_config
      if File.exist?(@options[:config_file]) && !@options[:force]
        abort "A config file already exists at #{@options[:config_file]}. Use --force to overwrite."
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
      <<-FILE
method: #{@options[:method]}
site_dir: #{@options[:site_dir]}
#{deploy_method.default_config(@options)}
FILE
    end

    # Checks the repository's .gitignore for the config file
    #
    # returns: Boolean - whether it is present or not.
    #
    def self.check_gitignore
      gitignore = File.join(`git rev-parse --show-toplevel`.strip, ".gitignore")

      if !File.exist?(gitignore) ||
        File.open(gitignore).read.match(/^#{@options[:config_file]}/i).nil?
        puts "Remember to add #{@options[:config_file]} to your .gitignore."
        false
      else
        true
      end
    end
  end
end
