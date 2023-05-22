module RiskAssessmentHelper
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

  def at_risk_km
    [
      'ប្រឈមនឹងការមិនអើពើ',
      'ប្រឈមនឹងការកេងប្រវ័ញ្ចផ្លូវភេទ',
      'ប្រឈមនឹងការកេងប្រវ័ញ្ចផ្លូវភេទតាមប្រព័ន្ធអ៊ីនធរនេត',
      'ប្រឈមនឹងការញៀន',
      'ប្រឈមនឹងការចាប់ពង្រត់កុមារ',
      'ប្រឈមនឹងការជួញដូរ',
      'ប្រឈមនឹងអំពើហឹង្សាផ្លូវកាយ',
      'ប្រឈមនឹងអំពើហឹង្សាផ្លូវចិត្ត',
      'ប្រឈមអំពើហឹង្សាផ្លូវភេទ',
      'ប្រឈមនឹងការរៀបអាពាហ៍ពិពាហ៍កុមារ/បង្ខំ',
      'ប្រឈមនឹងពលកម្មកុមារ',
      'ប្រឈមនឹងទម្រង់ធ្ងន់ធ្ងរបំផុតនៃពលកម្មកុមារ'
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

  def experiencing_km
    [
      'ទទួលរងការមិនអើពើ',
      'ទទួលរងការកេងប្រវ័ញ្ចផ្លូវភេទ',
      'ទទួលរងការកេងប្រវ័ញ្ចផ្លូវភេទតាមប្រព័ន្ធអ៊ីនធរនេត',
      'ទទួលរងការញៀន',
      'ទទួលរងការចាប់ពង្រត់កុមារ',
      'ទទួលរងការជួញដូរ',
      'ទទួលរងអំពើហឹង្សាផ្លូវកាយ',
      'ទទួលរងអំពើហឹង្សាផ្លូវចិត្ត',
      'ទទួលរងអំពើហឹង្សាផ្លូវភេទ',
      'ទទួលរងការរៀបអាពាហ៍ពិពាហ៍កុមារ/បង្ខំ',
      'ទទួលរងពលកម្មកុមារ',
      'ទទួលរងទម្រង់ធ្ងន់ធ្ងរបំផុតនៃពលកម្មកុមារ'
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

  def other_form_km
    [
      'ត្រូវបានបោះបង់ចោល',
      'បានបែកចេញ',
      'កំព្រា',
      'គ្មានមនុស្សពេញវ័យនៅជាមួយ',
      'មានទំនាស់នឹងច្បាប់',
      'ជនជាតិភាគតិច/សហគមន៍ឯកោ',
      'ឥរិយាបថទំនើង (ប្រព្រឹត្តខុសច្បាប់)',
      'រងការរើសអើង',
      'ធ្វើការ ឬរស់នៅតាមចិញ្ជើមផ្លូវ',
      'សាក្សីនៃអំពើហឹង្សា',
      'បញ្ហាល្បែងស៊ីសង',
      'ប៉ះពាល់ដោយចំណាកស្រុក',
      'ឆ្លងជង្ងឺកូវីដ-19',
      'ទទួលរងផលប៉ះពាល់ពីជម្ងឺកូវីដ-១៩',
      'បញ្ហាផ្សេងៗ'
    ]
  end

  def protection_concern_list
    [
      {
        label: 'At risk',
        options: at_risk_en.zip(at_risk_en).map{ |k, v| { label: k, value: v } }
      },
      {
        label: 'Experiencing/Experienced',
        options: experiencing_en.zip(experiencing_en).map{ |k, v| { label: k, value: v } }
      },
      {
        label: 'Other Form',
        options: other_form_en.zip(other_form_en).map{ |k, v| { label: k, value: v } }
      }
    ]
  end

  def protection_concern_list_local
    [
      {
        label: 'ការប្រឈម',
        options: at_risk_km.zip(at_risk_en).map{ |k, v| { label: k, value: v } }
      },
      {
        label: 'ទទួលរង/ធ្លាប់ឆ្លងកាត់',
        options: experiencing_km.zip(experiencing_en).map{ |k, v| { label: k, value: v } }
      },
      {
        label: 'ទម្រង់ផ្សេងៗ',
        options: other_form_km.zip(other_form_en).map{ |k, v| { label: k, value: v } }
      }
    ]
  end

  def select_quantitative_type(value)
    quantitative_types = QuantitativeType.cach_by_visible_on('client')
    quantitative_type = quantitative_types.select{|qt| qt.name =~ /#{value}/ }.first
    return [] if quantitative_type.blank?

    quantitative_cases = select_quantitative_cases(quantitative_type.id)
    quantitative_cases.map { |quantitative_case| [quantitative_case.value, quantitative_case.id] }
                      .map { |value, id| { label: split_quantitative_case_value(value), value: id } }
  end

  def split_quantitative_case_value(quantitative_case_value)
    values = quantitative_case_value.split(' / ')
    I18n.locale == :km ? values.first : values.last
  end

  def select_quantitative_cases(quantitative_type_id)
    QuantitativeCase.cache_all.select{ |qc| qc.quantitative_type_id == quantitative_type_id }
  end

  def history_of_harms
    select_quantitative_type('History of Harm')
  end

  def history_of_high_risk_behaviours
    select_quantitative_type('History of high-risk behaviours')
  end

  def reason_for_family_separations
    select_quantitative_type('Reason for Family Separation')
  end

  def history_of_disabilities
    select_quantitative_type('History of disability')
  end

  def display_level_of_risk(level_of_risk)
    return '' unless level_of_risk

    color_hash = { 'high' => 'danger', 'medium' => 'warning', 'low' => 'primary', 'no action' => 'success',  'pending_assessment' => 'default' }
    content_tag(:a, class: "btn btn-#{color_hash[level_of_risk]}") do
      level_of_risk.titleize
    end
  end

  def level_of_risk_options
    [
      I18n.t('risk_assessments._attr.level_of_risks.high'),
      I18n.t('risk_assessments._attr.level_of_risks.medium'),
      I18n.t('risk_assessments._attr.level_of_risks.low'),
      I18n.t('risk_assessments._attr.level_of_risks.no_action')
    ].zip(['high', 'medium', 'low', 'no action'])
  end
end
