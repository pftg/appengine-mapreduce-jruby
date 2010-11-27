module StringHelper
  extend self

  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

  def underscore(camel_cased_word)
    word = camel_cased_word.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

class ::String
  def camelize
    StringHelper.camelize(self)
  end
end

class ::Symbol
  def camelize
    StringHelper.camelize(self)
  end
end
