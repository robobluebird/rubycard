class CoolListener
  def initialize(swt_app, elem)
    @swt_app = swt_app
    @elem = elem
  end

  def handle_event(event)
    event.x = event.x + @elem.left
    event.y = event.y + @elem.top

    if event.type == ::Swt::SWT::MouseDown
      @swt_app.real.notify_listeners(::Swt::SWT::MouseDown, event)
    elsif event.type == ::Swt::SWT::MouseUp
      @swt_app.real.notify_listeners(::Swt::SWT::MouseUp, event)
    elsif event.type == ::Swt::SWT::MouseMove
      @swt_app.real.notify_listeners(::Swt::SWT::MouseMove, event)
    elsif event.type == ::Swt::SWT::MouseDoubleClick
      @swt_app.real.notify_listeners(::Swt::SWT::MouseDoubleClick, event)
    end
  end
end
