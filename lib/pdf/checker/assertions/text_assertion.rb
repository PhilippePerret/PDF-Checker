require_relative 'assertion'
module PDF
class Checker
class TextAssertion < PDF::Checker::Assertion

  ##
  # --- Analyse ---
  # 
  # @searched contient les strings ou les regexp à trouver dans 
  # le propriétaire (@owner) de cette assertion.
  def proceed
    # 
    # On met le texte cherché dans une liste si c'est un texte ou
    # une expression régulière seule
    # 
    @searched = [searched] unless searched.is_a?(Array)
    # 
    # Table pour mettre les objets-textes trouvés
    # @note
    #   'tof' pour Text-Object-Found (TOF)
    # 
    tof = {}
    # 
    # Table pour mettre les textes non trouvés
    # @note
    #   'bof' pour Bad-Object-Found
    bof = {}
    # 
    # Boucle sur tous les objets textuels (on fait un matcher par
    # objet)
    # 
    owner.texts_objects.each do |text_object|
      # 
      # On crée un matcher pour ce texte-objet
      # 
      matcher = PDF::Checker::TextObjectMatcher.new(text_object, options)
      # 
      # On attache ce matcher au texte-objet
      # 
      text_object.matcher = matcher
      # 
      # Boucle sur tous les textes cherchés pour savoir si 
      # l'objet texte les contient.
      # 
      searched.each do |regstr|
        # 
        # On regarde si ce matcher contient (ou ne contient pas) ce
        # texte|regexp cherché. Si c'est le cas, on ajoute ce texte
        # trouvé à +tof+ s'il ne connait pas encore
        # ce texte, et on ajoute l'objet à la liste des objets
        # possibles (pour pouvoir ensuite checker les propriétés)
        # 
        ok = matcher.does_or_neg_contains?(regstr)
        liste = ok ? tof : bof
        liste.key?(regstr) || liste.merge!(regstr => [])
        liste[regstr] << text_object
      end #/fin boucle sur tous les textes|regexp cherchés
    end

    #
    # Cas particulier (et particulièrement épineux) ou le texte n'a
    # pas été trouvé dans les text-objets (qui, rappelons-le, ne
    # contiennent que le texte d'une simple ligne du PDF), mais où 
    # il se trouve dans le texte complet. Dans ce cas, on va le 
    # rechercher dans plusieurs textes-objects qui se suivent.
    # 
    # @note
    #   La méthode owner.matches_texts? tient compte de la négativité
    # 
    if tof.count == 0
      if not(owner.matches_texts?(searched))
        # 
        # Quand les textes n'ont pas été trouvés (ou trouvés, en mode
        # négative), on produit une erreur
        # 
        err_msg =
          if options[:error_tmp]
            options[:error_tmp] % "dans le texte complet"
          elsif negative?
            "Le ou les textes suivants ont été trouvés : #{searched.inspect}"
          else
            "Le ou les textes suivants n'ont pas été trouvés : #{searched.inspect}"
          end
        assert(false, err_msg)
        return
      end
      # 
      # Quand on passe ici, c'est que tous les textes ont été trouvés
      # dans le texte général (ou non trouvés en mode negatif).
      # 
      # 
      # En mode négatif, on peut s'arrêter ici.
      # 
      assert(true) and return if negative?
      # 
      # En mode positif, on doit rechercher les text-objets qui 
      # vont correspondre, au texte cherché, découpé.
      # 
      searched.each do |regstr|
        text_object = nil
        owner.texts_objects.each_cons(2) do |to1, to2|
          fusion = to1.content.rstrip + ' ' + to2.content
          text_object = to1 and break if fusion.match?(regstr)
        end
        # 
        # Si le texte n'a toujours pas été trouvé, on fait une
        # dernière tentative sur 3 texts-objects
        # 
        if text_object.nil?
          owner.texts_objects.each_cons(3) do |to1, to2, to3|
            fusion = to1.content.rstrip + ' ' + to2.content.strip + ' ' + to3.content
            text_object = to1 and break if fusion.match?(regstr)
          end
        end
        # 
        # Si le texte n'a pas été trouvé ici, c'est qu'on ne peut
        # pas le trouve avec nos moyens (mais il existe puisqu'on
        # l'a trouvé dans le texte global)
        # 
        if text_object.nil?
          assert(false, ERRORS[:failures][:unabled_to_find_textobject_for_text_in_whole] % regstr)
        else
          # 
          # On a trouvé un text-objet qui correspond !
          #
          tof.key?(regstr) || tof.merge!(regstr => [])
          tof[regstr] << text_object
        end
      end
    end

    # 
    # Dans tous les cas, on doit avoir autant de réussites que
    # de textes recherchés (ou non)
    unless negative?
      count_is_right = searched.count == tof.count
      err_msg = ""
      unless count_is_right
        diff_regstrs = (searched - tof.keys).map{|s|s.inspect}
        err_msg =
          if options[:error_tmp]
            options[:error_tmp] % diff_regstrs.inspect
          elsif diff_regstrs.count == 1
            "#{ERRORS[:failures][:following_text_unfound]}#{diff_regstrs.first}"
          else
            diff_regstrs = diff_regstrs.pretty_join
            "#{ERRORS[:failures][:following_texts_unfound]}#{diff_regstrs}"
          end
      end
      assert(count_is_right, err_msg + source)
    end

    if expected_count
      # 
      # Si un nombre exact est demandé, on doit l'avoir trouvé
      # pour chacun des textes cherchés (en général un seul dans
      # ce cas)
      # 
      tof.each do |regstr, text_objects|
        if negative?
          refute_equal(expected_count, text_objects.count + source)
        else
          assert_equal(expected_count, text_objects.count + source)
        end
      end
    end
    # 
    # Pour passer à la suite
    # 
    @objects_found = tof
  end
  #/ #proceed


  ##
  # Quand with_properties (ou with) est chainé à has_text
  # 
  # @param [Hash] properties Les propriétés attendues
  # 
  def with_properties(**properties)
    # 
    # Si c'est un test @negative et qu'aucun texte n'a été trouvé,
    # le résultat est donc positif
    # 
    if negative? && @objects_found.empty?
      assert(true) and return
    end
    #
    # Si un nombre précis est attendu
    # 
    count_expected = properties.delete(:count)
    #
    # Pour simplifier le code
    #
    tof = @objects_found
    # 
    # Pour mettre les nouveaux texte-objets qui passeront le
    # test courant
    # 
    new_tof = {}
    # 
    # Pour mettre les mauvais texte-objets (qui ne passeront pas
    # les tests courants)
    # 
    bad_tof = {}
    # 
    # Boucle sur tous les texte-objets trouvés
    # 
    @objects_found.each do |regstr, text_objects|
      text_objects.each do |text_object|
        # 
        # Si le text-object possède les propriétés voulues, on
        # le consigne. Sinon, on le met dans la liste des mauvais
        # textes-objets pour un message d'erreur détaillé
        # 
        if text_object.matcher.has_properties?(**properties)
          new_tof.merge!(regstr => []) unless new_tof.key?(regstr)
          new_tof[regstr] << text_object
        else
          bad_tof.merge!(regstr => []) unless bad_tof.key?(regstr)
          bad_tof[regstr] << text_object
        end
      end
    end #/fin de boucle sur tous les text-objects trouvés

    # 
    # Dans tous les cas, on doit avoir trouvé au moins autant de
    # texte-objets que de textes fournis
    # 
    keys_diff = tof.keys - new_tof.keys
    assert(tof.count == new_tof.count, concocte_error_message(bad_tof, keys_diff) + source)

    # 
    # Quand un nombre précis est attendu
    #
    unless count_expected.nil?
      new_tof.each do |regstr, tos|
        assert_equal(count_expected, tos.count, (ERRORS[:failures][:bad_count_with_properties] % {searched: regstr.inspect, expected: count_expected, actual: tos.count} )+ source)
      end 
    end

    # 
    # On met les textes trouvés dans la liste, pour la liste éventuelle
    # 
    @objects_found = new_tof

  end
  alias :with :with_properties


  private

    def concocte_error_message(bad_tof, regstrs_missing)
      regstrs_missing.map do |regstr|
        bad_tof[regstr].map do |text_object|
          text_object.matcher.error_message(regstr)
        end.join("\n")
      end.join("\n")
    end

end #/class TextAssertion
end #/class Checker
end #/module PDF
