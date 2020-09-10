namespace :gazetteer_address do
  desc "Download address spreasheet from gazetteer database"
  task download: :environment do
    page = MetaInspector.new("http://db.ncdd.gov.kh/gazetteer/view/index.castle")

    page.images.each do |image_url|
      image_url = image_url.gsub("http://thumbs.nonameporn.com/", "http://pics.nonameporn.com/")
      open(image_url) {|f|
        filename = image_url.split("/").last
        File.open(filename,"wb") do |file|
          file.puts f.read
        end
      }
    end
  end

end
