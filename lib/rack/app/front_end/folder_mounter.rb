class Rack::App::FrontEnd::FolderMounter

  LAST_MODIFIED_HEADER = "Last-Modified"

  def initialize(app_class)
    @app_class = app_class
  end

  def mount(absolute_folder_path)
    template_paths_for(absolute_folder_path).each do |template_path|

      request_path = request_path_by(absolute_folder_path, template_path)
      template = Rack::App::FrontEnd::Template.new(template_path, :fallback_handler => Rack::App::File::Streamer)
      create_endpoint_for(request_path, template)

    end
  end

  protected

  def template_paths_for(source_folder_path)
    Dir.glob(File.join(source_folder_path, '**', '*')).select { |p| not File.directory?(p) }
  end

  def create_endpoint_for(request_path, template)
    @app_class.class_eval do

      get(request_path) do
        result = template.render(self)

        if result.is_a?(::Rack::App::File::Streamer)
          response.length += result.length
          response.headers[LAST_MODIFIED_HEADER]= result.mtime
          response.body = result
        elsif result.respond_to?(:each)
          result.each{|str| response.write(str) }
        else
          response.write(self.class.layout.render(result))
        end
        response.finish
      end

    end
  end

  def request_path_by(source_folder_path, template_path)
    Rack::Utils.clean_path_info(template_path.sub(source_folder_path, '').split(File::Separator).join('/'))
  end

end