# PDF::Checker

Ma classe personnelle pour rationaliser l’utilisation de PDF::Inspector.

Par exemple, au lieu de faire :

~~~ruby
rendered_pdf = File.open("mon.pdf", 'r')
text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
text_analysis.strings # => ["foo"]
~~~

On fera :

~~~ruby
checker = PDF::Checker.new("mon.pdf", **options)
checker.strings
~~~

