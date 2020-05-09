require_relative 'config/boot'
require 'lamby'

ENV['RAILS_MASTER_KEY'] =
  Lamby::SsmParameterStore.get!('/config/lamby_rails/env/RAILS_MASTER_KEY')

require_relative 'config/application'
require_relative 'config/environment'

$app = Rack::Builder.new { run Rails.application }.to_app

def handler(event:, context:)
  Lamby.handler $app, event, context, rack: :http
end
