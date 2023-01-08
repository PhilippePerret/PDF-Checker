module ErrorModule

  LANG = 'fr' # static pour le moment

  LOCALES_FILE = File.join(__dir__,'locales', "#{LANG}.yaml")

  ERRORS = YAML.load_file(LOCALES_FILE, symbolize_names: true)

end #/module ErrorModule
