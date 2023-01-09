module PDF
class Checker
class Page

  # - shortcut -
  def walk(receiver)
    self.reader_page.walk(receiver)
  end

  # @return [Array<Array<???>>] All receivers of all pages
  def self.receivers_callbacks
    reader.pages.map do |page|
      page.receivers_callbacks
    end
  end

  # @return [Array<Hash>] List of each text with positioning, fonts,
  # and properties. Each item contains :
  #   :content    [String|Array] The text of array of texts
  #   :type       [Symbol] :txt (simple text) or :twp (text with positioning)
  #   :properties [Hash]
  #       :font       {:name, :size}
  #       :cursor2d   {:left, :top}
  def texts_with_properties
    scenario if not(defined?(@texts_with_properties))
    @texts_with_properties
  end

  # @return [Scenario] The "script" of the page, i.e. the callback
  # in human format/
  # This method must be called to get 
  # 
  def scenario
    @scenario ||= begin
      ary     = []
      textes  = []
      current_2d_cursor = {left: nil, top: nil}
      current_font_size = {font: nil, size: nil}
      current_text_properties = {}
      receivers_callbacks.each do |cb|
        args = cb[:args]
        case cb[:name]
        when :show_text_with_positioning, :show_text
          props = current_text_properties.merge({
            font_name: current_font_size[:name], 
            font_size: current_font_size[:size],
            left: current_2d_cursor[:left],
            top: current_2d_cursor[:top],
          })
          type, content = case cb[:name]
            when :show_text
              ary << "TEXT POSITIONNÉ : #{args} (#{args.count})"
              [:txt, args.join(' ')]
            else
              ary << "TEXT : #{args}"
              [:twp, args.map { |seg| seg.select { |sseg| sseg.is_a?(String)}.join('') }.join(' ') ]
            end
          textes << {content:content, type: type, properties: props, raw_content: args}
        when :save_graphics_state
          # if args?
          ary << "Callback: :save_graphics_state"
        when :move_text_position
          ary << "2DCURSOR left & top set at #{args[0]} & #{args[1]}"
          current_2d_cursor = {left:args[0], top:args[1]}
        when :set_text_font_and_size
          ary << "FONT & TAILLE set at #{args[0]} & #{args[1]}"
          current_font_size = {name: args[0], size: args[1]}
        when :begin_text_object
          ary << "-> TXT OBJ"
        when :end_text_object
          ary << "<- TXT OBJ"
        when :concatenate_matrix
          ary << "CONTMATRIX #{args.inspect}"
        when :invoke_xobject
          ary << "INVOKE XOBT #{args}"
        when :restore_graphics_state
          # if args?
          ary << "Callback: :restore_graphics_state"
        when :page=
          ary << "Sur la page…"
        else
          ary << "Type de callback inconnu : #{cb[:name]}"
        end
      end
      @texts_with_properties = textes
      ary
    end
  end

  # @return [Array<???>] All receivers of this page
  def receivers_callbacks
    receiver = PDF::Reader::RegisterReceiver.new
    walk(receiver)
    receiver.callbacks
  end

  def get_all_textes
    receiver = ShowTextReceiver.new(self)
    walk(receiver)
    return receiver.textes
  end

end #/class Page

=begin
  Essai pour faire un receveur
=end
class ShowTextReceiver

  attr_reader :textes

  def initialize(page)
    @page = page
    @textes = []
    @current_text = nil
    @prov_properties = {}
  end

  def set_or_retain(property, args)
    if @current_text
      @current_text.set(property, args)
    else
      @prov_properties.merge!(property => args)
    end
  end
  def begin_text_object(*args)
    @current_text = PDF::Checker::Page::Text.new(@page)
    @textes << @current_text
    unless @prov_properties.empty?
      @prov_properties.each { |prop, v| @current_text.set(prop, v)}
      @prov_properties = {}
    end
  end
  def move_text_position(*args)
    set_or_retain(:move_text_position, args)
  end
  def move_to_start_of_next_line(*args)
    set_or_retain(:move_to_start_of_next_line, args)
  end
  def set_character_spacing(*args)
    set_or_retain(:character_spacing, args)
  end
  def set_word_spacing(*args)
    set_or_retain(:word_spacing, args)
  end
  def set_horizontal_text_scaling(*args)
    set_or_retain(:horizontal_text_scaling, args)
  end
  def set_text_font_and_size(*args)
    set_or_retain(:text_font_and_size, args)
  end
  def set_text_leading(*args)
    set_or_retain(:text_leading, args)
  end
  def set_text_rendering_mode(*args)
    set_or_retain(:text_rendering_mode, args)
  end
  def set_text_rise(*args)
    set_or_retain(:text_rise, args)
  end
  def show_text_with_positioning(*args)
    set_or_retain(:show_text_with_positioning, args)
  end
  def show_text(*args)
    set_or_retain(:show_text, args)
  end
  def set_text_matrix_and_text_line_matrix(*args)
    set_or_retain(:text_matrix_and_text_line_matrix, args)
  end
  def set_spacing_next_line_show_text(*args)
    set_or_retain(:spacing_next_line_show_text, args)
  end
  def end_text_object(*args)
    @current_text = nil
  end
end #/class ShowTextReceiver

end #/class Checker
end #/class PDF
