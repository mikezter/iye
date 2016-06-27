require 'yaml'

CONFIG_FILE = 'config/locales/de.yml'.freeze

class ExtractString < Parser::Rewriter
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

    if variable_hash.empty?
      replace node.loc.expression, %{I18n.t('#{normalize_key(key)}')}
    else
      replace node.loc.expression, %{I18n.t('#{normalize_key(key)}', #{variable_hash})}
    end

    emit(key)
  end

  def on_array(node)
    if string_array?(node)
      change_to_square_brackets(node)
      insert_commas(node)
    end
    node.children.each do |child|
      case child.type
      when :str
        on_str(child)
      when :dstr
        on_dstr(child)
      when :array
        on_array(child)
      when :hash
        on_hash(child)
      end
    end
  end

  private

  def i18n_t?(node)
    child = node.children.first
    node.loc.selector.source == 't' &&
      child.type == :const &&
      child.children.last == :I18n
  end

  def emit(key)
    yaml = YAML.load_file(CONFIG_FILE) if File.exist?(CONFIG_FILE)
    yaml = { 'de' => {} } unless yaml
    value = key.to_s

    key = normalize_key(value)

    puts "Dup: #{key}" if yaml['de'][key]

    yaml['de'][key] = unescape(value)
    File.write(CONFIG_FILE, YAML.dump(yaml))
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
