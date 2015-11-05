# -*- encoding : utf-8 -*-
module UserHelper
  def get_library_title ( succursale )  
   case succursale
      when '1' then answer = 'B.U. Lafayette'
      when '2' then answer = 'B.U. droit, économie, management'
      when '4' then answer = 'B.U. Gergovia'
      when '5' then answer = 'B.U. sciences & STAPS'
      when '6' then answer = 'B.U. santé'
      when '7' then answer = 'Bibliothèque 2e étage Gergovia'
      when '8' then answer = 'BUFR gestion'
      when '9' then answer = 'B.U. odontologie'
      when '10' then answer = 'ESPE Chamalières'
      when '11' then answer = 'Bibliothèque IUT Cézeaux'
      when '12' then answer = 'B.U. Aurillac'
      when '13' then answer = 'Bibliothèque IUT Montluçon'
      when '14' then answer = 'BUFR LACC'
      when '15' then answer = 'BUFR psychologie'
      when '16' then answer = 'Bibliothèque Langues Carnot'
      when '17' then answer = 'Polytech ISIMA'
      when '18' then answer = 'B.U. STAPS'
      when '19' then answer = 'BUFR physique'
      when '20' then answer = 'ESPE Moulins'
      when '21' then answer = 'Bibliothèque IUT Le Puy'
      when '23' then answer = 'IFMA centre de documentation'
      when '24' then answer = 'Bibliothèque Maison des sciences de l\'homme'
   else
      answer = 'Succursale inconnue'
  end
  answer
  end
end
