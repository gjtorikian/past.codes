# frozen_string_literal: true

class Mailers::ReminderViewTest < ActiveSupport::TestCase
  def setup
    today = Date.new(2020, 12, 28)
    @starred_repositories = [
      {
        starredAt: today - 1.month,
        era: '6 months',
        repository: {
          owner: 'gjtorikian',
          name: 'newest'
        }
      },
      {
        starredAt: today - 5.years,
        era: '2 years',
        repository: {
          owner: 'gjtorikian',
          name: 'oldest'
        }
      },
      {
        starredAt: today - 6.months,
        era: '6 months',
        repository: {
          owner: 'pelya',
          name: 'commandergenius'
        }
      },
      {
        starredAt: today - 1.year,
        era: '1 year',
        repository: {
          owner: 'curl',
          name: 'curl'
        }
      },
      {
        starredAt: today - 6.months,
        era: '6 months',
        repository: {
          owner: 'kivikakk',
          name: 'koino'

        }
      },
      {
        starredAt: today - 2.years,
        era: '2 years',
        repository: {
          owner: 'jekyll',
          name: 'jekyll'
        }
      }
    ]
    @view = Mailers::ReminderView.new('gjtorikian', @starred_repositories)
  end

  test 'it sorts repos by starred at' do
    assert_equal 6, @starred_repositories.length
    dates = @view.starred_repositories.map { |r| r[:starredAt].to_s }
    assert_equal 5, dates.length # dates less than 6 months are dropped
    assert_equal %w[2020-06-28 2020-06-28 2019-12-28 2018-12-28 2015-12-28], dates
  end

  test 'it adds eras to repos' do
    assert_equal 6, @starred_repositories.length
    eras = @view.starred_repositories.pluck(:era)
    assert_equal 5, eras.length # dates less than 6 months are dropped
    assert_equal ['6 months', '6 months', '1 year', '2 years', '5 years'], eras
  end
end
