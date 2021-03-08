require "flipper/cloud"
require "flipper/adapters/active_record"

# For dev:
#   FLIPPER_CLOUD_TOKEN=<your-personal-env-token>
#
# For production:
#   FLIPPER_CLOUD_TOKEN=<production-token>
#   FLIPPER_CLOUD_SYNC_METHOD=webhooks
#   FLIPPER_CLOUD_SYNC_SECRET=<webhook sync secret>
Flipper.configure do |config|
  config.default do
    Flipper::Cloud.new do |cloud|
      cloud.instrumenter = ActiveSupport::Notifications
      cloud.local_adapter = Flipper::Adapters::ActiveRecord.new
    end
  end
end

# Memoize Flipper adapter calls per request
require "flipper/middleware/memoizer"
Rails.configuration.middleware.use Flipper::Middleware::Memoizer, preload_all: true
