# frozen_string_literal: true

class SettingsController < ApplicationController
  include SessionsHelper
  include TimeHelper

  before_action :require_login

  def index; end
end
