class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildWindow
  end

  def buildWindow
    @director = Joybox::Configuration.setup do
      #director display_stats: false
    end

    @main_window = NSWindow.alloc.initWithContentRect([[240, 180], [1024, 768]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)

    @main_window.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @main_window.contentView.addSubview(@director.view)
    @main_window.orderFrontRegardless

    @director.run_with_scene(MenuLayer.scene)
  end
end
