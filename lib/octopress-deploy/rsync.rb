module Octopress
  module Deploy
    class Rsync

      def initialize(options)
        @user         = options[:user]
        @port         = options[:port]
        @local        = options[:site_dir]
        @remote       = options[:remote_path]
        @exclude      = options[:exclude]
        @exclude_file = options[:exclude_file]
        @exclude_file = File.expand_path(@exclude_file) if @exclude_file
        @include      = options[:include]
        @delete       = options[:delete]
      end

      def push
        cmd =  "rsync -avz"
        cmd << " -e"                               if @exclude_file || @exclude
        cmd << " --exclude-from #{@exclude_file}"  if @exclude_file
        cmd << " --exclude #{@exclude}"            if @exclude
        cmd << " --include #{@include}"            if @include
        cmd << " --rsh='ssh -p#{@port}'"           if @user && @port
        cmd << " --delete"                         if @delete
        cmd += " #{File.join(@local, '')} "
        cmd << "#{@user}:"                         if @user
        cmd << "#{@remote}"

        puts "Syncing #{@local} files to #{@remote} with rsync."
        system cmd
      end

      def self.default_config(options={})
        <<-CONFIG
user: #{options[:user]}
port: #{options[:port]}
remote_path: #{options[:remote_path]}
delete: #{options[:delete]}
CONFIG
      end
      
    end
  end
end
