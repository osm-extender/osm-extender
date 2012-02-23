ActionDispatch::Callbacks.to_prepare do
  Settings.setup if SettingValue.table_exists?
end