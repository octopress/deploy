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
        @bucket      = options[:bucket]
        @access_key  = options[:access_key_id]
        @secret_key  = options[:secret_access_key]
        @delete      = options[:delete]
        @verbose     = options[:verbose] || true
        Deploy.check_gitignore
      end

      def push
        AWS.config(access_key_id: @access_key, secret_access_key: @secret_key)
        s3 = AWS.s3
        bucket = s3.buckets[@bucket]
        abort "Bucket #{@bucket} not found" unless bucket.exists?
        FileUtils.cd @local do
          local_files = Find.find('.').to_a.map {|i| i.sub('./','')}
          local_files.reject!{|f| File.directory?(f)}

          puts "Syncing #{@local} files to #{@bucket} on S3."

          local_files.each do |file|
            o = bucket.objects[file]
            o.write(file: file)
            if @verbose
              puts file
            else
              progress
            end
          end

          if @delete
            deletable = bucket.objects.map(&:key) - local_files
            if deletable.size > 0
              puts "Deleting #{pluralize('file', deletable.size)}:" if @verbose
              deletable.each do |file|
                bucket.objects.delete(file)
                puts file
              end
            end
          end

          uploaded = local_files.size
          deleted = deletable.size

          message =  "\nSuccess:".green + " #{uploaded} #{pluralize('file', uploaded)} uploaded"
          message << ", #{deleted} #{pluralize('file', deleted)} deleted." if @delete
          puts message.green
        end
      end

      def pluralize(str, num)
        str << 's' if num == 0 || num > 1
        str
      end
      def progress
        print '.'
        $stdout.flush
      end

      def self.default_config(options={})
        config = <<-CONFIG
bucket: #{options[:bucket]}
access_key_id: #{options[:access_key_id]}
secret_access_key: #{options[:secret_access_key]}
delete: #{options[:delete] || 'false'}
verbose: #{options[:verbose] || 'true'}
CONFIG
      end

    end
  end
end

