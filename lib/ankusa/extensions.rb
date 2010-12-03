require 'iconv'

class String
  def numeric?
    true if Float(self) rescue false
  end
  
  def to_ascii
    # from http://www.jroller.com/obie/tags/unicode
    converter = Iconv.new('ASCII//IGNORE//TRANSLIT', 'UTF-8') 
    converter.iconv(self).unpack('U*').select { |cp| cp < 127 }.pack('U*') rescue ""
  end
end
