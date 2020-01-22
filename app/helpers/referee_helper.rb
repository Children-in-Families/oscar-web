module RefereeHelper
  def address_type
    [Referee::ADDRESS_TYPES.map(&:downcase).sort, I18n.t('referee_attr.address_types').values].transpose.to_h
  end
end
