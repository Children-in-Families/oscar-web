_ = ::ActionDispatch::Session::ActiveRecordStore
module ActionDispatch
  module Session
    class ActiveRecordStore
      def get_session_model(request, id)
        logger.silence_logger do
          model = @@session_class.find_by_session_id(id)
          if !model
            id ||= generate_sid # id = generate_sid
            model = @@session_class.new(:session_id => id, :data => {})
            model.save
          end
          if request.env[ENV_SESSION_OPTIONS_KEY][:id].nil?
            request.env[SESSION_RECORD_KEY] = model
          else
            request.env[SESSION_RECORD_KEY] ||= model
          end
          model
        end
      end
    end
  end
end
