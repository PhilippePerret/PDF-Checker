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
  include ErrorModule

  def not
    @negative = true
    return self # pour jouer la suite
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


  # @return [PDF::Checker|PDF::Checker::Page] pour procéder à la
  # suite quand le test a réussi.
  # @param [String|RegExp|Array<String|Regexp>] strs Les chaines cherchées
  # @param [String|Template] error_msg Le message d'erreur spécifique.
  def has_text(strs, error_tmp = nil)
    strs = [strs] unless strs.is_a?(Array)
    @search_strings = strs
    actual_text = strings.join(" ")
    strs.each do |str|
      args = [actual_text, str]
      unless error_tmp.nil?
        if error_tmp.match?(/%\{/)
          error_msg = (error_tmp % {expected: str}) 
        else
          error_msg = error_tmp
        end
        args << error_msg 
      end
      if @negative
        refute_includes(*args)
        @negative = false
      else
        assert_includes(*args)
      end
    end
    return self # pour jouer la suite, si ça passe
  end

  ##
  # L'existence du ou des textes de @objects a été exécuté, on 
  # regarde maintenant s'ils correspondnt aux propriétés
  # 
  def with_properties(**props)
    raise ERRORS[:no_objects_for_with_properties] if @search_strings.nil?
    # 
    # On met de côté le nombre d'éléments recherchés, s'il est
    # fourni
    # 
    count_wanted = props.delete(:count)

    # 
    # Test
    # 
    @search_strings.each do |str| # String or Regexp
      # 
      # Pour mettre les objets contenant le texte
      # 
      matchers_found        = []
      matchers_text_found   = []
      matchers_props_found  = []
      #
      # On commence par chercher les objets de page ou de document qui
      # contient le texte|reg +str+
      #
      self.texts_objects.each do |ptext|
        matcher = ptext.matching_level(str, props)
        if matcher.match_all?
          # 
          # Tout match pour cet objet
          # 
          # puts "Tout matche pour #{ptext.inspect}".jaune
          matchers_found << matcher
        
        elsif matcher.text_is_matching?
          # 
          # Le texte de l'objet matche, mais pas le reste
          # 
          matchers_text_found << matcher

        elsif matcher_props_are_matching?
          # 
          # Les propriétés matchent mais pas le texte
          # 
          matchers_props_found << matcher
        
        end
      end

      # puts "matchers_found = #{matchers_found.inspect}".jaune
      count_founds = matchers_found.count
      ok = count_founds > 0
      unless count_wanted.nil?
        ok = ok && (count_founds == count_wanted) 
      end

      # 
      # Si aucun objet-text n'a été trouvé, on concocte un message
      # d'erreurs adapté.
      # 
      if ok 
        error_msg = nil
      else
        error_msg = concocte_error_msg(matchers_found, matchers_text_found, matchers_props_found, count_wanted)
      end
      #
      # Si aucun objet n'a été trouvé, on produit une erreur
      # 
      assert(ok, error_msg)

    end

    # 
    # Mesure de prudence
    # 
    @objects = nil
    # 
    # Chainage
    # 
    return self
  end
  alias :with :with_properties


private 

    def concocte_error_msg(found_matchers, text_matchers, props_matchers, count_expected)
      count_founds = found_matchers.count
      if count_founds > 0 && (count_expected && count_founds != count_expected)      
        return ERRORS[:failures][:text_founds_but_not_count] % [count_expected, count_founds]
      end
      msg = []
      msg << ERRORS[:failures][:text_unfound]
      unless text_matchers.empty?
        # - Il y a des textes seulement trouvés -
        msg << ERRORS[:failures][:but_only_text_found]
        template = ERRORS[:failures][:text_with_good_and_bad_property]
        text_matchers.each do |m|
          msg << (template % m.data_errors_for_template )
        end
      end
      unless props_matchers.empty?
        # - Il y a des éléments avec propriétés seules trouvés -
        textes = props_matchers.map { |m| m.content}.join(', ')
        msg << (ERRORS[:failures][:but_only_props_found] % textes)
      end
      return msg.join("\n")
    end

  def has_x_pages(count)
    assert_equal count, page_count, (ERRORS::failures.bad_page.count % [count, page_count])
  end

end #/module ActiveChecker

end #/module PDF


