namespace :harvester do
  # task to harvest oai repository
  # rake harvester:harvest_repository
  # 0 2 * * * cd /path/to/your/app && /path/to/rake harvester:harvest_repository RAILS_ENV=your_env
  desc "Harvester"
  task :harvest_repository , [:url, :name, :set] =>  :environment do |t, args|
   #moissonnage et génération du fichier csv pour l'import
   
   harvester = Harvester.new(args[:name], args[:url], args[:set])
   harvester.harvest
#   commandStr = 'rake solr:marc:index MARC_FILE=' + File.expand_path(File.join(Rails.root, 'tmp/moissonnage.mrc'))
   commandStr = 'cp ' + File.expand_path(File.join(Rails.root, 'tmp/moissonnage.mrc')) + ' /var/local/exports/numilog.mrc '
   puts commandStr
   puts
   `#{commandStr}`
  end
end

