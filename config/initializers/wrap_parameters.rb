# Be sure to restart your server when you modify this file.

# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Disable parameter wrapping for JSON. フラットなパラメータのまま扱う
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: []
end

