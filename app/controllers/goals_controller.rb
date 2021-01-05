class GoalsController < AdminController
  HEX = '[0-9a-v]'.freeze
  def decode32hex(str)
    str.gsub(/\G\s*(#{HEX}{8}|#{HEX}{7}=|#{HEX}{5}={3}|#{HEX}{4}={4}|#{HEX}{2}={6}|(\S))/imno) do
      raise 'invalid base32' if $2

      s = $1
      s.tr('=', '0').to_i(32).divmod(256).pack("NC")[0,(s.count("^=")*5).div(8)]
    end
  end

  def find_goal
    @goal = @care_plan.goals.find(params[:id])
  end

  def authorize_client
    authorize @client, :create?
  end
end
