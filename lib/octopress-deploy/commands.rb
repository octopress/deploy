module Octopress
  module Deploy
    class Commands < Octopress::Command
      def self.init_with_program(p)
        p.command(:deploy) do |c|
          c.syntax "deploy [options]"
          c.description "Deploy your Octopress site."
          c.option "config_file", "--config FILE", "The path to your config file (default: _deploy.yml)"
          c.option "using", "--using METHOD", "Define the push method to use, overriding your configuration file's setting"
          c.option "pull", "--pull DIRECTORY", "Pull down the published copy of your site into a directory (default: ./site-pull)"

          c.action do |args, options|
            if options[:pull] and options[:pull].is_a?(String)
              Octopress::Deploy.pull(options[:pull], options)
            else
              Octopress::Deploy.push(options)
            end
          end

          c.command(:init) do |c|
            c.syntax 'init <METHOD> [options]'
            c.description "Create a configuration file for a deployment method (#{Deploy::METHODS.keys.join(', ')})."
            c.option 'force', '--force', 'Initialize a config file even if it already exists.'

            c.action do |args, options|
              options[:method] = args.first
              Octopress::Deploy.init_config(options)
            end
          end
        end
      end
    end
  end
end
