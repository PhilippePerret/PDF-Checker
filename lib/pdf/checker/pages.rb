module PDF
class Checker

  # @return [] Page numéro x
  # @note
  #   Unlike PDF::Reader#page which raises a exception when page is missing, PDF::Checker.page return nil
  def page(x)
    begin
      @pages ||= {}
      @pages[x] ||= Page.new(self, reader.page(x))
    rescue PDF::Reader::InvalidPageError
      return nil
    end
  end

  # @return [Integer] Page count
  def page_count
    reader.page_count    
  end


end #/class Checker
end # module PDF
