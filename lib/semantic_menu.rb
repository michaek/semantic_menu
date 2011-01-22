require 'rubygems'
require 'action_view'
require 'active_support'
require 'semantic_menu/menu_helper'
require 'semantic_menu/menu_item'

# Include hook code here
ActionView::Base.send :include, MenuHelper

class SemanticMenu < MenuItem
  # Adapted from Formtastic::Util, which was in turn
  # Adapted from the rails3 compatibility shim in Haml 2.2
  module Util
    extend self
    ## Rails XSS Safety

    # Returns the given text, marked as being HTML-safe.
    # With older versions of the Rails XSS-safety mechanism,
    # this destructively modifies the HTML-safety of `text`.
    #
    # @param text [String]
    # @return [String] `text`, marked as HTML-safe
    def html_safe(text)
      return text if text.nil?
      return text.html_safe if defined?(ActiveSupport::SafeBuffer)
      return text.html_safe!
    end

    def rails_safe_buffer_class
      return ActionView::SafeBuffer if defined?(ActionView::SafeBuffer)
      ActiveSupport::SafeBuffer
    end
  end

  def initialize(controller, opts={},&block)
    @@controller = controller
    @opts       = {:class => 'menu'}.merge opts
    @level      = 0
    @children   = []

    yield self if block_given?
  end

  def to_s
    content_tag(:ul, SemanticMenu::Util.html_safe(@children.collect(&:to_s).join), @opts)
  end
end
