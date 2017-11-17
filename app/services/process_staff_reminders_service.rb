class ProcessStaffRemindersService
  def call
    StaffReminder.active.find_each do |r|
      next unless r.due?(Time.now)

      #m = r.pop!
      m = r.next_reminder
      AdminMailer.staff_reminder_email(r, m).deliver_later unless m.nil?
    end
  end
end
