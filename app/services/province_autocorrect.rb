class ProvinceAutocorrect
  attr_accessor :banteay_meanchey, :battambang, :kampong_cham, :kampong_chhnang, :preah_sihanouk, :kampot, :kandal, :phnom_penh, :preah_vihear,
                :prey_veng, :ratanakiri, :siem_reap, :svay_rieng, :takeo, :oddar_meanchey, :kampong_speu, :mondulkiri, :kep

  def initialize
    @banteay_meanchey  = ['Banteay Meanchey', 'Banteaymeanchey province', 'Banteay Mean Chay  Provice', 'Banteay Meachay']
    @battambang        = %w(Battambang)
    @kampong_cham      = ['Kampong Cham', 'Kampong Chamm', 'Kompong Cham', 'Phum Kandal']
    @kampong_chhnang   = ['Kampong Chhnang', 'Kampong Chnang', 'Kampong Chhnang', 'Kampong Chhang', 'Kompong Chhnang', 'Kompongchnang', 'Kampongchnang']
    @preah_sihanouk    = ['Preah Sihanouk', 'Kampong Som']
    @kampot            = %w(Kampot Kampot)
    @kandal            = ['Kandal', 'kandal  Province', 'Kondal', 'Kien Svay']
    @phnom_penh        = ['Phnom Penh', 'Phonm Penh', 'Phom Phen', 'Phom Penh', 'Phnom Penh (steung Meanchey)']
    @preah_vihear      = ['Preah Vihear', 'Prah Vihea']
    @prey_veng         = ['Prey Veng', 'Prey veng', 'Preyveng']
    @ratanakiri        = %w(Ratanakiri Rotanakiri Ratanakiti)
    @siem_reap         = ['Siem Reap', 'Siem Reap*']
    @svay_rieng        = ['Svay Rieng', 'Svay Reing', 'Svayrieng']
    @takeo             = ['Takéo', 'Takeo', 'Takeo', 'Ta Keo']
    @oddar_meanchey    = ['Oddar Meanchey', 'Somroung Thom']
    @kampong_speu      = ['Kampong Speu', 'Kampongspeu']
    @mondulkiri        = %w(Mondulkiri Mondolkiri)
    @kep               = %w(Kep)
  end

  def validate(name)
    value = name.downcase.strip if name.present?

    return banteay_meanchey[0] if banteay_meanchey.map(&:downcase).include?(value)
    return battambang[0]       if battambang.map(&:downcase).include?(value)
    return kampong_cham[0]     if kampong_cham.map(&:downcase).include?(value)
    return kampong_chhnang[0]  if kampong_chhnang.map(&:downcase).include?(value)
    return preah_sihanouk[0]   if preah_sihanouk.map(&:downcase).include?(value)
    return kampot[0]           if kampot.map(&:downcase).include?(value)
    return kandal[0]           if kandal.map(&:downcase).include?(value)
    return phnom_penh[0]       if phnom_penh.map(&:downcase).include?(value)
    return preah_vihear[0]     if preah_vihear.map(&:downcase).include?(value)
    return prey_veng[0]        if prey_veng.map(&:downcase).include?(value)
    return ratanakiri[0]       if ratanakiri.map(&:downcase).include?(value)
    return siem_reap[0]        if siem_reap.map(&:downcase).include?(value)
    return svay_rieng[0]       if svay_rieng.map(&:downcase).include?(value)
    return takeo[0]            if takeo.map(&:downcase).include?(value)
    return oddar_meanchey[0]   if oddar_meanchey.map(&:downcase).include?(value)
    return kampong_speu[0]     if kampong_speu.map(&:downcase).include?(value)
    return mondulkiri[0]       if mondulkiri.map(&:downcase).include?(value)
    return kep[0]              if kep.map(&:downcase).include?(value)

    name
  end
end
