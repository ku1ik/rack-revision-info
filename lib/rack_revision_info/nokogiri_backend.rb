require 'nokogiri'

# extending Nokogiri with 'append' and 'prepend' methods

class Nokogiri::XML::Element
  def append(data)
    self.inner_html = inner_html + data
  end

  def prepend(data)
    self.inner_html = data + inner_html
  end
end

