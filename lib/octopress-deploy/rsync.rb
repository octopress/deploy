module Octopress
  module Deploy
    class Rsync

      def initialize(options)
        @user         = options[:user]
        @port         = options[:port] || "22"
        @local        = options[:site_dir]
        @remote       = options[:remote_path]
        @exclude      = options[:exclude]
        @exclude_file = options[:exclude_file]
        @include      = options[:include]
        @delete       = options[:delete]
      end

      def push
        cmd = "rsync -avz"
        if @exclude || @exclude_file
          cmd << "e"
          if @exclude_file
            cmd << " --exclude-from #{@exclude_file}"
          else
            cmd << " --exclude #{@exclude}"
          end
        end
        if @include
          cmd << " --include #{@include}"
        end
        if @user
          cmd << " ssh -p #{@port}"
        end
        if @delete
          cmd << " --delete"
        end
        cmd += " #{File.join(@local, '')} "
        if @user
          cmd << "#{@user}:"
        end
        cmd << "#{@remote}"

        system cmd
      end

      def self.default_config(options={})
        config = <<-CONFIG
user: #{options[:user]}
port: #{options[:port] || '22'}
remote_path: #{options[:remote_path]}
delete: #{options[:delete]}
CONFIG
      end
      
    end
  end
end
