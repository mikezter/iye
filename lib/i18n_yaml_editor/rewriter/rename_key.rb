require 'parser'

module I18nYamlEditor::Rewriter
  class RenameKey < Parser::Rewriter
    def on_send(node)
      return super unless i18n_t?(node)
      return super unless match_from?(node)

      replace stringnode(node).loc.expression, "'#{to}'"
    end

    def from
      raise NotImplementedError
    end

    def to
      raise NotImplementedError
    end

    def self.name
      'RenameKey'
    end

    private

    def match_from?(node)
      stringnode(node).children.first == from
    end

    def stringnode(node)
      node.children[2] && node.children[2]
    end

    def i18n_t?(node)
      child = node.children.first
      node.loc.selector.source == 't' &&
        child.type == :const &&
        child.children.last == :I18n
    end
  end
end
