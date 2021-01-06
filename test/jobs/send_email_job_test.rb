# frozen_string_literal: true

require 'test_helper'

class SendEmailJobTest < ActiveJob::TestCase
  include AuthHelper

  def setup
    @user = users(:good_user)
    @encrypted_github_token = auth_encrypt('secretztoken')
    @user.encrypted_github_token = @encrypted_github_token
    @user.save
  end

  test 'it prepares an email' do
    starred_repos_basic = file_fixture('starred_repos_basic.json').read
    stub_get_starred_repos(starred_repos_basic)

    assert_called_on_instance_of(ReminderMailer, :reminder_email, times: 1) do
      SendEmailJob.perform_now(@user, frequency: :weekly)
    end
  end

  test 'it can paginate' do
    starred_repos_file_page_one = file_fixture('starred_repos_page_1.json').read
    starred_repos_file_page_two = file_fixture('starred_repos_page_2.json').read
    stub_get_starred_repos(starred_repos_file_page_one)
    stub_get_starred_repos(starred_repos_file_page_two, pagination_query: true)

    # notice the map is called twice now (we don't care as much about the return values)
    assert_called_on_instance_of(GraphQL::Client::List, :map, times: 2, returns: []) do
      SendEmailJob.perform_now(@user, frequency: :weekly)
    end
  end

  test 'it does not blow up on empty repos' do
    starred_repos_empty = file_fixture('starred_repos_empty.json').read
    stub_get_starred_repos(starred_repos_empty)

    assert_called_on_instance_of(ReminderMailer, :reminder_email, times: 0) do
      SendEmailJob.perform_now(@user, frequency: :weekly)
    end
  end
end
