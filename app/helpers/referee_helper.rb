module RefereeHelper
  def address_type
    [Referee::ADDRESS_TYPES.map(&:downcase).sort, Referee::ADDRESS_TYPES.map{|type| I18n.t('referee_attr.address_types')[type.downcase.to_sym] }].transpose.to_h
  end
end
