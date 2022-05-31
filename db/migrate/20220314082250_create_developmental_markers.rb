class CreateDevelopmentalMarkers < ActiveRecord::Migration
  def up
    create_table :developmental_markers do |t|
      t.string :name
      t.string :name_local
      t.string :short_description
      t.string :short_description_local
      t.string :question_1
      t.string :question_1_field
      t.string :question_1_illustation
      t.string :question_1_local
      t.string :question_2
      t.string :question_2_field
      t.string :question_2_illustation
      t.string :question_2_local
      t.string :question_3
      t.string :question_3_field
      t.string :question_3_illustation
      t.string :question_3_local
      t.string :question_4
      t.string :question_4_field
      t.string :question_4_illustation
      t.string :question_4_local

      t.timestamps null: false
    end
    add_index :developmental_markers, :name


    DevelopmentalMarker.reset_column_information

    if DevelopmentalMarker.count == 0 && schema_search_path[/^\"public\"|^\"shared\"/].blank?
      workbook = Roo::Excelx.new(Rails.root.join('db/support/cbdmat_markers.xlsx'))
      (0..9).each do |index|
        sheet = workbook.sheet(index)
        names = sheet.sheets[index].split('_')
        marker_obj = DevelopmentalMarker.find_or_initialize_by(name: names.first.squish) do |marker|
          marker.name_local = names.last.squish

          cells = sheet.to_a
          marker.short_description = cells[1].second.squish
          marker.short_description_local = cells[1].last.squish

          (1..4).each do |index|
            marker.public_send("question_#{index}_field=", cells[index + 1].first.squish)
            marker.public_send("question_#{index}=", cells[index + 1].second.squish)
            marker.public_send("question_#{index}_local=", cells[index + 1].last.squish)
          end
        end

        marker_obj.save
      end
    end
  end

  def down
    drop_table :developmental_markers
  end
end
