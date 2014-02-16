module Octopress
  module Deploy
    class Rsync

      def initialize(options)
        @options      = options
        @user         = @options[:user]
        @port         = @options[:port]
        @local        = @options[:site_dir]
        @remote_path  = @options[:remote_path]
        @exclude      = @options[:exclude]
        @exclude_file = @options[:exclude_file]
        @exclude_file = File.expand_path(@exclude_file) if @exclude_file
        @include      = @options[:include]
        @delete       = @options[:delete]
        @remote_path  = @remote_path.sub(/^\//,'') #remove leading slash
        @pull_dir     = @options[:pull_dir]
      end

      def push
        puts "Syncing #{@local} files to #{@remote_path} with rsync."
        system cmd
      end

      def pull
        puts "Syncing #{@remote_path} files to #{@pull_dir} with rsync."
        system cmd
      end

      def cmd
        local = ''
        remote = ''

        cmd    =  "rsync -avz "
        cmd    << " -e "                               if @exclude_file || @exclude
        cmd    << " --exclude-from #{@exclude_file} "  if @exclude_file
        cmd    << " --exclude #{@exclude} "            if @exclude
        cmd    << " --include #{@include} "            if @include
        cmd    << " --rsh='ssh -p#{@port}' "           if @user && @port
        cmd    << " --delete "                         if @delete

        local  << " #{File.join(@local, '')} "
        remote << " #{@user}:"                         if @user
        remote << "#{@remote_path}"

        if @pull_dir
          cmd << remote+'/ ' << @pull_dir
        else
          cmd << local << remote
        end
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
