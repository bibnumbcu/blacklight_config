namespace :harvester do
  # task to harvest oai repository
  # rake harvester:harvest_repository
  # 0 2 * * * cd /path/to/your/app && /path/to/rake harvester:harvest_repository RAILS_ENV=your_env
  desc "Harvester"
  task :harvest_repository , [:url, :name, :set] =>  :environment do |t, args|
   #moissonnage et génération du fichier csv pour l'import

   harvester = Harvester.new(args[:name], args[:url], args[:set])
   harvester.harvest
   commandStr = 'java -Xms1024m -Xmx1024m  -Dsolr.hosturl=http://127.0.0.1:8080/solr/blacklight  -jar /var/local/solrmarc/lib/SolrMarc.jar config/SolrMarc/config.properties ' + File.expand_path(File.join(Rails.root, 'tmp/moissonnage.mrc'))
#   commandStr = 'cp ' + File.expand_path(File.join(Rails.root, 'tmp/moissonnage.mrc')) + ' /usr/applications/exports/moissonnage.mrc '
   puts commandStr
   puts
   `#{commandStr}`
  end
end
