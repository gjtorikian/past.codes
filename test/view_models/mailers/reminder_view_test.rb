# frozen_string_literal: true

class Mailers::ReminderViewTest < ActiveSupport::TestCase
  def setup
    @today = Date.new(2020, 12, 28)
    @starred_repositories = [
      {
        starredAt: @today - 1.month,
        era: '6 months',
        repository: {
          owner: 'gjtorikian',
          name: 'newest'
        }
      },
      {
        starredAt: @today - 5.years,
        era: '5 years',
        repository: {
          owner: 'gjtorikian',
          name: 'oldest'
        }
      },
      {
        starredAt: @today - 6.months,
        era: '6 months',
        repository: {
          owner: 'pelya',
          name: 'commandergenius'
        }
      },
      {
        starredAt: @today - 1.year,
        era: '1 year',
        repository: {
          owner: 'curl',
          name: 'curl'
        }
      },
      {
        starredAt: @today - 6.months,
        era: '6 months',
        repository: {
          owner: 'kivikakk',
          name: 'koino'

        }
      },
      {
        starredAt: @today - 2.years,
        era: '2 years',
        repository: {
          owner: 'jekyll',
          name: 'jekyll'
        }
      }
    ]
    @view = Mailers::ReminderView.new('gjtorikian', @starred_repositories, has_public_repo_scope: false)
  end

  test 'it sorts repos by starred at' do
    dates = @view.sort_by_starred_at!.map { |r| r[:starredAt].to_s }
    assert_equal %w[2020-06-28 2020-06-28 2019-12-28 2018-12-28 2015-12-28], dates
  end

  test 'it adds eras to repos' do
    assert_equal 6, @starred_repositories.length
    eras = @view.starred_repositories.pluck(:era)
    assert_equal 5, eras.length # dates less than 6 months are dropped!
    assert_equal ['6 months', '6 months', '1 year', '2 years', '5 years'], eras
  end

  test 'it can handle descriptions' do
    starred_repositories = [
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'newest',
          description: 'Something great!'
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'oldest',
          description: 'Another repo'
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'no desc'
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'null desc',
          description: nil
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'blank desc',
          description: ''
        }
      }
    ]

    view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false)

    descriptions = view.assemble_descriptions!.map { |h| h.dig :repository, :full_description }.filter(&:present?)

    assert_equal ['Something great.', 'Another repo.'], descriptions
  end

  test 'it can handle languages' do
    starred_repositories = [
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with desc and language',
          description: 'Some great project.',
          primary_language: OpenStruct.new(name: 'Ruby')
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with no desc, but language',
          primary_language: OpenStruct.new(name: 'Rust')
        }
      }
    ]
    view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false)
    descriptions = view.assemble_descriptions!.map { |h| h.dig :repository, :full_description }.filter(&:present?)

    assert_equal ['Some great project. It appears to be written in Ruby.', 'It appears to be written in Rust.'], descriptions
  end

  test 'it can handle funding links' do
    starred_repositories = [
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with desc, language, and funding links',
          description: 'Some amazing project!!',
          primary_language: OpenStruct.new(name: 'Rust'),
          funding_links: [
            {
              "platform": 'GITHUB',
              "url": 'https://github.com/gjtorikian'
            },
            {
              "platform": 'OPEN_COLLECTIVE',
              "url": 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with no desc, but language and funding links',
          primary_language: OpenStruct.new(name: 'PHP'),
          funding_links: [
            {
              "platform": 'GITHUB',
              "url": 'https://github.com/gjtorikian'
            },
            {
              "platform": 'OPEN_COLLECTIVE',
              "url": 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with no desc, no language, but funding links',
          funding_links: [
            {
              "platform": 'GITHUB',
              "url": 'https://github.com/gjtorikian'
            },
            {
              "platform": 'OPEN_COLLECTIVE',
              "url": 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      },
      {
        starredAt: @today - 8.months,
        repository: {
          owner: 'gjtorikian',
          name: 'repo with desc, no language, but funding links',
          description: 'No language, folks.',
          funding_links: [
            {
              "platform": 'GITHUB',
              "url": 'https://github.com/gjtorikian'
            },
            {
              "platform": 'OPEN_COLLECTIVE',
              "url": 'https://opencollective.com/garen-torikian'
            }
          ]
        }
      }
    ]
    view = Mailers::ReminderView.new('gjtorikian', starred_repositories, has_public_repo_scope: false)
    descriptions = view.assemble_descriptions!.map { |h| h.dig :repository, :full_description }.filter(&:present?)

    assert_equal ["Some amazing project. It appears to be written in Rust. They're looking for sponsors!", \
                  "It appears to be written in PHP. They're looking for sponsors!", \
                  "They're looking for sponsors!", \
                  "No language, folks. They're looking for sponsors!"], descriptions
  end
end
