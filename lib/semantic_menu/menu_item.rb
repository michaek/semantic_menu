class MenuItem
  include ActionView::Helpers::TagHelper,
    ActionView::Helpers::UrlHelper

  attr_accessor :children, :link
  cattr_accessor :controller

  def initialize(title, link, level, link_opts={})
    @title, @link, @level, @link_opts = title, link, level, link_opts
    @children = []
  end

  def add(title, link, link_opts={}, &block)
    MenuItem.new(title, link, @level +1, link_opts).tap do |adding|
      @children << adding
      yield adding if block_given?
    end
  end

  def to_s
    css_classes = ""
    css_classes << " active" if active?
    css_classes << " current" if on_current_page?
    @link_opts[:class] = @link_opts[:class] || ""
    @link_opts[:class] << css_classes
    content_tag :li, SemanticMenu::Util.html_safe(link_to(@title, @link, @link_opts) + child_output)
  end

  def level_class
    "menu_level_#{@level}"
  end

  def child_output
    children.empty? ? '' : content_tag(:ul, SemanticMenu::Util.html_safe(@children.collect(&:to_s).join), :class => level_class)
  end

  def active?
    children.any?(&:active?) || on_current_page?
  end

  def on_current_page?
    current_page?(@link)
  end

  # Provide a 'request' method to account for Rails 3's new current_page?-method
  def request
    @@controller.request
  end
end
