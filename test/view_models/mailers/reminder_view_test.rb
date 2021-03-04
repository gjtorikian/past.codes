# frozen_string_literal: true

class Mailers::ReminderViewTest < ActiveSupport::TestCase
  include TimeHelper

  def setup
    @today = Date.new(2020, 12, 28)
    @starred_repositories = [
      {
        starred_at: @today - 1.month,
        era: '6 months',
        repository: {
          owner: 'gjtorikian',
          name: 'newest'
        }
      },
      {
        starred_at: @today - 5.years,
        era: '5 years',
        repository: {
          owner: 'gjtorikian',
          name: 'oldest'
        }
      },
      {
        starred_at: @today - 6.months,
        era: '6 months',
        repository: {
          owner: 'pelya',
          name: 'commandergenius'
        }
      },
      {
        starred_at: @today - 1.year,
        era: '1 year',
        repository: {
          owner: 'curl',
          name: 'curl'
        }
      },
      {
        starred_at: @today - 6.months,
        era: '6 months',
        repository: {
          owner: 'kivikakk',
          name: 'koino'

        }
      },
      {
        starred_at: @today - 2.years,
        era: '2 years',
        repository: {
          owner: 'jekyll',
          name: 'jekyll'
        }
      }
    ]
    @view = Mailers::ReminderView.new('gjtorikian', @starred_repositories, has_public_repo_scope: false, frequency: :weekly)
  end

  test 'it sorts repos by starred at' do
    dates = @view.sort_by_starred_at!.map { |r| r[:starred_at].to_s }
    assert_equal %w[2020-11-28 2020-06-28 2020-06-28 2019-12-28 2018-12-28 2015-12-28], dates
  end

  test 'it adds eras to repos' do
    Timecop.freeze(@today) do
      @view.sort_by_starred_at!
      assert_equal 6, @starred_repositories.length

      eras = @view.append_era!.pluck(:era)
      assert_equal 5, eras.length # dates less than 6 months are dropped!

      assert_equal ['6 months', '6 months', '1 year', '2 years', '5 years'], eras
    end
  end

  test 'it can filter on weekly frequency' do
    starred_repositories = [
      {
        starred_at: @today - 6.days, # within weekly
        repository: {
          owner: 'gjtorikian',
          name: 'back 6 days'
        }
      },
      {
        starred_at: @today - 7.months - 3.days, # within weekly
        repository: {
          owner: 'gjtorikian',
          name: 'back 7 months and 3 days'
        }
      },
      {
        starred_at: @today - 5.years - 3.days, # within weekly
        repository: {
          owner: 'gjtorikian',
          name: 'back 5 years months and 3 days'
        }
      },
      {
        starred_at: @today - 8.days, # not within weekly
        repository: {
          owner: 'baddy',
          name: 'back 8 days'
        }
      },
      {
        starred_at: @today + 2.days, # not within weekly
        repository: {
          owner: 'baddy',
          name: 'up 2 days'
        }
      },
      {
        starred_at: @today - 2.months - 10.days, # not within weekly
        repository: {
          owner: 'baddy',
          name: 'back two months and 10 days'
        }
      },
      {
        starred_at: @today - 9.days, # not within weekly
        repository: {
          owner: 'baddy',
          name: 'back 9 days'
        }
      }
    ]

    Timecop.freeze(@today) do
      view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false, frequency: :weekly)

      descriptions = view.filter_by_starred_at!

      assert(descriptions.map { |h| h.dig :repository, :owner }.all?('gjtorikian'))
    end
  end

  test 'it can filter on monthly frequency' do
    starred_repositories = [
      {
        starred_at: @today - 6.days, # within monthly
        repository: {
          owner: 'gjtorikian',
          name: 'back 6 days'
        }
      },
      {
        starred_at: @today - 5.years - 3.days, # within monthly
        repository: {
          owner: 'gjtorikian',
          name: 'back 5 years months and 3 days'
        }
      },
      {
        starred_at: @today - 8.days, # within monthly
        repository: {
          owner: 'gjtorikian',
          name: 'back 8 days'
        }
      },
      {
        starred_at: @today - 7.months - 3.days, # not within monthly
        repository: {
          owner: 'baddy',
          name: 'back 7 months and 3 days'
        }
      },
      {
        starred_at: @today + 2.days, # not within monthly
        repository: {
          owner: 'baddy',
          name: 'up 2 days'
        }
      },
      {
        starred_at: @today - 2.months - 10.days, # not within monthly
        repository: {
          owner: 'baddy',
          name: 'back two months and 10 days'
        }
      },
      {
        starred_at: @today - 9.days, # within monthly
        repository: {
          owner: 'gjtorikian',
          name: 'back 9 days'
        }
      }
    ]

    Timecop.freeze(@today) do
      view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false, frequency: :monthly)

      descriptions = view.filter_by_starred_at!

      assert(descriptions.map { |h| h.dig :repository, :owner }.all?('gjtorikian'))
    end
  end

  test 'it can handle descriptions' do
    starred_repositories = [
      {
        starred_at: @today - 3.days,
        repository: {
          owner: 'gjtorikian',
          name: 'newest',
          description: 'Something great!'
        }
      },
      {
        starred_at: @today - 3.days,
        repository: {
          owner: 'gjtorikian',
          name: 'oldest',
          description: 'Another repo'
        }
      },
      {
        starred_at: @today - 3.days,
        repository: {
          owner: 'gjtorikian',
          name: 'no desc'
        }
      },
      {
        starred_at: @today - 3.days,
        repository: {
          owner: 'gjtorikian',
          name: 'null desc',
          description: nil
        }
      },
      {
        starred_at: @today - 3.days,
        repository: {
          owner: 'gjtorikian',
          name: 'blank desc',
          description: ''
        }
      }
    ]

    view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false, frequency: :weekly)

    descriptions = view.assemble_descriptions!.map { |h| h.dig :repository, :full_description }.filter(&:present?)

    assert_equal ['Something great.', 'Another repo.'], descriptions
  end

  test 'it can handle languages' do
    starred_repositories = [
      {
        starred_at: @today - 1.day,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with desc and language',
          description: 'Some great project.',
          primary_language: OpenStruct.new(name: 'Ruby')
        }
      },
      {
        starred_at: @today - 1.day,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with no desc, but language',
          primary_language: OpenStruct.new(name: 'Rust')
        }
      }
    ]
    view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false, frequency: :weekly)
    descriptions = view.assemble_descriptions!.map { |h| h.dig :repository, :full_description }.filter(&:present?)

    assert_equal ['Some great project. It appears to be written in Ruby.', 'It appears to be written in Rust.'], descriptions
  end

  test 'it can handle funding links' do
    starred_repositories = [
      {
        starred_at: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with desc, language, and funding links',
          description: 'Some amazing project!!',
          primary_language: OpenStruct.new(name: 'Rust'),
          funding_links: [
            {
              platform: 'GITHUB',
              url: 'https://github.com/gjtorikian'
            },
            {
              platform: 'OPEN_COLLECTIVE',
              url: 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      },
      {
        starred_at: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with no desc, but language and funding links',
          primary_language: OpenStruct.new(name: 'PHP'),
          funding_links: [
            {
              platform: 'GITHUB',
              url: 'https://github.com/gjtorikian'
            },
            {
              platform: 'OPEN_COLLECTIVE',
              url: 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      },
      {
        starred_at: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with no desc, no language, but funding links',
          funding_links: [
            {
              platform: 'GITHUB',
              url: 'https://github.com/gjtorikian'
            },
            {
              platform: 'OPEN_COLLECTIVE',
              url: 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      },
      {
        starred_at: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with desc, no language, but funding links',
          description: 'No language, folks.',
          funding_links: [
            {
              platform: 'GITHUB',
              url: 'https://github.com/gjtorikian'
            },
            {
              platform: 'OPEN_COLLECTIVE',
              url: 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      }
    ]
    view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false, frequency: :weekly)
    descriptions = view.assemble_descriptions!.map { |h| h.dig :repository, :full_description }.filter(&:present?)

    assert_equal ["Some amazing project. It appears to be written in Rust. They're looking for sponsors!", \
                  "It appears to be written in PHP. They're looking for sponsors!", \
                  "They're looking for sponsors!", \
                  "No language, folks. They're looking for sponsors!"], descriptions
  end

  test 'it can handle weekly updates' do
    updates = [
      {
        date: format_time(@today - 1.day),
        message: 'Good news!',
        link: 'https://github.com/gjtorikian/past.codes'
      },
      {
        date: format_time(@today - 6.days),
        message: 'Good news!',
        link: 'https://github.com/gjtorikian/past.codes'
      },
      {
        date: format_time(@today - 10.days),
        message: 'Bad news!',
        link: 'https://github.com/gjtorikian/past.codes'
      }
    ]

    Timecop.freeze(@today) do
      view = Mailers::ReminderView.new('gjtorikian', [], has_public_repo_scope: false, frequency: :weekly)

      view.stub :updates, updates do
        assert(view.new_updates.all? { |u| u[:message] == 'Good news!' })
      end
    end
  end

  test 'it can handle monthly updates' do
    updates = [
      {
        date: format_time(@today - 6.days),
        message: 'Good news!',
        link: 'https://github.com/gjtorikian/past.codes'
      },
      {
        date: format_time(@today - 5.years - 4.days),
        message: 'Good news!',
        link: 'https://github.com/gjtorikian/past.codes'
      },
      {
        date: format_time(@today - 2.months - 10.days),
        message: 'Bad news!',
        link: 'https://github.com/gjtorikian/past.codes'
      }
    ]

    Timecop.freeze(@today) do
      view = Mailers::ReminderView.new('gjtorikian', [], has_public_repo_scope: false, frequency: :monthly)

      view.stub :updates, updates do
        assert(view.new_updates.all? { |u| u[:message] == 'Good news!' })
      end
    end
  end
end
