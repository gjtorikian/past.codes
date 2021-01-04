# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Pastcodes <no-reply@past.codes>'
  layout 'mailer'
end
