class SettingsController < ApplicationController

  def edit
    authorize! :edit, Settings
    @setting_values = SettingValue.all
  end

  def update
    authorize! :update, Settings
    @setting_values = SettingValue.update(params[:setting_value].keys, params[:setting_value].values).reject { |p| p.errors.empty? }
    if @setting_values.empty?
      flash[:notice] = 'Settings updated.'
      redirect_to edit_settings_path
    else
      flash[:error] = 'Some settings could not be updated.'
      render :action => 'edit'
    end
  end

end