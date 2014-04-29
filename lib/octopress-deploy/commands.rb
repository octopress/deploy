module Octopress
  module Deploy
    class Commands < Octopress::Command
      def self.init_with_program(p)
        p.command(:deploy) do |c|
          c.syntax "deploy [options]"
          c.version Deploy::VERSION
          c.description "Deploy your Octopress site."
          c.option "config_file", "--config FILE", "The path to your config file (default: _deploy.yml)"

          c.action do |args, options|
            Octopress::Deploy.push(options)
          end

          c.command(:pull) do |c|
            c.syntax "pull <DIR>"
            c.description "Pull down the published copy of your site into DIR"
            c.option "config_file", "--config FILE", "The path to your config file (default: _deploy.yml)"

            c.action do |args, options|
              options['dir'] = args.first
              Octopress::Deploy.pull(options)
            end
          end

          c.command(:init) do |c|
            c.syntax 'init <METHOD> [options]'
            c.description "Create a configuration file for a deployment method (#{Deploy::METHODS.keys.join(', ')})."
            c.option 'force', '--force', 'Initialize a config file even if it already exists.'

            c.action do |args, options|
              options['method'] = args.first
              Octopress::Deploy.init_config(options)
            end
          end

          c.command(:'add-bucket') do |c|
            c.syntax 'add-bucket [options]'
            c.description "Add a new S3 bucket and configure it for static websites."
            c.option 'bucket_name','--name NAME','Choose a bucket name. (Defaults: to bucket_name in config file)'
            c.option 'region','--region REGION','Choose a region. (Defaults: to region in config file)'
            c.option 'index_page','--index PAGE','Specify an index page. (Default: index.html)'
            c.option 'error_page','--error PAGE','Specify an error page. (Default: 404.html)'
            c.option "config_file", "--config FILE", "The path to your config file (default: _deploy.yml)"

            c.action do |args, options|
              Octopress::Deploy.add_bucket(options)
            end
          end
        end
      end
    end
  end
end
