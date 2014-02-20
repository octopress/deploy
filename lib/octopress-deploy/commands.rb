module Octopress
  module Deploy
    class Commands < Octopress::Command
      def self.init_with_program(p)
        p.command(:deploy) do |c|
          c.syntax "octopress deploy [options]"
          c.description "Deploy your Octopress site."
          c.option "config_file", "--config FILE", "The path to your config file (default: _deploy.yml)"
          c.option "init", "--init METHOD", "Initialize a config file with the options for the given method."
          c.option "using", "--using METHOD", "Define the push method to use, overriding your configuration file's setting"
          c.option "pull", "--pull DIRECTORY", "Pull down the published copy of your site into a directory (default: ./site-pull)"

          c.action do |_, options|
            if options["init"] and options["init"].is_a?(String)
              Octopress::Deploy.init_config(options["init"], options)
            elsif options["pull"] and options["pull"].is_a?(String)
              Octopress::Deploy.pull(options["pull"], options)
            else
              Octopress::Deploy.push(options)
            end
          end
        end
      end
    end
  end
end
