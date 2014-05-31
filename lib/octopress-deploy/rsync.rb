module Octopress
  module Deploy
    class Rsync

      def initialize(options)
        @options      = options
        @flags        = @options[:flags] || ' -avz'
        @user         = @options[:user]
        @port         = @options[:port]
        @local        = @options[:site_dir] || '_site'
        @remote_path  = @options[:remote_path]
        @exclude      = @options[:exclude]
        @exclude_file = @options[:exclude_file]
        @exclude_file = File.expand_path(@exclude_file) if @exclude_file
        @include      = @options[:include]
        @exclude_file = @options[:include_file]
        @exclude_file = File.expand_path(@include_file) if @include_file
        @delete       = @options[:delete] || false
        @pull_dir     = @options[:dir]
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

        cmd    =  "rsync "
        cmd    << "#{@flags} "
        cmd    << " -e"                               if @exclude_file || @exclude
        cmd    << " --exclude-from #{@exclude_file}"  if @exclude_file
        cmd    << " --exclude #{@exclude}"            if @exclude
        cmd    << " --include-from #{@include_file}"  if @include_file
        cmd    << " --include #{@include}"            if @include
        cmd    << " --rsh='ssh -p#{@port}'"           if @user && @port
        cmd    << " --delete "                        if @delete

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
#{"user: #{options[:user]}".ljust(40)}  # The user for your host, e.g. user@host.com
#{"remote_path: #{options[:remote_path]}".ljust(40)}  # Destination directory
#{"delete: #{options[:delete]}".ljust(40)}  # Remove files from destination which don't match files in source

#{"# flags: #{options[:flags] || '-rltDvz'}".ljust(40)}  # Modify flags as necessary to suit your hosting setup
#{"# port: #{options[:port]}".ljust(40)}  # If your host requires a non standard port
#{"# exclude: ".ljust(40)}  # Path to file containing list of files to exclude
#{"# exclude-file: ".ljust(40)}  # Path to file containing list of files to exclude
#{"# include: ".ljust(40)}  # Path to file containing list of files to include
#{"# include-file: ".ljust(40)}  # Path to file containing list of files to include
CONFIG
      end
      
    end
  end
end
