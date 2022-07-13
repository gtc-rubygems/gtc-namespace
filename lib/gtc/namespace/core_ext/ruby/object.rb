
require "gtc/namespace/base"

# patches the Object class to directly access the namespace
class Object
  # returns a new namespace object which can be used to resolve namespace-related modules
  # @return [::GTC::Namespace::Base] namespace
  def namespace
    ::GTC::Namespace::Base.new(self.is_a?(Module) ? self : self.class)
  end
end