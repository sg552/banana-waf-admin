require_relative 'boot'

require 'rails/all'

require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
include Log4r
Bundler.require(*Rails.groups)

module WafLuaAdmin
  class Application < Rails::Application
    config.load_defaults 6.0
    config.assets.initialize_on_precompile = true

    config.paths.add 'lib', eager_load: false, autoload: true
    config.paths.add 'lib/DataKeeper', eager_load: false, autoload: true

    config.i18n.enforce_available_locales = false
    config.i18n.load_path += Dir[root.join('config', 'locales', '*.{yml}')]
    config.i18n.available_locales = ['en', 'jp', 'zh', 'kr', 'ru']
    config.i18n.default_locale = :zh
    config.paths.add 'lib/Sso', eager_load: false, autoload: true
    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]

    #config.active_record.database_selector = { delay: 2.seconds }
    #config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
    #config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

    log4r_config= YAML.load_file(File.join(File.dirname(__FILE__),"log4r.yml"))
    YamlConfigurator.decode_yaml( log4r_config['log4r_config'] )
    config.logger = Log4r::Logger[Rails.env]
    config.hosts << "waf-gly.sctajik.com"

    #config.hosts.clear
    #config.hosts << "lua-gly.testcadae.top"
    Rails.logger = config.logger
    $logger = config.logger

    $redis = Redis.new url: ENV['WAF_REDIS_URL']
    $datakeeper_redis_url = Redis.new url: ENV['DATAKEEPER_REDIS_URL']
  end
end


