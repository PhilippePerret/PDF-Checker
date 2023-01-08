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

La première chose à faire est d’instancier un *checker*. Il attend simplement le chemin d’accès au document PDF (on pourra, plus tard, ajouter quelques options) :

~~~ruby
require 'pdf/checker'

pdf = PDF::Checker.new("path/to/doc.pdf")
~~~

On peut ensuite utiliser les assertions sur cette instance, qui se présentent toujours comme des affirmations simples. Par exemple, une affirmation donnant le nombre de pages :

~~~ruby
pdf.has(5.pages)
# => Si le document doc.pdf contient 5 pages, une réussite sera
#    produite, sinon, une failure sera initiée.
~~~

Pour faire référence à une page précise, on utilise la tournure :

~~~ruby
pdf.page(x).<methode>
~~~

Par exemple, pour contrôler que la page 12 contient bien 4 images, on utilise :

~~~ruby
pdf.page(12).has(4.images)
# => Failure si la page numéro 12 (la vraie 12e) ne contient pas
#    exactement 4 images.
~~~

Comme on peut le voir, la méthode `#has` reçoit un simple nombre d’objets d’un certain type (page, image, graphique, etc.). On utilise ensuite des méthodes plus précises pour contrôler en détail les différents éléments. À commencer par les méthodes :

* **`has_text`**, pour contrôler la présence précise d’un texte à un endroit précis avec des propriétés précises,
* **`has_image`**, pour contrôler la présence d’une image précise, à l’endroit précis avec les propriétés précises,
* **`has_header`**, idem pour les entête,
* **`has_footer`**, idem pour les pieds de page.

Nous allons voir ces méthodes en détail.

<a name="asssertion-has_text"></a>

### Assertion `has_text`

Cette assertion attend un seul argument : le texte ou les textes à trouver dans le PDF ou la page. 

Par exemple :

~~~ruby
pdf.has_text("Bonjour tout le monde")
pdf.has_text(["Bonjour", "tout", "le", "monde"])
pdf.has_text(/(Bonjour|Au revoir) tout le monde/i)
pdf.page(2).has_text("Bonjour")
~~~

ou la négation :

~~~ruby
pdf.not.has_text("Bonjour tout le monde")
~~~

On peut ajouter des propriétés :

~~~ruby
pdf.has_text("Bonjour tout le monde").with_properties({at: [100,10], font:'Helvetica', size:15})
~~~

… ou avec des raccourcis :

~~~ruby
pdf.has_text("Bonjour tout le monde").with({at: [100,10], font:'Helvetica', size:15})
~~~

> Noter que pour le `:at`, il y a une approximation dont la tolérance peut être définie précisément. TODO

On peut définir le message d’erreur :

~~~ruby
pdf.has_text("Bonjour", "Le document devrait contenir le texte 'Bonjour'")
~~~



<a name="assertion-has_texte-properties"></a>

#### `has_text` propriétés

~~~bash
at: 		[Array<Integer|String>] Position du contenu du texte
width: 	[Integer|String] Largeur du contenu du texte
font: 	[String] La fonte du texte
size: 	[Integer|String] La taille du texte
color:  [String] La couleur du texte
page: 	[Integer] La page de début du texte
pages:	[Array<Integer>] Les pages si le texte tient sur plusieurs pages
~~~



<a name="assertion-has_image"></a>

### Assertion `has_image`

<a name="assertion-has_header"></a>

### Assertion `has_header`

Pas encore implémenté

<a name="negative-assertion"></a>

### Assertion négative

Comme on a pu le voir précédemment, on marque l’assertion négative à l’aide du *préfixe* `not` :

~~~ruby
pdf.not.has_text("Bonjour")
~~~



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

### `[Array<Hash>] <checker>.page(x).texts_with_properties`

C’est sans doute la donnée la plus importante de toutes. Elle contient des informations précises sur tous les textes de la page `x`. Les propriétés sont détaillées ci-dessous.

~~~
content: 		[String] 	Le contenu textuel, le texte
type: 			[Symbol] 	Le type de texte, entre celui écrit par show_text (:txt)
 											et celui écrit par show_text_with_positioning (:twp)
font_name 	[String] 	Nom de la fonte, qui peut être "F1.0" ou le nom explicite
font_size 	[Integer] Taille de la police (peut être un Float ?)
left 				[Float] 	Position horizontal du texte
top 				[Float] 	Position verticale du texte.
# TODO D'autres propriétés peuvent suivre, en définition le leading, 
# les "caractères spacing" et autres propriétés pouvant affecter les textes
~~~



<a name="property-texts"></a>

### `[Array<String>] <checker>.page(x).texts`

La liste des textes de la page de numéro `x`.

> La valeur doit être plus sûre que `#strings` ci-dessous.

<a name="property-text"></a>

### `[String] <checker>.page(x).text`

Le texte complet de la page `x`, de façon rigoureuse.

> Ici aussi, la valeur doit être plus sûre qu’avec `#strings` ci-dessous.

<a name="strings-property"></a>

### `[Array<String>] <checker>#strings`

Retourne la liste des strings. Attention, les phrases peuvent être découpées en lignes.

<a name="plain_text-property"></a>

### `[String] <checker>#plain_text`

Le texte complet, mais pas forcément exact dans le détail, puisque c’est simplement la propriété [`#strings`](#string-property) qui est jointe avec des espaces.

<a name="page-properties"></a>

### `[PDF::Checker::Page] <checker>#page(x)`

Retourne l’instance Page de la page `x` (1-start).
