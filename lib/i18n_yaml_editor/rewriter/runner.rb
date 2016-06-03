require 'find'
require 'parser/runner/ruby_rewrite'

module I18nYamlEditor::Rewriter
  class Runner < Parser::Runner::RubyRewrite
    def initialize(path, old_key, new_key)
      super()
      @modify = true
      @files = files(path)

      rewriter = Class.new(RenameKey) do
        define_method(:from) { old_key }
        define_method(:to) { new_key }
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
