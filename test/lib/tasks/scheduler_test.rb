# frozen_string_literal: true

require 'rake'

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

  test 'queues for valid weekly' do
    t = Time.zone.local(2020, 12, 7, 12, 0, 0)
    Timecop.freeze(t) do
      assert_enqueued_with(job: SendEmailJob) do
        Rake::Task['scheduler:weekly_delivery'].invoke
      end
      assert_enqueued_jobs @weekly_users.count
    end
  end

  test 'does nothing for invalid weekly' do
    t = Time.zone.local(2020, 12, 8, 12, 0, 0)
    Timecop.freeze(t) do
      Rake::Task['scheduler:weekly_delivery'].invoke
      assert_enqueued_jobs 0
    end
  end

  test 'queues for valid monthly' do
    t = Time.zone.local(2020, 12, 1, 12, 0, 0)
    Timecop.freeze(t) do
      assert_enqueued_with(job: SendEmailJob) do
        Rake::Task['scheduler:monthly_delivery'].invoke
      end
      assert_enqueued_jobs @monthly_users.count
    end
  end

  test 'does nothing for invalid monthly' do
    t = Time.zone.local(2020, 11, 30, 12, 0, 0)
    Timecop.freeze(t) do
      Rake::Task['scheduler:monthly_delivery'].invoke
      assert_enqueued_jobs 0
    end
  end
end
