module Api
  class BaseApiController < ApplicationController
    protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

    private

    def connect_db
      server = CouchRest.new('http://127.0.0.1:5984')
      @remote_temp_db    = server.database!('cif_change_log')
    end
  end
end
