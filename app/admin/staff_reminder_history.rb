ActiveAdmin.register StaffReminderHistory do

  config.filters = false

  permit_params :user_id, :email

  index do
    column :email

    column :member do |r|
      begin
        User.find(r.user_id).name
      rescue ActiveRecord::RecordNotFound
        "Nothing to see here"
      end
    end
  end
end
