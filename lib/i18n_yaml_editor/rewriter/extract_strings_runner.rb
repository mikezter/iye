require 'find'
require 'parser/runner/ruby_rewrite'

module I18nYamlEditor::Rewriter
  class ExtractStringRunner < Parser::Runner::RubyRewrite
    def initialize(path, language, file)
      super()
      @modify = true
      @files = files(path)

      rewriter = Class.new(ExtractString) do
        define_method(:language) { language }
        define_method(:file) { file }
      end

      @rewriters = [rewriter]
    end

    def go
      execute([])
    end

    def files(path)
      path = File.expand_path(path)
      files = []
      return files unless File.directory?(path)
      Find.find(path) { |f| files << f if f.end_with? '.rb' }
      files
    end
  end
end
