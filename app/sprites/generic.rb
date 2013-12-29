class Generic < Joybox::Core::Sprite

  def initialize(opts={})
    super frame_name: opts[:frame_name], position: opts[:position]
  end

  def touched?(touch_location)
    rect = CGRect.new(boundingBox.origin, boundingBox.size)
    CGRectContainsPoint(rect, touch_location)
  end
end