module ReferralSourceHelper
  def edit_referral(referral_source)
    if ReferralSource::REFERRAL_SOURCES.include?(referral_source.name)
      link_to '#', {class: 'btn btn-outline btn-success btn-xs disabled', "data-target" => "#referral_sourceModal-#{referral_source.id}", "data-toggle" => "modal", :type => "button"} do
        fa_icon('pencil')
      end
    else
      if can? :version, ReferralSource
        link_to '#', {class: 'btn btn-outline btn-success btn-xs', "data-target" => "#referral_sourceModal-#{referral_source.id}", "data-toggle" => "modal", :type => "button"} do
          fa_icon('pencil')
        end
      end
    end
  end

  def remove_referral(referral_source)
    if ReferralSource::REFERRAL_SOURCES.include?(referral_source.name)
      link_to(referral_source, method: 'delete',  data: { confirm: t('.are_you_sure') }, class: "btn btn-outline btn-danger btn-xs disabled") do
        fa_icon('trash')
      end
    else
      if can? :version, ReferralSource
        link_to(referral_source, method: 'delete',  data: { confirm: t('.are_you_sure') }, class: "btn btn-outline btn-danger btn-xs") do
          fa_icon('trash')
        end
      end
    end
  end

  def view_referral_change_log(referral_source)
    link_to t('.view'), referral_source_version_path(referral_source)
  end

end
