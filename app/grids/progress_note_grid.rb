include ActionView::Helpers::SanitizeHelper
class ProgressNoteGrid < BaseGrid

  attr_accessor :current_client

  scope do
    ProgressNote.includes(:client, :progress_note_type, :location, :material, :interventions, :assessment_domains).order(:created_at)
  end

  filter(:date, :date, range: true, header: -> { I18n.t('datagrid.columns.progress_notes.date') })

  filter(:progress_note_type_id, :enum, select: :progress_note_type_select_options, header: -> { I18n.t('datagrid.columns.progress_notes.progress_note_type') })

  def progress_note_type_select_options
    ProgressNoteType.joins(:progress_notes).where(progress_notes: { client_id: current_client.id }).order('progress_note_types.note_type').map{ |t| [t.note_type, t.id] }.uniq
  end

  filter(:location_id, :enum, select: :location_select_options, header: -> { I18n.t('datagrid.columns.progress_notes.location') })

  def location_select_options
    Location.joins(:progress_notes).where(progress_notes: { client_id: current_client.id }).order('locations.order_option, locations.name').map{ |l| [l.name, l.id] }.uniq
  end

  filter(:other_location, :string, header: -> { I18n.t('datagrid.columns.progress_notes.other_location') }) { |value, scope| scope.other_location_like(value) }

  filter(:interventions_action, :enum, multiple: true, select: :interventions_options, header: -> { I18n.t('datagrid.columns.progress_notes.interventions') }) do |action, scope|
    if interventions ||= Intervention.action_like(action)
      scope.joins(:interventions).where(interventions: { id: interventions.ids })
    else
      scope.joins(:interventions).where(interventions: { id: nil })
    end
  end

  def interventions_options
    Intervention.joins(:progress_notes).where(progress_notes: { client_id: current_client.id }).order('interventions.action').pluck(:action).uniq
  end

  filter(:material_id, :enum, select: :material_select_options, header: -> { I18n.t('datagrid.columns.progress_notes.material') })

  def material_select_options
    Material.joins(:progress_notes).where(progress_notes: { client_id: current_client.id }).order('materials.status').map{ |m| [m.status, m.id] }.uniq
  end

  filter(:assessment_domains_goal, :enum, multiple: true, select: :assessment_domains_options, header: -> { I18n.t('datagrid.columns.progress_notes.goals_addressed') }) do |goal, scope|
    if assessment_domains ||= AssessmentDomain.goal_like(goal)
      scope.joins(:assessment_domains).where(assessment_domains: { id: assessment_domains.ids })
    else
      scope.joins(:assessment_domains).where(assessment_domains: { id: nil })
    end
  end

  def assessment_domains_options
    AssessmentDomain.joins(:progress_notes).where(progress_notes: { client_id: current_client.id }).pluck(:goal).uniq
  end

  column(:date, html: true, header: -> { I18n.t('datagrid.columns.progress_notes.date') }) do |object|
    link_to object.date.strftime('%d %B %Y'), client_progress_note_path(object.client, object)
  end

  date_column(:date, html: false, header: -> { I18n.t('datagrid.columns.progress_notes.date') })

  column(:child, html: true, order: false, header: -> { I18n.t('datagrid.columns.progress_notes.child') }) do |object|
    entity_name(object.client)
  end

  column(:child, html: false, header: -> { I18n.t('datagrid.columns.progress_notes.child') }) do |object|
    object.decorate.client
  end

  column(:staff, order: proc { |scope| scope.joins(:user).reorder('users.first_name') }, header: -> { I18n.t('datagrid.columns.progress_notes.staff') }) do |object|
    object.decorate.user
  end

  column(:progress_note_type, order: proc { |scope| scope.includes(:progress_note_type).reorder('progress_note_types.note_type') }, header: -> { I18n.t('datagrid.columns.progress_notes.progress_note_type') }) do |object|
    object.decorate.progress_note_type
  end

  column(:location, order: proc { |scope| scope.includes(:location).reorder('locations.name') }, header: -> { I18n.t('datagrid.columns.progress_notes.location') }) do |object|
    object.decorate.location
  end

  column(:other_location, header: -> { I18n.t('datagrid.columns.progress_notes.other_location') })

  column(:interventions, order: false, header: -> { I18n.t('datagrid.columns.progress_notes.interventions') }) do |object|
    object.interventions.pluck(:action).join(', ')
  end

  column(:material, order: proc { |scope| scope.includes(:material).reorder('materials.status') }, header: -> { I18n.t('datagrid.columns.progress_notes.material') }) do |object|
    object.decorate.material
  end

  column(:goals_addressed, order: false, header: -> { I18n.t('datagrid.columns.progress_notes.goals_addressed') }) do |object|
    object.assessment_domains.pluck(:goal).join(', ')
  end

  column(:response, html: false, header: -> { I18n.t('datagrid.columns.progress_notes.response') }) do |object|
    strip_tags(object.response)
  end

  column(:additional_note, html: false, header: -> { I18n.t('datagrid.columns.progress_notes.additional_notes') }) do |object|
    strip_tags(object.additional_note)
  end

  column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.progress_notes.manage') }) do |object|
    render partial: 'progress_notes/actions', locals: { object: object }
  end

  column(:changelog, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.progress_notes.changelogs') }) do |object|
    link_to t('datagrid.columns.progress_notes.view'), client_progress_note_version_path(object.client, object)
  end
end
