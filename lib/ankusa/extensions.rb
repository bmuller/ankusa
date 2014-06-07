class String
  def to_ascii
    encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "").force_encoding('UTF-8') rescue ""
  end
end
