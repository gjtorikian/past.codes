# frozen_string_literal: true

class UsersController < ApplicationController
  def new; end

  def update
    current_user.update(frequency: params[:delivery_type])
    redirect_to '/settings'
  end
end
