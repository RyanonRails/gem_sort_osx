class StarMatchLayer < Joybox::Core::Layer
  scene

  def on_enter
    setup_sounds
    load_sprite_sheet
    handle_touches
  end

  def setup_sounds
    @audio_effect = AudioEffect.new
    @audio_effect.add(effect: :hit, file_name: 'sounds/hit.caf')
    @audio_effect.add(effect: :miss, file_name: 'sounds/miss.caf')
  end

  def load_sprite_sheet
    SpriteFrameCache.frames.add file_name: 'sprites/stars.plist'
    @sprite_batch = SpriteBatch.new file_name: 'sprites/stars.png'
    self << @sprite_batch

    @box_green = Box.new({frame_name: 'green_box.png', position: [900,200], colour: 'green'})
    @box_blue = Box.new({frame_name: 'blue_box.png', position: [900,400], colour: 'blue'})
    @box_red = Box.new({frame_name: 'red_box.png', position: [900,600], colour: 'red'})

    @star_green = Star.new({frame_name: 'green_star.png', position: [100,200],
                            colour: 'green', home_position: [100,200]})
    @star_blue = Star.new({frame_name: 'blue_star.png', position: [100,300],
                            colour: 'blue', home_position: [100,300]})
    @star_red = Star.new({frame_name: 'red_star.png', position: [100,100],
                             colour: 'red', home_position: [100,100]})

    @level_select_button = LevelSelectButton.new({frame_name: 'back.png', position: [100,700]})

    @sprite_batch << @star_green
    @sprite_batch << @star_blue
    @sprite_batch << @star_red
    @sprite_batch << @box_green
    @sprite_batch << @box_blue
    @sprite_batch << @box_red
    @sprite_batch << @level_select_button

    @stars = Array.new
    [@star_green, @star_blue, @star_red].each do |s|
      @stars << s
    end

    @boxes = Array.new
    [@box_blue, @box_red, @box_green].each do |b|
      @boxes << b
    end
  end

  def handle_touches
    on_mouse_down do |event, button|
      @stars.each do |s|
        if s.touched?(event.location)
          s.movable = true
          sprite_to_front(s)
        end
      end

      if @level_select_button.touched?(event.location)
        @level_select_button.load_home
      end

    end

    on_mouse_dragged do |event, button|
      @stars.each do |s|
        if s.movable
          s.position = event.location
        end
      end
    end

    on_mouse_up do |event, button|
      movable_star = nil
      touched_box = nil

      @stars.each do |s|
        movable_star = s if s.movable
      end
      matched_box = touching_matched_box(movable_star, event) if movable_star

      if matched_box && movable_star && matched_box.colour == movable_star.colour
        sprite_remove(movable_star)
        @stars.delete(movable_star)
        @audio_effect.play :hit
        game_ended?
      else
        if movable_star
          @audio_effect.play :miss
          move_to_action = Move.to position: movable_star.home_position
          movable_star.run_action move_to_action
          movable_star.movable = false
        end
      end
    end
  end

  def sprite_to_front(sprite)
    @sprite_batch.removeChild(sprite)
    @sprite_batch << sprite
  end

  def sprite_remove(sprite)
    @sprite_batch.removeChild(sprite)
  end

  def sprite_show(sprite)
    show_action = Visibility.show
    sprite.run_action show_action
  end

  def sprite_hide(sprite)
    hide_action = Visibility.hide
    sprite.run_action hide_action
  end

  def sprite_toggle_visibility(sprite)
    toggle_visibility_action = Visibility.toggle
    sprite.run_action toggle_visibility_action
  end

  def touching_matched_box(sprite, touch)
    touched_box = nil
    @boxes.each do |b|
      touched_box = b if b.touched?(touch.location)
    end

    return touched_box if touched_box && touched_box.colour == sprite.colour
    nil
  end

  def game_ended?
    Joybox.director.replace_scene StarMatchLayer.scene if @stars.empty?
  end
end
