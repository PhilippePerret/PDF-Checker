module PDF
class Checker

  def creator
    info[:Creator]
  end

  def info
    reader.info
  end

  def metadata
    reader.metadata
  end

  def pdf_version
    reader.pdf_version
  end

  def producer
    info[:Producer]
  end

end #/class Checker
end #/module PDF
