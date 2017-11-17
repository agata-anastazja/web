class StaffReminder < ActiveRecord::Base
  validates :email, :frequency, presence: true
  validates :last_id, :frequency, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  before_validation :set_default_last_id

  def due?(time = Time.now)
    self.last_run_at.nil? || (self.last_run_at < (time - self.frequency.hours))
  end

  def next_reminder


    StaffReminderHistory.create       ({email: self.email, user_id: self.last_id})
    user_to_contact                   = User.find(self.last_id)    
    user_to_contact.last_contacted    = Time.now
    user_to_contact.last_contacted_by = self.email
    user_to_contact.increment(:times_introduced)
    #Updates the next person to contact but it can overridden manually (side note - it's referred to as last_id but in fact now relates to the next person)
    next_user                         = return_next_user
    self.last_id                      = next_user.id
    self.last_run_at                  = Time.now
    self.save!
    # Return the User model to be contacted
    user_to_contact

  end

  def pop!
    new_id = self.last_id
    max_id = User.maximum('id')
    loops  = 0

    begin
      new_id = new_id + 1

      if new_id > max_id
        loops  = loops + 1
        new_id = 1
      end

      next_user = User.find(new_id)

      raise UnwantedUser unless next_user.eligible_for_reminders?
    rescue ActiveRecord::RecordNotFound, UnwantedUser
      return nil if loops > 2
      retry
    end

    self.last_id     = new_id
    self.last_run_at = Time.now
    self.save!

    next_user
  end

  private

  def return_next_user
    User.select("*, greatest (times_introduced, 1) / greatest(1 ,(DATE_PART('day', '#{Time.now.to_s}'::timestamp - created_at))) as ratio").order("ratio desc").limit(1).member
  end

  def set_default_last_id
    if self.last_id.blank?
      self.last_id = return_next_user.id
    end
  end

  class UnwantedUser < StandardError
  end
end
