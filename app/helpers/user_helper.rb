# -*- encoding : utf-8 -*-
module UserHelper
  def get_library_title ( succursale )  
   case succursale
      when '1' then answer = 'B.U. LETTRES LAFAYETTE'
      when '2' then answer = 'B.U. Droit, économie, management'
      when '3' then answer = 'Bibliothèque du Patrimoine'
      when '4' then answer = 'B.U. LETTRES GERGOVIA'
      when '5' then answer = 'B.U. SCIENCES & TECHNIQUES'
      when '6' then answer = 'B.U. SANTE'
      when '7' then answer = 'Bibliothèque 2e etage Gergovia'
      when '8' then answer = 'BUFR GESTION'
      when '9' then answer = 'B.U. ODONTOLOGIE'
      when '10' then answer = 'CRFCB'
      when '11' then answer = 'Bibliothèque IUT CLERMONT FD'
      when '12' then answer = 'B.U. AURILLAC'
      when '13' then answer = 'Bibliothèque IUT MONTLUCON'
      when '14' then answer = 'BUFR LACC'
      when '15' then answer = 'BUFR PSYCHOLOGIE'
      when '16' then answer = 'Bibliothèque Langues Carnot'
      when '17' then answer = 'Polytech ISIMA'
      when '18' then answer = 'B.U. STAPS'
      when '19' then answer = 'BUFR PHYSIQUE'
      when '20' then answer = 'Centre de documentation La Jetée'
      when '21' then answer = 'Bibliothèque IUT LE PUY'
      when '23' then answer = 'IFMA Centre de documentation'
      when '24' then answer = 'Bibliothèque Maison des sciences de l\'homme'
   else
      answer = 'Succursale inconnue'
  end
  answer
  end
end
