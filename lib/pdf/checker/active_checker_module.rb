=begin

  Ce module contient les méthodes qui peuvent être appelées sur 
  le PDF::Checker pour vérifier son contenu.

  @example:

    pdf = PDF::Checker.new("path/to/my/doc.pdf")
    pdf.has(5.pages)
    # => error if doc.pdf does'nt contain 5 pages

    pdf.page(10).has_text("My text").at(**{top: 110})

    Read document to get all the check methods.
    

  TODO
    Problème pour le moment avec le @negative (si on le met à 
    true, il reste à true pour tout le temps)
    =>  À chaque appel d'une assertion (comme :has ou :has_text et 
        donc, aussi, :not), il faut créer une instance qui va se
        charger de tester.
    note : cela devrait aussi régler certains problèmes, car en
    créant une instance unique, on pourra mettre plus de propriété
    en propriété
    QUESTION : est-il possible de fondre avec level_matcher qui n'a
    plus vraiment de sens ?
    Ce serait par exemple une instance PDF::Checker::Assertion qui 
    pourrait être décliné en PDF::Checker::TextAssertion ou 
    PDF::Checker::ImageAssertion
    Noter que lorsque c'est appelé par :not, on ne sait pas encore
    ce que c'est, donc il faut utiliser PDF::Checker::NegAssertion

=end
module PDF
module ActiveChecker
  include ErrorModule

  def not
    return PDF::Checker::NegAssertion.new(self, nil, nil)
  end

  def has_text(strs, error_tmp = nil, options = nil)
    if error_tmp.is_a?(Hash)
      options = error_tmp
    else
      options ||= {}
      options.merge!(error_tmp: error_tmp) unless error_tmp.nil?
    end
    assertion = PDF::Checker::TextAssertion.new(self, strs, options)
    assertion.proceed
    return assertion # chainage
  end

  def has_font(font_name)
    assertion = PDF::Checker::FontAssertion.new(self, font_name)
    assertion.proceed
    return assertion # chainage
  end

  def has_image(img_path, error_tmp = nil, options = nil)
    if error_tmp.is_a?(Hash)
      options = error_tmp
    else
      options ||= {}
      options.merge!(error_tmp: erro_tmp) unless error_tmp.nil?
    end
    return PDF::Checker::ImageAssertion.new(self, img_path, options)
  end

  def has_graphic(params, error_tmp = nil, options = nil)
    if error_tmp.is_a?(Hash)
      options = error_tmp
    else
      options ||= {}
      options.merge!(error_tmp: erro_tmp) unless error_tmp.nil?
    end
    return PDF::Checker::GraphicAssertion.new(self, params, options)
  end

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

  # # @return [String] Error message for assertion
  # # 
  # # @param [String|Nil] error_tmp Template de message fourni ou non
  # # @param [String] actual_text Textual content of the page (or document ?)
  # # @param [String|Regexp] regstr Text or Regexp searched in actual_text
  # # 
  # def build_error_message_text_unfound(error_tmp, actual_text, regstr)
  #   # 
  #   # Message d'erreur s'il n'a pas été fourni
  #   # 
  #   if error_tmp.nil?
  #     err_key = @negative ? :text_found_in_negative : :text_unfound_in
  #     error_tmp = ERRORS[:failures][err_key] % actual_text.inspect
  #   end
  #   # 
  #   # On construit le message d'erreur
  #   # 
  #   error_msg = "#{error_tmp}"
  #   error_msg % {expected: regstr} if error_tmp.match?(/%\{/)
    
  #   return error_msg
  # end

private 

  def has_x_pages(count)
    assert_equal count, page_count, (ERRORS::failures.bad_page.count % [count, page_count])
  end

end #/module ActiveChecker

end #/module PDF


