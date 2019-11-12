# frozen_string_literal: true

module BackupRestore
  class S3BackupStoreMark2 < BackupStore
    def initialize(opts = {})
      s3_options = S3Helper.s3_options(SiteSetting)
      s3_options.merge!(opts[:s3_options]) if opts[:s3_options]
      @s3_helper = S3Helper.new(s3_bucket_name_with_prefix, '', s3_options)
    end

    def generate_upload_url(filename)
      obj = @s3_helper.object(filename)
      # raise BackupFileExists.new if obj.exists?

      ensure_cors!
      presigned_url(obj, :put, 90) # UPLOAD_URL_EXPIRES_AFTER_SECONDS
    rescue Aws::Errors::ServiceError => e
      Rails.logger.warn("Failed to generate upload URL for S3: #{e.message.presence || e.class.name}")
      raise StorageError
    end

    def presigned_url(obj, method, expires_in_seconds)
      obj.presigned_url(method, expires_in: expires_in_seconds)
    end

    def ensure_cors!
      rule = {
        allowed_headers: ["*"],
        allowed_methods: ["PUT"],
        allowed_origins: [Discourse.base_url_no_prefix],
        max_age_seconds: 3000
      }

      @s3_helper.ensure_cors!([rule])
    end

    def s3_bucket_name_with_prefix
      if Rails.configuration.multisite
        File.join(SiteSetting.s3_backup_bucket, MULTISITE_PREFIX, RailsMultisite::ConnectionManagement.current_db)
      else
        SiteSetting.s3_upload_bucket
      end
    end
  end
end
