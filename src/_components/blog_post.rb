class BlogPost < Bridgetown::Component
  attr_reader :post, :post_level, :keep_reading

  def initialize(post:, post_level: :h2, keep_reading: false)
    @post, @post_level, @keep_reading = post, post_level, keep_reading
  end
end
