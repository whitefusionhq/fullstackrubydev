require "tilt"

module Tilted
  def tilt(tmpl, method_name = nil, locals: {}, &block)
    block = method(method_name) if method_name.is_a?(Symbol)
    calling_context = self

    template = Class.new(Tilt::ERBTemplate) do
      define_method(:_calling_context) { calling_context }
      define_method(:_calling_context_locals) { locals }
      define_method(:_calling_context_block) { block }

      def render
        super(_calling_context, _calling_context_locals) do
          add_decoration_to_string _calling_context_block.call
        end
      end

      def add_decoration_to_string(str)
        str.to_s + " <"
      end
    end

    template.new(tmpl).render
  end
end

class TiltExample
  include Tilted

  def use_block
    tilt "tilt_dsl_template.erb", locals: {yay: "It worked!"} do
      "All #{good} :)"
    end
  end

  def use_method
    tilt "tilt_dsl_template.erb", :feeling, locals: {yay: "w00t"}
  end

  def world
    "World"
  end

  def good
    "good"
  end

  def feeling
    "I feel " + good.upcase
  end
end

example = TiltExample.new
puts example.use_block
puts
puts example.use_method