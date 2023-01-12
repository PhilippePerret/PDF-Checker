class Numeric
  include Prawn::Measurements

  # Depuis les ps-points vers les millimètres
  def to_mm
    "#{pt2mm(self)}mm"
  end

  def to_cm
    "#{(pt2mm(self).to_f/10).round(3)}cm"
  end

end #/class Numeric
