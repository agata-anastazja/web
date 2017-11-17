class CreateStaffReminderHistories < ActiveRecord::Migration
  def change
    create_table :staff_reminder_histories do |t|
      t.integer :user_id
      t.string :email

      t.timestamps null: false
    end
  end
end
