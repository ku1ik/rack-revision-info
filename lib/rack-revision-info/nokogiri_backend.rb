require 'nokogiri'

# extending Nokogiri with 'append' and 'prepend' methods

Nokogiri::XML::Element.class_eval do
  def append(data)
    child = self.children.last
    child && child.after(data) || add_child(data)
  end

  def prepend(data)
    child = self.children.first
    child && child.before(data) || add_child(data)
  end
end
