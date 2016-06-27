require 'parser'

module I18nYamlEditor::Rewriter
  class ExtractString < Parser::Rewriter
    def language
      raise NotImplementedError
    end

    def file
      raise NotImplementedError
    end

    def on_send(node)
      return if node.loc.selector.source == 'require'
      return if node.loc.selector.source == 'freeze'
      return if i18n_t?(node)
      super
    end

    def on_regexp(_node)
      nil
    end

    def on_str(node)
      key = remove_quotes(key_name(node))
      return if key.length < 2
      replace node.loc.expression, "I18n.t('#{normalize_key(key)}')"

      emit(key)
    end

    def on_dstr(node)
      symbols, variables = extract_symbols(node)
      variable_hash = variables.map { |v| "#{v[0]}: #{v[1]}" }.join(', ')

      key = symbols.join

      replacement = %{I18n.t('#{normalize_key(key)}')}
      replacement += %{, #{variable_hash})} if variables.any?

      replace node.loc.expression, replacement

      emit(key)
    end

    def on_array(node)
      convert_string_array if string_array?(node)
      node.children.each { |child| process_subchild(child) }
    end

    private

    def process_subchild(child)
      public_send "on_#{child.type}", child
    end

    def i18n_t?(node)
      child = node.children.first
      node.loc.selector.source == 't' &&
        child.type == :const &&
        child.children.last == :I18n
    end

    # TODO: emit to local I18nYamlEditor::Store
    def emit(key)
      yaml = YAML.load_file(file)
      yaml ||= {}
      yaml[language] ||= {}

      value = key.to_s

      key = normalize_key(value)

      # TODO: handle duplicate keys somehow?
      puts "Dup: #{key}" if yaml[language][key]

      yaml[language][key] = unescape(value)
      File.write(file, YAML.dump(yaml))
    end

    def unescape(value)
      value.gsub('\"', '"').gsub("\\'", "'")
    end

    def normalize_key(key)
      key.gsub(/\W/i, '_')
    end

    def insert_commas(node)
      node.children[0..-2].each do |child|
        insert_after child.loc.expression, ','
      end
    end

    def change_to_square_brackets(node)
      replace node.loc.begin, '['
      replace node.loc.end, ']'
    end

    def string_array?(node)
      node.loc.begin && node.loc.begin.source.casecmp('%w(') == 0
    end

    def convert_string_array(node)
      change_to_square_brackets(node)
      insert_commas(node)
    end

    def extract_symbols(node)
      symbols = []
      variables = []
      contains_interpolation = false
      node.children.each do |child|
        case child.type

        when :str
          symbols << key_name(child)

        when :begin
          contains_interpolation = true
          child.children.each do |subchild|
            next unless %i(send lvar ivar).include?(subchild.type)
            symbols << variable_name(subchild)
            variables << [key_name(subchild), value_for(subchild)]
          end

        when :dstr
          more_symbols, more_variables = extract_symbols(child)
          symbols += more_symbols
          variables += more_variables
        end
      end

      symbols = symbols.map { |s| remove_quotes s } unless contains_interpolation

      [symbols, variables]
    end

    def value_for(node)
      node.loc.expression.source
    end

    def variable_name(node)
      "%{#{key_name(node)}}"
    end

    def key_name(node)
      source = node.loc.expression.source
      source = source[1..-1] if node.type == :ivar
      source
    end

    def remove_quotes(source)
      source = source[1..-1] if source[0] =~ /['"]/
      source = source[0..-2] if source[-1] =~ /['"]/
      source
    end
  end
end
