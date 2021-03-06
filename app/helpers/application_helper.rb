# frozen_string_literal: true

module ApplicationHelper
  def svg(name)
    file_path = Rails.root.join('app', 'assets', 'images', "#{name}.svg")
    if File.exist?(file_path)
      File.read(file_path).html_safe # rubocop:disable Rails/OutputSafety
    else
      '(not found)'
    end
  end
end
