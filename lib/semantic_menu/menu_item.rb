class MenuItem
  include ActionView::Helpers::TagHelper,
    ActionView::Helpers::UrlHelper

  attr_accessor :children, :link, :is_first, :is_last
  cattr_accessor :controller

  def initialize(title, link, level, link_opts={})
    @title, @link, @level, @link_opts = title, link, level, link_opts
    @is_first, @is_last = false, false
    @children = []
  end

  def add(title, link, link_opts={}, &block)
    @children.last.is_last = false unless @children.last.nil?

    MenuItem.new(title, link, @level +1, link_opts).tap do |adding|
      @children << adding
      yield adding if block_given?
    end

    @children.first.is_first = true unless @children.first.nil?
    @children.last.is_last = true unless @children.last.nil?
  end
  
  def to_s
    css_classes = []
    css_classes << "active" if active?
    css_classes << "current" if on_current_page?
    css_classes << "first" if first?
    css_classes << "last" if last?
    @link_opts[:class] = @link_opts[:class] || ""
    @link_opts[:class] << css_classes.join(" ")
    content_tag :li, SemanticMenu::Util.html_safe(link_to(@title, @link, @link_opts) + child_output)
  end

  def level_class
    "menu_level_#{@level}"
  end

  def child_output
    children.empty? ? '' : content_tag(:ul, SemanticMenu::Util.html_safe(@children.collect(&:to_s).join), :class => level_class)
  end

  def first?
    @is_first
  end
  
  def last?
    @is_last
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
