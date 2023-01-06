=begin

  Ce module contient les méthodes qui peuvent être appelées sur 
  le PDF::Checker pour vérifier son contenu.

  @example:

    pdf = PDF::Checker.new("path/to/my/doc.pdf")
    pdf.has(5.pages)
    # => error if doc.pdf does'nt contain 5 pages

    Read document to get all the check methods.
    
=end
module PDF
module ActiveChecker

  ##
  # Produit une erreur si le document checké ne contient pas 
  # +what+
  # 
  # @param [Hash] what  Pour le momemnt, c'est une table qui contient
  #                     le type et le nombre voulu (cf. ci-dessous)
  # @option what [Integer] :count Le nombre d'éléments de type :
  # @option what [Symbol] :type   Le type de l'élément qui, pour le moment, peut être :page, :image ou :graphic
  # 
  def has(what)
    send("has_x_#{what[:type]}s".to_sym, what[:count])
  end


private 

  def has_x_pages(count)
    assert_equal count, page_count, "Le document devrait contenir #{count} pages. Il en contient #{page_count}."
  end

end #/module ActiveChecker
end #/module PDF
