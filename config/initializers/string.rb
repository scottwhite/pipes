class String
  def to_phone_number
    return if self.blank?
    m= self.match(/(\d{3})(\d{3})(\d{4})/)
    "#{m[1]} #{m[2]} #{m[3]}"
  end
end