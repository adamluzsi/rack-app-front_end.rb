module Rack::App::FrontEnd::Helpers::HtmlDsl
  UnImplementedError = Class.new(StandardError)

  require 'rack/app/front_end/helpers/html_dsl/block'
  require 'rack/app/front_end/helpers/html_dsl/tag_builder'

  def self.build(method_name, *args, &block)
    case method_name.to_s

      when /_tag$/
        tag_name = method_name.to_s.sub(/_tag$/, '')
        TagBuilder.build(tag_name,*args,&block)

      else
        raise(UnImplementedError)

    end
  end

  def method_missing(method_name,*args,&block)
    Rack::App::FrontEnd::Helpers::HtmlDsl.build(method_name,*args,&block)
  rescue UnImplementedError
    super
  end

  def form_tag(*args, &block)
    args.unshift({'method' => "get", 'accept-charset' => "UTF-8"})
    super
  end

end
