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
pdf = PDF::Checker.new("mon.pdf", **options)
pdf.strings
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

<a name="assertion-has_text-with_properties"></a>

### Assertion `has_text(...).with_properties(...)`

On peut ajouter la recherche de propriétés :

~~~ruby
pdf.has_text("Bonjour tout le monde").with_properties({at: [100,10], font:'Helvetica', size:15})
~~~

… ou avec des raccourcis :

~~~ruby
pdf.has_text("Bonjour tout le monde").with({at: [100,10], font:'Helvetica', size:15})
~~~

> Noter que pour le `:at`, il y a une approximation dont la tolérance peut être définie précisément avec :
>
> `PDF::Checker.set_config(:coordonates_tolerance, <nouvelle valeur>[.<unit>])`

On peut définir le message d’erreur :

~~~ruby
pdf.has_text("Bonjour", "Le document devrait contenir le texte 'Bonjour'")
~~~

### Assertion `has_text(...).with(...)`

Alias raccourci de [`has_text(...).with_properties(...)`](#assertion-has_text-with_properties).

<a name="assertion-has_text-at"></a>

### Assertion `has_text(...).at(...)`

Permet de contrôler qu’un ou des textes sont à leur place.

Pour voir [les arguments de `has_text`](#asssertion-has_text).

`at` peut recevoir plusieurs arguments, de 1 à 3.

Si elle ne reçoit qu’un argument, c’est :

* SOIT la valeur **:top** attendue,

  ~~~ruby
  pdf.page(1).has_text("Mon texte").at(100)
  # => Le texte doit avoir un top à 100
  ~~~

* SOIT une table contenant au choix : `{:left, :top, :right, :bottom}`.

  ~~~ruby
  pdf.page(1).has_text("Mon texte").at(**{top:100.0, left:23})
  # => le texte "Mon texte" doit avoir un top de 100 et un left de 23
  ~~~

Si `at` reçoit **2 arguments**, ce sont :

* SOIT une table de propriétés (comme ci-dessus) et le delta autorisé (tolérance)

  ~~~ruby
  pdf.page(1).has_text("Mon texte").at(**{top:100.0, left:23}, 10)
  # => le texte "Mon texte" doit avoir un top de 100 et un left de 23
  # 	 avec une tolérance de 10.
  ~~~

* SOIT la valeur **:left** et la valeur **:top**

  ~~~ruby
  pdf.page(1).has_text("Mon texte").at(20, 100)
  # => Le texte "Mon texte" doit avoir un top à 100 et un left à 20
  ~~~

  > Bien noter que dans ce cas le top devient le second argument.

Si `at` reçoit **3 arguments**, ce sont dans l’ordre : le **:left**, le **:top** et la **tolérance** (le “delta”).

<a name="assertion-has_text-close_to"></a>

### Assertion `has_text(...).close_to(...)`

Cette méthode produit une erreur si le texte n’existe pas (testé par `has_text`) et ne se trouve pas aux coordonnées indiquées par les arguments de `close_to` avec une tolérance de 2 (dont une petite tolérance).

C’est en fait la même assertion que [`at`](#assertion-has_text-at) mais avec une tolérance définie.

La méthode attend 2 arguments qui correspondent aux deux premiers de la méthode [`at`](#assertion-has_text-at) (le `:top` s’il n’y en a qu’un seul, le `:left` et le `:top` s’il y en a 2).

<a name="assertion-has_text-near"></a>

### Assertion `has_text(...).near(...)`

Cette méthode produit une erreur si le texte n’existe pas (testé par `has_text`) et ne se trouve pas aux coordonnées indiquées par les arguments de `near` avec une tolérance correspondant à la tolérance par défaut.

C’est en fait la même assertion que [`at`](#assertion-has_text-at) mais avec une tolérance définie.

La méthode attend 2 arguments qui correspondent aux deux premiers de la méthode [`at`](#assertion-has_text-at) (le `:top` s’il n’y en a qu’un seul, le `:left` et le `:top` s’il y en a 2).

On peut définir la tolérance par défaut à l’aide de :

~~~ruby
PDF::Checker.set_config(:coordonates_tolerance, <new value>)
~~~

---



<a name="assertion-has_texte-properties"></a>

#### `has_text(...).with|with_properties` propriétés

~~~bash
at: 		[Array<Integer|String>] Position du contenu du texte
				On peut changer l’unité (par défaut, ce sont des postscript-points
				avec : <integer|float>.mm ou <integer|float>.in etc.
width: 	[Integer|String] Largeur du contenu du texte
				Là aussi on peut définir une autre unité avec <float>.<unit>
height: [Integer|String] Hauteur du contenu du texte
				Là aussi on peut définir une autre unité avec <float>.<unit>
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

### `.include?(args)`

{Ancienne méthode, mais toujours active}

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

### `.has_page_number?(<nombre pages>)`

Retourne true si le document contient bien ce nombre de page.

---

## Propriétés d’une instance `PDF::Checker`

### `.page(x).texts_with_properties`

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

### `.page(x).texts`

La liste des textes de la page de numéro `x`.

> La valeur doit être plus sûre que `#strings` ci-dessous.

<a name="property-text"></a>

### `.page(x).text`

Le texte complet de la page `x`, de façon rigoureuse.

> Ici aussi, la valeur doit être plus sûre qu’avec `#strings` ci-dessous.

<a name="strings-property"></a>

### `.strings`

Retourne la liste des strings. Attention, les phrases peuvent être découpées en lignes.

<a name="plain_text-property"></a>

### `.plain_text`

Le texte complet, mais pas forcément exact dans le détail, puisque c’est simplement la propriété [`#strings`](#string-property) qui est jointe avec des espaces.

<a name="page-properties"></a>

### `.page(x)`

Retourne l’instance Page de la page `x` (1-start). C’est une instance `PDF::Checker::Page`.
