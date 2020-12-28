# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/star_mailer
class ReminderMailerPreview < ActionMailer::Preview
  include ActionView::Helpers::DateHelper

  def reminder_email
    starred_repositories = [
      {
        starredAt: Time.zone.today - 6.months,
        era: distance_of_time_in_words(Time.zone.today - 6.months, Time.zone.today),
        repository: {
          owner: 'pelya',
          name: 'commandergenius'
        }
      },
      {
        starredAt: Time.zone.today - 6.months,
        era: distance_of_time_in_words(Time.zone.today - 6.months, Time.zone.today),
        repository: {
          owner: 'kivikakk',
          name: 'koino'

        }
      },
      {
        starredAt: Time.zone.today - 1.year,
        era: distance_of_time_in_words(Time.zone.today - 1.year, Time.zone.today),
        repository: {
          owner: 'curl',
          name: 'curl'
        }
      },
      {
        starredAt: Time.zone.today - 2.years,
        era: distance_of_time_in_words(Time.zone.today - 2.years, Time.zone.today),
        repository: {
          owner: 'jekyll',
          name: 'jekyll'
        }
      }
    ]

    ReminderMailer.with(user: User.find_by(github_username: 'gjtorikian')).reminder_email('gjtorikian@somewhere.com', 'gjtorikian', starred_repositories)
  end
end
