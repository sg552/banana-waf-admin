require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'
require 'json'

devices = UserBehavier.group(:user_agent)
p devices.count
