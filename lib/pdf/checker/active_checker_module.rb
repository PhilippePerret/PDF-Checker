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
    return assertion
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


  ##
  # Méthode qui vérifie la présence d'un texte dans la page
  # 
  # @return [PDF::Checker|PDF::Checker::Page] pour procéder à la
  # suite quand le test a réussi.
  # @param [String|RegExp|Array<String|Regexp>] strs Les chaines cherchées
  # @param [String|Template] error_msg Le message d'erreur spécifique.
  # 
  # Fonctionnement
  # --------------
  # La méthode privilégiée (la première) recherche dans tous les
  # objets textuels (text_objects) les textes cherchés. Si tous les
  # textes sont trouvés, ils sont mis dans @objects_found pour être
  # testés ailleurs.
  # Pour chaque texte qui n'est pas trouvé, on regarde si son début
  # est contenu dans le text-object et on le prend, avec un coefficiant
  # de pertinence plus faible.
  # 
  def OLD_has_text(strs, error_tmp = nil)
    strs = [strs] unless strs.is_a?(Array)
    # 
    # On fait une table pour savoir quels textes|regexp ont été 
    # trouvés. C'est une table avec en clé le texte|regexp et en
    # valeur une liste des text-objets (entendu qu'un même texte peut
    # se trouver à différents endroits)
    # Chaque valeur est une liste contenant les textes-objets
    # 
    @found_texts = {}
    # 
    # On boucle sur tous les textes à trouver, qu'on cherche dans
    # les textes-objets.
    # 
    # @rappel : les textes-objets peuvent contenir
    # des textes incomplets — c'est même souvent le cas pour de longs
    # textes : chaque ligne de paragraphe fait l'objet d'un texte-
    # objet différent). Aussi bien, un texte cherché, si c'est tout
    # le paragraphe, peut n'être trouvé qu'en partie, il faut le
    # chercher dans le texte complet.
    #
    text_objects.each do |tob|
      # 
      # Boucle sur chaque texte|regexp cherché
      # 
      strs.each do |regstr|
        if case regstr
           when String
             tob.content.include?(regstr)
           when Regexp
             tob.content.match?(regstr)
           else
             raise ERRORS[:invalid_type_to_search_text] % "#{regstr.class}"
          end === !@negative then
          # => OK
          @found_texts.merge!(regstr => []) unless @found_texts.key?(regstr)
          @found_texts[regstr] << tob
        end
      end
    end

    # --- On cherche les textes|regexp non trouvés ---

    # 
    # Pour mettre les textes non trouvés, qui pourront être cherchés
    # plutôt dans le texte complet ensuite.
    # 
    unfound_texts = []
    # 
    # Boucle sur tous les textes|regexps pour connaitre ceux qui 
    # n'ont pas été trouvés et les mettre dans unfound_texts
    # 
    strs.each do |regstr|
      next if @found_texts.key?(regstr)
      unfound_texts << regstr
    end

    # 
    # Si des textes n'ont pas été trouvé ci-dessus, il faut les 
    # chercher dans le texte complet (assemblé)
    # 
    if unfound_texts.count > 1
      # 
      # Le texte complet (de la page ou du document)
      # 
      actual_text = strings.join(" ")
      # 
      # Boucle sur chaque texte|regexp non trouvé
      # 
      unfound_texts.each do |regstr|
        # 
        # On teste
        #
        if case regstr
          when String
            actual_text.include?(regstr)
          when Regexp
            actual_text.match?(regstr)
          end === @negative then
          #   
          # <= Texte|regexp non trouvé (ou trouvé si @negative)
          # => ERROR
          # 
          error_msg = build_error_message_text_unfound(error_tmp, actual_text, regstr)
          # 
          # On produit la failure (et on s'arrête là)
          # 
          refute(false, error_msg)
        end
      end
    end #/s'il y a eu des textes non trouvés
    # 
    # Chainage
    # 
    return self # pour jouer la suite, si ça passe
  end

  # @return [String] Error message for assertion
  # 
  # @param [String|Nil] error_tmp Template de message fourni ou non
  # @param [String] actual_text Textual content of the page (or document ?)
  # @param [String|Regexp] regstr Text or Regexp searched in actual_text
  # 
  def build_error_message_text_unfound(error_tmp, actual_text, regstr)
    # 
    # Message d'erreur s'il n'a pas été fourni
    # 
    if error_tmp.nil?
      err_key = @negative ? :text_found_in_negative : :text_unfound_in
      error_tmp = ERRORS[:failures][err_key] % actual_text.inspect
    end
    # 
    # On construit le message d'erreur
    # 
    error_msg = "#{error_tmp}"
    error_msg % {expected: regstr} if error_tmp.match?(/%\{/)
    
    return error_msg
  end

  ##
  # L'existence du ou des textes a été exécuté, on 
  # regarde maintenant s'ils correspondnt aux propriétés
  # @rappel
  #   Tous les textes-objets trouvés ont été mis dans @found_texts
  #   qui contient :
  #     key: le texte|regexp recherché
  #     value: array of text_objects containing texte|regexp 
  # 
  def with_properties(**props)
    raise ERRORS[:no_objects_for_with_properties] if @search_strings.nil?
    # 
    # On met de côté le nombre d'éléments recherchés, s'il est
    # fourni (par l'attribut :count)
    # 
    count_wanted = props.delete(:count)

    #
    # Pour mettre les textes-objets retenus (et savoir si certains
    # textes — objets-texte — n'ont pas passé la barre)
    # Il ne contiendra que les text-objets qui contiennent le texte
    # et qui possède les propriétés requises. Avec en clé le regstr
    # et en valeur la liste des text-objects si plusieurs ont été
    # trouvés.
    # 
    @new_found_texts = nil

    # 
    # Boucle sur tous les texte-objets trouvés
    # 
    @search_strings.each do |regstr, text_objects|
      # 
      # Pour mettre les objets contenant le texte
      # 
      matchers_found        = []
      matchers_text_found   = []
      matchers_props_found  = []

      text_objects.each do |text_object|
        # 
        # Le "level-matcher" qui va nous permettre de voir si les
        # propriétés existent pour le texte-objet
        # 
        matcher = text_object.matching_level(regstr, props)
        if matcher.props_are_matching? === !@negative
          # 
          # Les propriétés matchent
          # 
          @new_found_texts.merge!(regstr => []) unless @new_found_texts.key?(regstr)
          @new_found_texts[regstr] << text_objet
        else
          # 
          # Les propriétés ne matchent pas
          # 
          matchers_props_unfound << matcher
        end
      end

      if not(@new_found_texts.key?(regstr))
        # 
        # Un texte trouvé ne possède pas les propriétés attendues
        # Cela provoque forcément une erreur (mais incomplète puisque
        # les textes suivants n'ont pas encore été examinés)
        err_message = matchers_props_unfound.map do |matcher|
          matcher.build_failure_message_with_good_and_bad_properties
        end.join("\n\- ")
        refute(false, err_message)

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

      #
      # On ajoute les matchers trouvés
      # 
      @matchers += matchers_found

    end #/fin boucles sur chaque texte-objet possédant le texte

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


  # Produit une erreur si aucun des textes fournis n'est positionné
  # à l'endroit défini par les arguments.
  # 
  # @param [Numeric|Hash] arg1 Position top ou left ou table contenant une ou plusieurs valeurs parmi : :left, :top, :right, :bottom
  #     Si arg2 est nil, c'est la position top
  #     Si arg2 est défini, arg1 est le left
  # @param [Numeric|nil] Position top
  # @param [Numeric] Tolérance acceptée pour l'estimation
  # 
  def at(arg1, arg2 = nil, delta = 0.0)
    if @matchers.nil?
      raise ERRORS[:failures][:searched_text_required_for_at_test]
    end
    # 
    # Pour mettre la liste des propriétés à checker
    # 
    checked_props = {}

    case arg1
    when Hash
      [:left, :top, :bottom, :right].each do |prop|
        checked_props.merge!(prop => arg1[prop]) if arg1.key?(prop) && arg1[prop]
      end
    when Numeric
      if arg2.nil?
        checked_props.merge!(top: arg1)
      else
        checked_props.merge!(left: arg1)
        checked_props.merge!(top: arg2)
      end
    end

    # 
    # Pour indiquer les positions des textes en cas d'erreur
    # 
    @texts_positioning = []

    # 
    # On ne doit garder que les matchers qui sont bien positionnés
    # @rappel :
    #   Il y a un matcher par texte|regexp recherché
    # 
    @matchers.select! do |matcher|
      all_positioning_are_good(matcher, checked_props, delta)
    end

    # 
    # S'il ne reste plus de matchers, on n'a pas trouvé le texte
    # positionné au bon endroit
    # TODO : Affiner le message d'erreur
    # 
    err_msg = nil
    if @matchers.empty?
      # 
      # On construit un meilleur message d'erreur
      #
      err_msg = "Aucun des textes trouvés ne se trouve à la position #{checked_props.inspect} :\n#{@texts_positioning.join("\n")}"
    end
    refute(@matchers.empty?, err_msg)
    # 
    # Chainage
    # 
    return self
  end

  def all_positioning_are_good(matcher, checked_props, delta)
    # 
    # La procédure, en fonction du fait que le delta est défini
    # 
    not_in_delta =
      if delta == 0.0 || delta.nil? then
        Proc.new { |act, exp| act != exp }
      else
        Proc.new { |act, exp| delta < (exp.round(3) - act.round(3)).abs }
      end

    #
    # On checke toutes les propriétés surveillées
    # 
    checked_props.each do |prop, expected| # :left, :top...
      actual = matcher.text_object.send(prop)
      if not_in_delta.call(actual, expected)
        # 
        # Puisque cette propriété ne correspond pas, on regarde
        # quand même les autres pour offrir un message d'erreur le
        # plus éclairant possible.
        # 
        good_props = []
        expecteds_against_actuals = []
        checked_props.each do |prop, expected|
          actual = matcher.text_object.send(prop)
          if not_in_delta.call(actual, expected)
            expecteds_against_actuals << ":#{prop} (valeur: #{actual}, attendu: #{expected})"
          else
            good_props << prop.inspect 
          end
        end
        content = matcher.text_object.content.inspect
        if good_props.empty?
          @texts_positioning << "- Aucune des propriété du texte #{content} ne correspond : #{expecteds_against_actuals.pretty_join}."
        else
          les_good_props = good_props.count > 1 ? "les bonnes propriétés" : "la bonne propriété"
          les_bad_props  = expecteds_against_actuals.count > 1 ? "les propriétés" : "la propriété"
          @texts_positioning << "- Le texte #{content} possède #{les_good_props} #{good_props.pretty_join} mais pas #{les_bad_props} #{expecteds_against_actuals.pretty_join}."
        end
        return false 
      end
    end
    # 
    # Toutes les propriétés sont valides, c'est bon
    # 
    return true
  end

  def close_to(arg1, arg2 = nil)
    self.at(arg1, arg2, delta = 2)
  end
  def near_to(arg1, arg2 = nil)
    self.at(arg1, arg2, delta = LevelMatcher::COORDONNATE_TOLERANCE)
  end

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


