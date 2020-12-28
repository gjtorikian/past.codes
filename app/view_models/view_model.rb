# frozen_string_literal: true

# An optional superclass for view models. `ViewModel` provides a
# consistent hash-based attributes initializer and access to a few
# basic Rails view modules.
#
# Be careful about adding things to this class. We're not trying to
# make a comprehensive view model framework or anything.

class ViewModel
  include ActionView::Helpers::DateHelper

  def initialize(*args); end
end
