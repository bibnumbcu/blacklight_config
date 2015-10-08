# -*- encoding : utf-8 -*-
module SuggestionHelper
  def get_status ( number )  
   case number
      when 1 then answer = 'Demande envoyée'
   else
      answer = 'Demande en erreur'
  end
  answer
  end
end
