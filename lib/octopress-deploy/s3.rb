require 'find'
require 'fileutils'

module Octopress
  module Deploy
    class S3

      def initialize(options)
        begin
          require 'aws-sdk-v1'
        rescue LoadError
          abort "Deploying to S3 requires the aws-sdk-v1 gem. Install with `gem install aws-sdk-v1`."
        end
        @options     = options
        @local       = options[:site_dir]          || '_site'
        @bucket_name = options[:bucket_name]
        @access_key  = options[:access_key_id]     || ENV['AWS_ACCESS_KEY_ID']
        @secret_key  = options[:secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY']
        @region      = options[:region]            || ENV['AWS_DEFAULT_REGION'] || 'us-east-1'
        @distro_id   = options[:distribution_id]   || ENV['AWS_DISTRIBUTION_ID']
        @remote_path = (options[:remote_path]      || '/').sub(/^\//,'')
        @verbose     = options[:verbose]
        @incremental = options[:incremental]
        @delete      = options[:delete]
        @headers     = options[:headers]           || []
        @remote_path = @remote_path.sub(/^\//,'')  # remove leading slash
        @pull_dir    = options[:dir]
        @bust_cache_files = []
        @thread_pool = []
        connect
      end

      def push
        #abort "Seriously, you should. Quitting..." unless Deploy.check_gitignore
        @bucket = @s3.buckets[@bucket_name]
        if !@bucket.exists?
          abort "Bucket not found: '#{@bucket_name}'. Check your configuration or create a bucket using: `octopress deploy add-bucket`"
        else
          if File.exist?(@local)
            puts "Syncing #{@local} files to #{@bucket_name} on S3."
            write_files
            delete_files if delete_files?
            status_message
          else
            abort "Cannot find site build at #{@local}. Be sure to build your site first."
          end
        end
      end

      def pull
        @bucket = @s3.buckets[@bucket_name]
        if !@bucket.exists?
          abort "Bucket not found: '#{@bucket_name}'. Check your configuration or create a bucket using: `octopress deploy add-bucket`"
        else
          puts "Syncing from S3 bucket: '#{@bucket_name}' to #{@pull_dir}."
          @bucket.objects.each do |object|
            path = File.join(@pull_dir, object.key)

            # Path is a directory, not a file
            if path =~ /\/$/ 
              FileUtils.mkdir_p(path) unless File.directory?(path)
            else
              dir = File.dirname(path)
              FileUtils.mkdir_p(dir) unless File.directory?(dir)
              File.open(path, 'w') { |f| f.write(object.read) }
            end
          end
        end
      end

      # Connect to S3 using the AWS SDK
      # Retuns an aws bucket
      #
      def connect
        AWS.config(access_key_id: @access_key, secret_access_key: @secret_key, region: @region)
        @s3 = AWS.s3
        @cloudfront = AWS.cloud_front.client
      end

      # Write site files to the selected bucket
      #
      def write_files
        puts "Writing #{pluralize('file', site_files.size)}#{" (sequential mode)" unless parallel_upload?}:" if @verbose
        @bust_cache_files = []

        site_files.each do |file|
          if parallel_upload?
            threaded { write_file file }
          else
            write_file file
          end
        end

        @thread_pool.each(&:join)
        bust_cloudfront_cache
      end

      def write_file file
        if write_file? file
          s3_upload_file file
          @bust_cache_files << file
          @verbose ? puts("+ #{remote_path(file)}") : progress('+')
        else
          @verbose ? puts("= #{remote_path(file)}") : progress('=')
        end
      end

      def s3_upload_file file
        s3_object(file).write File.open(file), s3_object_options(file)
      end

      def bust_cloudfront_cache
        return if @distro_id.nil?

        puts "Invalidating cache for #{pluralize('file', site_files.size)}" if @verbose
        @cloudfront.create_invalidation(
          distribution_id: @distro_id, 
          invalidation_batch:{
            paths:{
              quantity: @bust_cache_files.size,
              items: @bust_cache_files.map{|file| "/" + remote_path(file)}
            },
            # String of 8 random chars to uniquely id this invalidation
            caller_reference: (0...8).map { ('a'..'z').to_a[rand(26)] }.join
          }
        ) unless @bust_cache_files.empty?
        @bust_cache_files = []
      end

      def s3_object_options(file)
        s3_filename = remote_path file
        s3_options = { :acl => :public_read }

        @headers.each do |conf|
          if conf.has_key? 'filename' and s3_filename.match(conf['filename'])
            if @verbose
              puts "+ #{s3_filename} matched pattern #{conf['filename']}"
            end

            if conf.has_key? 'expires'
              expireDate = conf['expires']

              relative_years = /^\+(\d+) year(s)?$/.match(conf['expires'])
              if relative_years
                expireDate = (Time.now + (60 * 60 * 24 * 365 * relative_years[1].to_i)).httpdate
              end

              relative_days = /^\+(\d+) day(s)?$/.match(conf['expires'])
              if relative_days
                expireDate = (Time.now + (60 * 60 * 24 * relative_days[1].to_i)).httpdate
              end

              s3_options[:expires] = expireDate
            end

            if conf.has_key? 'content_type'
              s3_options[:content_type] = conf['content_type']
            end

            if conf.has_key? 'cache_control'
              s3_options[:cache_control] = conf['cache_control']
            end

            if conf.has_key? 'content_encoding'
              s3_options[:content_encoding] = conf['content_encoding']
            end
          end
        end

        s3_options
      end

      # Delete files from the bucket, to ensure a 1:1 match with site files
      #
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

      # Create a new S3 bucket
      #
      def add_bucket
        puts @bucket_name
        @bucket = @s3.buckets.create(@bucket_name)
        puts "Created new bucket '#{@bucket_name}' in region '#{@region}'."
        configure_bucket
      end

      def configure_bucket
        error_page = @options['error_page'] || remote_path('404.html')
        index_page = @options['index_page'] || remote_path('index.html')

        config = @bucket.configure_website do |cfg|
          cfg.index_document_suffix = index_page
          cfg.error_document_key = error_page
        end
        puts "Bucket configured with index_document: #{index_page} and error_document: #{error_page}."
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
        @site_files_dest ||= site_files.map{|f| remote_path(f) }
      end

      # Replace local path with remote path
      def remote_path(file)
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
        configure_bucket unless @bucket.website?
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
        <<-CONFIG
#{"bucket_name: #{options[:bucket_name]}".ljust(40)}  # Name of the S3 bucket where these files will be stored.
#{"access_key_id: #{options[:access_key_id]}".ljust(40)}  # Get this from your AWS console at aws.amazon.com.
#{"secret_access_key: #{options[:secret_access_key]}".ljust(40)}  # Keep it safe; keep it secret. Keep this file in your .gitignore.
#{"distribution_id: #{options[:distribution_id]}".ljust(40)}  # Get this from your CloudFront page at https://console.aws.amazon.com/cloudfront/
#{"remote_path: #{options[:remote_path] || '/'}".ljust(40)}  # relative path on bucket where files should be copied.
#{"region: #{options[:remote_path] || 'us-east-1'}".ljust(40)}  # Region where your bucket is located.
#{"verbose: #{options[:verbose] || 'false'}".ljust(40)}  # Print out all file operations.
#{"incremental: #{options[:incremental] || 'false'}".ljust(40)}  # Only upload new/changed files
#{"delete: #{options[:delete] || 'false'}".ljust(40)}  # Remove files from destination which do not match source files.
#{"parallel: #{options[:parallel] || 'true'}".ljust(40)}  # Speed up deployment by uploading files in parallel.
CONFIG
      end

    protected

      def write_file? file
        return true unless @incremental

        file_digest = Digest::MD5.file(file).hexdigest
        o = s3_object file
        s3sum = o.etag.tr('"','') if o.exists?
        s3sum.to_s != file_digest
      end

      def s3_object file
        s3_filename = remote_path file
        @bucket.objects[s3_filename]
      end

      def parallel_upload?
        @options[:parallel]
      end

      def threaded &blk
        @thread_pool << Thread.new(blk) do |operation|
          operation.call
        end
      end

    end
  end
end
