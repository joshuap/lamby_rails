class ApplicationController < ActionController::Base
  def index
    render html: "<h1>Hello Lamby</h1>".html_safe
  end

  def badgers
    fail 'badgers!'
  end
end
