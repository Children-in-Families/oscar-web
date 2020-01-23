module RefereeHelper
  def address_type
    [Referee::ADDRESS_TYPES.map(&:downcase).sort, Client::ADDRESS_TYPES.map{|type| I18n.t('default_client_fields.client_address_types')[type.downcase.to_sym] }].transpose.to_h
  end
end
