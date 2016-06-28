#!/usr/bin/env ruby
# be bin/iye \
#   ~/codevault.io/kaeuferportal/pdf_templates/config/locales \
#   ~/codevault.io/kaeuferportal/pdf_templates

source_folder = '~/codevault.io/kaeuferportal/pdf_templates/config/locales'
code = '~/codevault.io/kaeuferportal/pdf_templates'

require 'i18n_yaml_editor'
require 'rack'

iye_app = I18nYamlEditor::App.new(source_folder, code: code)
$stdout.puts " * Loading translations from #{iye_app.full_path}"
$stdout.puts " * Will rewrite Ruby code at #{iye_app.code_path}" if code
$stdout.puts " * Starting web editor at port 5050"
run I18nYamlEditor.endpoint_for_app(iye_app)
