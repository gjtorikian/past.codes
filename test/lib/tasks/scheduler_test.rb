# frozen_string_literal: true

class SchedulerTaskTest < ActionDispatch::IntegrationTest
  def setup
    @all_users = User.all.to_a
    @weekly_users, @monthly_users = @all_users.partition { |u| u[:frequency] == 'weekly' }

    Pastcodes::Application.load_tasks if Rake::Task.tasks.empty?
  end

  test 'counts are different' do
    assert_not_equal @weekly_users.count, @all_users.count
    assert_not_equal @weekly_users.count, @monthly_users.count
    assert_not_equal @monthly_users.count, @all_users.count
    assert_equal @weekly_users.count + @monthly_users.count, @all_users.count
  end

  test 'queues for weekly' do
    assert_enqueued_with(job: SendEmailJob) do
      Rake::Task['scheduler:weekly_delivery'].invoke
    end
    assert_enqueued_jobs @weekly_users.count
  end

  test 'queues for monthly' do
    assert_enqueued_with(job: SendEmailJob) do
      Rake::Task['scheduler:monthly_delivery'].invoke
    end
    assert_enqueued_jobs @monthly_users.count
  end
end
