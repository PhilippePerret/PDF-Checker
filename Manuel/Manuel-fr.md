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

## Utilisation

---

<a name="assertions"></a>

## Assertions

### `<checker>#include?(args)`

Retourne true si le document contient l’argument

L’argument peut être :

- une chaine ou une liste de chaines de caractères,

- une expression régulière ou une liste d’expressions régulières,

- un table définissant au moins `:string`, la chaine à trouver, ainsi que d’autres attributs permettant d’affiner la recherche. Par exemple :

  ~~~ruby
  checker.include?({string:"le", after:"Bonjour", before:"monde", near:'tout'}) 
  ~~~

  … renverra `true` si le document contient le mot “le” placé après (`:after`) le mot “Bonjour” et avant (`:before`) le mot “monde” et se trouvera prêt (à moins de 30 caractères, en comptant la longueur du mot, — `:near` de “tout”.

- une liste contenant un de ces éléments, même une liste.

<a name="assertion-has-page-number"></a>

### `<checker>#has_page_number?(<nombre pages>)`

Retourne true si le document contient bien ce nombre de page.

---

## Propriétés

<a name="strings-property"></a>

### `[Array<String>] <checker>#strings`

Retourne la liste des strings. Attention, les phrases peuvent être découpées en lignes.

<a name="plain_text-property"></a>

### `[String] <checker>#plain_text`

Le texte complet, mais pas forcément exact dans le détail, puisque c’est simplement la propriété [`#strings`](#string-property) qui est jointe avec des espaces.

<a name="page-properties"></a>

### `[PDF::Checker::Page] <checker>#page(x)`

Retourne l’instance Page de la page `x` (1-start).
