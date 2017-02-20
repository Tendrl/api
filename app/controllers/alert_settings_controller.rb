class AlertSettingsController < AuthenticatedUsersController

  before '/alert_settings/*' do
    halt 403 unless admin_user?
  end

  get '/alert_settings' do
    AlertSettingPresenter.single(Tendrl::AlertSetting.find).to_json
  end

  put '/alert_settings' do
    body = request.body.read
    attributes = JSON.parse(body).symbolize_keys
    Tendrl::AlertSetting.save(attributes)
    AlertSettingPresenter.single(Tendrl::AlertSetting.find).to_json
  end

end
