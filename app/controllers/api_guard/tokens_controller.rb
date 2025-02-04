# frozen_string_literal: true

require_dependency 'api_guard/application_controller'

module ApiGuard
  class TokensController < ApplicationController
    before_action :authenticate_resource, only: [:create]
    before_action :find_refresh_token, only: [:create]

    def create
      create_and_set_token_pair(current_resource, resource_name)

      @refresh_token.destroy
      blacklist_token if ApiGuard.blacklist_token_after_refreshing

      render_success(message: I18n.t('api_guard.access_token.refreshed'))
    end

    private

    def find_refresh_token
      refresh_token_from_request = if ApiGuard.enable_tokens_in_cookies
                                     request.cookies['refresh_token']
                                   else
                                     request.headers['Refresh-Token']
                                   end

      if refresh_token_from_request
        @refresh_token = find_refresh_token_of(current_resource, refresh_token_from_request)
        return render_error(401, message: I18n.t('api_guard.refresh_token.invalid')) unless @refresh_token
      else
        render_error(401, message: I18n.t('api_guard.refresh_token.missing'))
      end
    end
  end
end
