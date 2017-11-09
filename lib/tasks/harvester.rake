namespace :harvester do
  # task to harvest oai repository
  # rake harvester:harvest_repository
  # 0 2 * * * cd /path/to/your/app && /path/to/rake harvester:harvest_repository RAILS_ENV=your_env
  desc "Harvester"
  task :harvest_repository , [:url, :name, :set] =>  :environment do |t, args|
   #moissonnage et génération du fichier csv pour l'import

   harvester = Harvester.new(args[:name], args[:url], args[:set])
   harvester.harvest
   commandStr = 'java -Xms1024m -Xmx1024m  -Dsolr.hosturl=http://127.0.0.1:8080/solr/blacklight  -jar /root/.rbenv/versions/2.4.0/lib/ruby/gems/2.4.0/gems/blacklight-marc-5.10.0/lib/SolrMarc.jar /usr/applications/blacklight-developpement-6.10.1/config/SolrMarc/config.properties ' + File.expand_path(File.join(Rails.root, 'tmp/moissonnage.mrc'))
#   commandStr = 'cp ' + File.expand_path(File.join(Rails.root, 'tmp/moissonnage.mrc')) + ' /usr/applications/exports/moissonnage.mrc '
   puts commandStr
   puts
   `#{commandStr}`
  end
end
