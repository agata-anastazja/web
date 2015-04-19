class ConnectionsController < ApplicationController
  before_filter :authenticate_user!

  def create
    auth = request.env['omniauth.auth']
    connection = Connection.find_or_create_by(provider: auth['provider'], uid: auth['uid'])

    connection.access_token = auth['credentials']['token']
    connection.secret       = auth['credentials']['secret']
    connection.expires_at   = auth['credentials']['expires_at']
    connection.user         = current_user
    connection.save!

    redirect_to dashboard_path, notice: 'Successfully connected account'
  end

  def failure
    redirect_to dashboard_path, alert: 'There was a problem authenticating you'
  end

  def check_friends
    service = CheckFriendsService.new
    service.call(current_user)

    redirect_to dashboard_path, notice: 'Checked your friends, here are the results'
  end
end
