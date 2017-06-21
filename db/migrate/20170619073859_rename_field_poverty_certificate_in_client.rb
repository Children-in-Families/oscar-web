class RenameFieldPovertyCertificateInClient < ActiveRecord::Migration
  def change
    rename_column :clients, :poverty_certificate, :id_poor
  end
end
