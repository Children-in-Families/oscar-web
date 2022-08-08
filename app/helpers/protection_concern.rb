module ProtectionConcern
  def at_risk_en
    [
      'At risk of neglect',
      'At risk of sexual exploitation',
      'At risk of online sexual exploitation',
      'At risk of substance abuse',
      'At risk of child kidnapping',
      'At risk of trafficking',
      'At risk of physical violence',
      'At risk of emotional violence',
      'At risk of sexual violence',
      'At risk of forced/child marriage',
      'At risk of child labour',
      'At risk of worst forms of child labour'
    ]
  end

  def experiencing_en
    [
      'Experiencing neglect',
      'Experiencing sexual exploitation',
      'Experiencing online sexual exploitation',
      'Experiencing substance abuse',
      'Experiencing child kidnapping',
      'Experienced trafficking',
      'Experiencing physical violence',
      'Experiencing emotional violence',
      'Experienced sexual violence',
      'Experienced forced/child marriage',
      'Experiencing child labour',
      'Experiencing worst forms of child labour'
    ]
  end

  def other_form_en
    [
      'Abandonment',
      'Separated',
      'Orphaned',
      'Unaccompanied',
      'In conflict with law',
      'Minority / Isolated community',
      'Delinquent behaviour',
      'Stigmatization',
      'Working or living on street',
      'Witness of violence',
      'Gambling issues',
      'Affected by migration',
      'Infected by COVID-19',
      'Affected by COVID-19',
      'Other'
    ]
  end

  def protection_concerns
    [
      ['At risk', at_risk_en.zip(at_risk_en)],
      ['Experiencing/Experienced', experiencing_en.zip(experiencing_en)],
      ['Other Form', other_form_en.zip(other_form_en)]
    ]
  end
end
