require 'find'
require 'fileutils'
begin
  require 'aws-sdk'
rescue LoadError 
  abort "You'll need to install the aws-sdk gem to deploy with S3."
end

module Octopress
  module Deploy
    class S3

      def initialize(options)
        @local       = options[:site_dir]
        @bucket_name = options[:bucket_name]
        @access_key  = options[:access_key_id]
        @secret_key  = options[:secret_access_key]
        @delete      = options[:delete]
        @verbose     = options[:verbose] || true
        @remote_path = (options[:remote_path] || '/').sub(/^\//,'')
        @bucket = connect
      end

      def push
        puts "Syncing #{@local} files to #{@bucket_name} on S3."
        write_files
        delete_files if delete_files?
        status_message
        Deploy.check_gitignore
      end

      # Connect to S3 using the AWS SDK
      # Retuns an aws bucket
      def connect
        AWS.config(access_key_id: @access_key, secret_access_key: @secret_key)
        bucket = AWS.s3.buckets[@bucket_name]
        abort "S3 bucket '#{@bucket_name}' not found." unless bucket.exists?
        bucket
      end

      # Write site files to the selected bucket
      def write_files
        puts "Writing #{pluralize('file', site_files.size)}:" if @verbose
        site_files.each do |file| 
          o = @bucket.objects[dest_path(file)]
          o.write(file: file)
          if @verbose
            puts "+ #{dest_path(file)}"
          else
            progress('+')
          end
        end
      end

      # Delete files from the bucket, to ensure a 1:1 match with site files
      def delete_files
        if deletable_files.size > 0
          puts "Deleting #{pluralize('file', deletable_files.size)}:" if @verbose
          deletable_files.each do |file|
            @bucket.objects.delete(file)
            if @verbose
              puts "- #{file}"
            else
              progress('-')
            end
          end
        end
      end

      def delete_files?
        !!@delete
      end

      # local site files
      def site_files
        @site_files ||= Find.find(@local).to_a.reject do |f|
          File.directory?(f)
        end
      end

      # Destination paths for local site files.
      def site_files_dest
        @site_files_dest ||= site_files.map{|f| dest_path(f) }
      end

      # Replace local path with remote path
      def dest_path(file)
        File.join(@remote_path, file.sub(@local, '')).sub(/^\//, '')
      end

      # Files from the bucket which are deletable
      # Only deletes files beneath the remote_path if specified
      def deletable_files
        return [] unless delete_files?
        unless @deletable
          @deletable = @bucket.objects.map(&:key) - site_files_dest
          @deletable.reject!{|f| (f =~ /^#{@remote_path}/).nil? }
        end
        @deletable
      end

      # List written and deleted file counts
      def status_message
        uploaded = site_files.size
        deleted = deletable_files.size

        message =  "\nSuccess:".green + " #{uploaded} #{pluralize('file', uploaded)} uploaded"
        message << ", #{deleted} #{pluralize('file', deleted)} deleted."
        puts message
      end

      # Print consecutive characters
      def progress(str)
        print str
        $stdout.flush
      end

      def pluralize(str, num)
        str << 's' if num != 1
        str
      end

      # Return default configuration options for this deployment type
      def self.default_config(options={})
        config = <<-CONFIG
bucket_name: #{options[:bucket_name]}
access_key_id: #{options[:access_key_id]}
secret_access_key: #{options[:secret_access_key]}
remote_path: #{options[:remote_path] || '/'}
delete: #{options[:delete] || 'false'}
verbose: #{options[:verbose] || 'true'}
CONFIG
      end

    end
  end
end

