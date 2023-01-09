require_relative 'assertion'
module PDF
class Checker
  class NegAssertion < PDF::Checker::Assertion

    def has_text(strs, error_tmp = nil, options = nil)
      options ||= {}
      owner.has_text(strs, error_tmp, options.merge!(negative: true))
    end

  end #/class NegAssertion
end #/class Checker
end #/module PDF
