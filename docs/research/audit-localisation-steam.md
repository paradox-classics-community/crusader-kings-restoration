# Audit en lecture seule de la localisation Steam

Date de l’audit : 18 juillet 2026

Installation examinée : `games/ck1-vanilla-reference`

Référence documentée : Steam, App ID `204940`, Build ID `29958`, version affichée `CK: Deus Vult 2.1 beta`

## Résumé exécutif

La version Steam examinée contient déjà des textes français, mais sa localisation française est **partielle et très inégale**.

Les treize CSV du dossier `config` partagent un schéma multilingue positionnel : clé, anglais, français, allemand, espagnol, italien, colonnes réservées, puis marqueur terminal. Les langues sont donc stockées côte à côte dans les mêmes fichiers. Sur 9 078 entrées de localisation relevées :

- 5 780 valeurs françaises sont non vides, soit 63,7 % ;
- 3 298 valeurs françaises sont vides, soit 36,3 % ;
- parmi les valeurs non vides, 789 sont le marqueur spécial `@` et 552 sont strictement identiques à l’anglais ;
- 4 439 valeurs françaises non vides diffèrent de l’anglais, sans que ce seul test permette d’en garantir la qualité linguistique ;
- aucune clé dupliquée n’a été trouvée dans un fichier ni entre les treize fichiers, avec une comparaison exacte ou insensible à la casse.

Les fichiers `event_text.csv` et `trait_names.csv` ont une colonne française entièrement renseignée. `extra_text.csv` est presque entièrement renseigné. À l’inverse, les colonnes françaises de `text.csv`, `advance_names.csv`, `law_names.csv`, `province_names.csv`, `provinceeffects_names.csv`, `provinceimprovement_names.csv` et `unit_names.csv` sont entièrement vides. `messages.csv` est partiel. `deus_vult.csv` contient surtout des marqueurs `@`, et non des traductions françaises explicites. `world_names.csv` est rempli, mais mélange valeurs distinctes, valeurs identiques à l’anglais et marqueurs `@`.

L’encodage dominant est très probablement Windows-1252 sans marque d’ordre des octets. Les fichiers ne contenant que de l’ASCII sont compatibles à la fois avec Windows-1252 et UTF-8 ; leur encodage exact ne peut donc pas être prouvé à partir des octets seuls. Tous les CSV de localisation utilisent des fins de ligne CRLF et le point-virgule comme séparateur.

Deux irrégularités structurelles demandent un test dans une copie isolée : `deus_vult.csv` juxtapose un bloc de 448 lignes à 12 colonnes et un bloc de 595 lignes à 15 colonnes ; `messages.csv` contient 16 lignes à 23 colonnes au milieu d’un schéma normalement large de 12 colonnes. Leur tolérance réelle par le moteur n’a pas été vérifiée.

## Méthode utilisée

L’audit a été réalisé sans lancer le jeu et sans modifier aucun fichier de `games/ck1-vanilla-reference`.

1. Inventaire récursif des extensions, chemins relatifs et tailles.
2. Analyse de tous les CSV du dossier `config`, puis de tous les autres CSV de l’installation.
3. Détection du séparateur par structure, puis lecture avec prise en charge des champs entre guillemets.
4. Détection d’encodage fondée sur la marque d’ordre des octets, la validité UTF-8 stricte et la possibilité de décoder en Windows-1252.
5. Comptage des lignes physiques, des largeurs de ligne, des entrées de données, des valeurs françaises vides ou non vides et des clés dupliquées.
6. Exclusion des lignes vides, des commentaires dont la première cellule commence par `#` et des lignes d’en-tête du comptage des valeurs de langue.
7. Recherche des marqueurs `@`, des valeurs françaises identiques à l’anglais, des variables de substitution courantes et des séparateurs incorporés dans des champs protégés par des guillemets.
8. Recherche structurelle, sans reproduction des textes, dans les fichiers TXT, INC et EUG ; inventaire des bitmaps d’aide et des polices bitmap.

Le « nombre de colonnes » désigne le nombre de champs après lecture CSV. Une « ligne mal formée » est ici une ligne non vide dont la largeur diffère du schéma dominant du fichier. Cette règle est volontairement stricte : elle détecte des anomalies, mais ne prouve pas que le moteur refuse les lignes concernées.

## Fichiers de localisation analysés

### Structure des CSV de `config`

| Chemin relatif | Taille (octets) | Encodage probable | Séparateur | Lignes | Colonnes | En-tête ou noms de colonnes | Lignes mal formées, test strict |
|---|---:|---|:---:|---:|---:|---|---:|
| `config/advance_names.csv` | 55 598 | Windows-1252 | `;` | 347 | 12 | Pas d’en-tête formel | 0 |
| `config/deus_vult.csv` | 77 668 | Windows-1252 | `;` | 1 043 | 12 puis 15 | `##`, `English`, `French`, `German`, `Spanish`, `Italiano`, colonnes sans nom, `x` | 448* |
| `config/event_text.csv` | 109 805 | Windows-1252 | `;` | 669 | 15 | Pas d’en-tête formel | 0 |
| `config/extra_text.csv` | 674 672 | Windows-1252 | `;` | 2 908 | 15 | `##`, `English`, `French`, `German`, `Spanish`, `Italiano`, colonnes sans nom, `X` | 0 |
| `config/law_names.csv` | 6 144 | ASCII pur, encodage exact indéterminable | `;` | 36 | 12 | Pas d’en-tête formel | 0 |
| `config/messages.csv` | 133 068 | Windows-1252 | `;` | 1 216 | 12 normalement ; 23 sur 16 lignes | Ligne-guide interne partielle : clé, `English`, `Deutsch`, `Spanish`, `Extra2`, `X` ; plusieurs cellules sans nom | 16 |
| `config/province_names.csv` | 36 786 | Windows-1252 | `;` | 1 007 | 12 | Pas d’en-tête formel | 0 |
| `config/provinceeffects_names.csv` | 4 392 | ASCII pur, encodage exact indéterminable | `;` | 34 | 12 | Pas d’en-tête formel | 0 |
| `config/provinceimprovement_names.csv` | 12 470 | ASCII pur, encodage exact indéterminable | `;` | 90 | 12 | Pas d’en-tête formel | 0 |
| `config/text.csv` | 81 006 | Windows-1252 | `;` | 1 528 | 12 | Lignes-guides internes partielles : clé, `English`, cellules sans nom, `X` | 0 |
| `config/trait_names.csv` | 115 871 | Windows-1252 | `;` | 146 | 12 | Pas d’en-tête formel | 0 |
| `config/unit_names.csv` | 2 362 | ASCII pur, encodage exact indéterminable | `;` | 25 | 12 | Pas d’en-tête formel | 0 |
| `config/world_names.csv` | 35 433 | Windows-1252 | `;` | 615 | 12 | Pas d’en-tête formel | 0 |

\* Le résultat strict de 448 lignes vient d’une rupture nette de largeur : lignes 1 à 448 sur 12 colonnes, puis lignes 449 à 1 043 sur 15 colonnes. Les deux blocs sont homogènes et conservent les mêmes six premières cellules significatives ainsi qu’un marqueur terminal. Il peut s’agir d’un assemblage historique toléré plutôt que de 448 lignes réellement invalides ; seul un test moteur peut le déterminer.

Les treize fichiers ont une colonne anglaise en deuxième position et une colonne française en troisième position. Lorsque l’en-tête est absent ou incomplet, cette identification est fondée sur le schéma positionnel commun aux fichiers `config`, sur les en-têtes complets de `deus_vult.csv` et `extra_text.csv`, et sur la nature linguistique des valeurs présentes.

### Couverture de la colonne française

| Chemin relatif | Entrées de données | Colonne anglaise | Colonne française | Français vide | Français non vide | Dont `@` | Identique à l’anglais | Clés dupliquées |
|---|---:|---|---|---:|---:|---:|---:|---:|
| `config/advance_names.csv` | 344 | Oui, colonne 2 | Oui, colonne 3 | 344 | 0 | 0 | 0 | 0 |
| `config/deus_vult.csv` | 1 026 | Oui, colonne 2 | Oui, colonne 3 | 310 | 716 | 710 | 0 | 0 |
| `config/event_text.csv` | 659 | Oui, colonne 2 | Oui, colonne 3 | 0 | 659 | 0 | 0 | 0 |
| `config/extra_text.csv` | 2 896 | Oui, colonne 2 | Oui, colonne 3 | 23 | 2 873 | 4 | 37 | 0 |
| `config/law_names.csv` | 34 | Oui, colonne 2 | Oui, colonne 3 | 34 | 0 | 0 | 0 | 0 |
| `config/messages.csv` | 1 084 | Oui, colonne 2 | Oui, colonne 3 | 292 | 792 | 0 | 261 | 0 |
| `config/province_names.csv` | 1 005 | Oui, colonne 2 | Oui, colonne 3 | 1 005 | 0 | 0 | 0 | 0 |
| `config/provinceeffects_names.csv` | 31 | Oui, colonne 2 | Oui, colonne 3 | 31 | 0 | 0 | 0 | 0 |
| `config/provinceimprovement_names.csv` | 88 | Oui, colonne 2 | Oui, colonne 3 | 88 | 0 | 0 | 0 | 0 |
| `config/text.csv` | 1 149 | Oui, colonne 2 | Oui, colonne 3 | 1 149 | 0 | 0 | 0 | 0 |
| `config/trait_names.csv` | 144 | Oui, colonne 2 | Oui, colonne 3 | 0 | 144 | 0 | 3 | 0 |
| `config/unit_names.csv` | 22 | Oui, colonne 2 | Oui, colonne 3 | 22 | 0 | 0 | 0 | 0 |
| `config/world_names.csv` | 596 | Oui, colonne 2 | Oui, colonne 3 | 0 | 596 | 75 | 251 | 0 |
| **Total** | **9 078** |  |  | **3 298** | **5 780** | **789** | **552** | **0** |

Le marqueur `@` n’est pas compté comme une valeur vide, puisqu’il est matériellement présent. Il n’est toutefois pas assimilé à une traduction française explicite. Sa fonction probable est une réutilisation ou un repli vers une autre langue, mais ce comportement n’a pas été confirmé dans le moteur.

Une valeur identique à l’anglais n’est pas nécessairement une erreur : il peut s’agir d’un nom propre, d’un code, d’une variable ou d’un terme identique dans les deux langues. Ces 552 cas nécessitent une revue contextuelle.

## Autres CSV contenant des noms ou libellés potentiels

Les douze CSV suivants ont aussi été examinés. Ils ne suivent pas le schéma de localisation multilingue de `config` et ne possèdent pas de colonne française dédiée.

| Chemin relatif | Taille (octets) | Encodage probable | Séparateur | Lignes | Colonnes | En-tête ou rôle textuel constaté |
|---|---:|---|:---:|---:|---:|---|
| `db/character_names.csv` | 130 827 | Windows-1252 | `;` | 5 801 | 3 | Pas d’en-tête formel ; culture, sexe et prénom |
| `db/country.csv` | 70 144 | ASCII pur | `;` | 1 404 | 6 | `Country`, couleurs, sprites et drapeaux |
| `db/eu2_country.csv` | 54 818 | Windows-1252 | `;` | 1 495 | 3 | Pays CK, pays EU2, nom CK |
| `db/eu2_culture.csv` | 8 997 | ASCII pur | `;` | 390 | 4 | Identifiant, culture CK, religion, marqueur |
| `db/eu2_prov.csv` | 45 648 | Windows-1252 | `;` | 1 005 | 3 | Province CK, province EU2, nom CK |
| `db/eu2_rev_country.csv` | 5 054 | Windows-1252 | `;` | 291 | 3 | Pays EU, pays CK, nom ou marqueur |
| `db/province.csv` | 233 829 | Windows-1252 | `;` | 1 008 | 53 | En-tête complet, dont numéro, identifiant, nom, région, zone et coordonnées |
| `db/spreadneighbours.csv` | 1 549 | ASCII pur | `;` | 178 | 2 | Couples d’identifiants, sans en-tête |
| `db/terrain.csv` | 116 | ASCII pur | `;` | 10 | 2 | `Name`, `MoveCost` |
| `map/colorscales.csv` | 2 379 | ASCII pur | `;` | 156 | 4 | Noms de couleurs et composantes RVB |
| `map/SpriteDB.csv` | 75 351 | Windows-1252 | `,` | 1 406 | 5 | Fichier de sprite, coordonnées et libellé géographique |
| `map/Terrain types.csv` | 169 | ASCII pur | `;` | 11 | 3 | Numéro, type de terrain, mouvement |

Ces fichiers ont tous une largeur constante après lecture CSV. La notion de « clé dupliquée » ne leur est pas appliquée : leur première colonne n’est pas toujours une clé unique et les répétitions peuvent être voulues, notamment pour les cultures, les voisinages ou les couleurs.

## Textes possibles hors CSV

| Emplacement ou format | Constat | Incidence pour une traduction |
|---|---|---|
| `db/events/*.txt` | 46 scripts, 7 564 713 octets. La recherche structurelle trouve des jetons de localisation dans les champs de nom, sans phrase naturelle directement placée dans ces champs. | Les scripts doivent rester synchronisés avec les clés des CSV ; les identifiants et variables ne doivent pas être traduits. |
| `db/dynasties.txt` | 3 487 champs de nom sur 17 445 lignes. | Noms affichables sans colonnes de langue ; une politique éditoriale distincte est nécessaire pour les noms propres. |
| `db/character_names.csv` | 5 801 lignes de prénoms associés à une culture et à un sexe. | Source de texte affiché, mais pas fichier de traduction multilingue. |
| `db/eu2_rotw_misc.txt` | 47 champs de nom sur 3 898 lignes. | Données liées à l’export EU2, sans schéma multilingue ; vérifier si elles sont visibles pendant l’export ou seulement dans les données produites. |
| `scenarios/*_scenario_characters.inc` | Trois fichiers, 7 635 champs de nom et 190 223 lignes. | Les noms de personnages font partie des données de scénario et ne doivent pas être traités comme des clés de localisation ordinaires. |
| `scenarios/*.eug` et `scenarios/*_scenario_titles.inc` | Les fichiers EUG portent des jetons de nom de scénario ; les INC de titres portent des identifiants et structures de titres. | Vérifier en jeu quels noms sont résolus par les CSV et lesquels sont directement affichés. |
| `db/credits.txt` | 2 871 octets, 216 lignes, Windows-1252 probable. | Texte de générique potentiellement affiché, à traiter séparément et avec prudence juridique. |
| `tutorial/*.bmp` | Deux images d’aide, 3 319 408 octets au total. L’audit d’utilisabilité existant confirme un tutoriel sous forme de pages d’aide statiques. | Le texte incorporé dans une image ne peut pas être traduit par les CSV ; il faut une ressource graphique dérivée ou un remplacement original autorisé. |
| `gfx/fonts/*.bmp` | Dix polices bitmap, 861 412 octets. | La présence et la qualité des glyphes accentués doivent être vérifiées visuellement dans le moteur. |
| `gfx/Interface/**/*.bmp` | 437 bitmaps d’interface. Aucun OCR exhaustif n’a été effectué. | Certains libellés peuvent être incorporés aux images ; cette possibilité reste à auditer écran par écran. |
| `ReadMe.txt` | Documentation externe de 72 727 octets. | Non classée comme texte d’interface en jeu. |
| Exécutable et formats binaires | Aucune extraction de chaînes n’a été effectuée dans `Crusaders.exe`, les vidéos ou les tables binaires. | Des libellés codés en dur ou incorporés à des médias peuvent subsister hors des fichiers textuels. |

Les 431 fichiers SPR ont également été inventoriés. Ils servent de descripteurs de sprites et n’ont pas été retenus comme fichiers de localisation.

## Bilan sur la présence du français

### Présence confirmée

La présence de français est certaine dans les fichiers installés : plusieurs milliers de cellules de la troisième colonne contiennent des valeurs distinctes de l’anglais, et 2 367 valeurs françaises renseignées contiennent au moins un caractère non ASCII. Les textes d’événements, de nombreux textes supplémentaires, les traits et une partie des messages sont déjà localisés.

### Complétude

La localisation ne peut pas être qualifiée de complète. Le déficit touche des familles importantes : texte général de l’interface, avancées, lois, provinces, effets provinciaux, améliorations et unités. Le simple taux brut de 63,7 % de cellules non vides surestime en outre la couverture utile, car il inclut les marqueurs `@` et les valeurs identiques à l’anglais.

La conclusion la plus prudente est donc : **français présent, localisation partielle, couverture hétérogène et probablement insuffisante pour une expérience entièrement francophone**.

### Stockage multilingue

Les langues principales sont stockées dans les mêmes CSV de `config`, par colonnes. Les en-têtes complets identifient l’anglais, le français, l’allemand, l’espagnol et l’italien. Des colonnes supplémentaires sans nom sont réservées avant le marqueur terminal. Il ne faut ni supprimer ni réordonner ces colonnes sans test moteur.

## Risques techniques pour une future traduction

### Encodage et accents

- Les fichiers contenant des caractères étendus ne sont pas des UTF-8 valides et sont cohérents avec Windows-1252.
- Aucun des CSV de localisation ne possède de marque d’ordre des octets.
- Une conversion involontaire en UTF-8, l’ajout d’une marque d’ordre des octets ou le remplacement des CRLF peut rendre les fichiers incompatibles avec le moteur ou produire des caractères corrompus.
- La présence d’accents dans les données ne prouve pas que toutes les polices bitmap couvrent correctement tous les glyphes français.

### Structure CSV

- Le point-virgule est le séparateur des fichiers de localisation.
- Au moins 16 lignes contiennent un point-virgule à l’intérieur d’un champ protégé par des guillemets : un découpage naïf avec `split(';')` est donc dangereux.
- Les colonnes réservées et le marqueur terminal doivent être préservés.
- `deus_vult.csv` combine deux largeurs de schéma ; `messages.csv` contient un bloc de largeur atypique. Une normalisation automatique pourrait casser un comportement historique toléré.

### Variables et marqueurs spéciaux

- Les textes utilisent des variables de substitution. Le contrôle automatisé des variables courantes n’a trouvé aucune discordance entre anglais et français parmi les cellules françaises explicites déjà remplies, mais ce test ne couvre pas nécessairement toute la syntaxe interne du moteur.
- Le marqueur `@` doit être compris avant toute substitution en masse.
- Les jetons de localisation présents dans les scripts d’événements ne doivent pas être traduits comme du texte visible.

### Longueur et mise en page

- Les champs anglais observés atteignent 1 346 caractères dans `advance_names.csv` ; des champs français existants atteignent 606 caractères dans `trait_names.csv` et 317 caractères dans `messages.csv`.
- Les fenêtres et zones de texte du jeu sont anciennes et probablement contraintes. Une traduction française plus longue peut provoquer coupures, débordements ou chevauchements.
- Les libellés courts doivent être testés avec les polices bitmap et à la résolution native de l’interface.

### Clés et fichiers spéciaux

- Aucune clé dupliquée n’a été trouvée dans l’état actuel des treize CSV de localisation, mais un futur pipeline doit conserver ce contrôle à chaque génération.
- Les noms de personnages, dynasties, provinces, titres et scénarios ne suivent pas tous le même mécanisme de localisation.
- Les pages d’aide bitmap, les éventuels libellés incorporés à l’interface et les chaînes potentiellement codées en dur nécessitent des audits séparés.

## Limitations de l’analyse

- L’audit porte sur les fichiers réellement présents dans la référence locale documentée, mais ne compare pas cette installation à d’autres langues Steam, à une édition disque ou à un ancien correctif.
- Le jeu n’a pas été lancé. La sélection effective du français, les règles de repli, le sens exact de `@` et la tolérance aux largeurs atypiques restent à confirmer.
- La détection d’encodage est probabiliste. Un fichier ASCII pur ne permet pas de distinguer Windows-1252 d’UTF-8.
- Les comptes « vide » et « non vide » sont syntaxiques. Ils ne mesurent ni la qualité, ni la fidélité, ni l’adéquation contextuelle d’une traduction.
- Une valeur identique à l’anglais n’est pas automatiquement une absence de traduction.
- Aucun OCR exhaustif des bitmaps, aucune transcription des vidéos et aucune extraction de chaînes de l’exécutable n’ont été réalisés.
- Aucun long extrait de contenu propriétaire n’est reproduit dans ce rapport.

## Prochaines étapes recommandées

1. Copier uniquement les fichiers nécessaires dans `games/ck1-testing` et vérifier en jeu la sélection du français, le repli des cellules vides et le comportement de `@`.
2. Tester sans les modifier les deux schémas de `deus_vult.csv` et le bloc atypique de `messages.csv`, puis documenter ce que le moteur accepte réellement.
3. Écrire un validateur original qui préserve Windows-1252, CRLF, guillemets, nombre de colonnes, marqueur terminal, variables et unicité des clés.
4. Prioriser la traduction de `text.csv`, puis des lois, avancées, améliorations, effets provinciaux et unités, car leurs colonnes françaises sont entièrement vides.
5. Soumettre les 552 valeurs identiques à l’anglais et les 789 marqueurs `@` à une revue contextuelle, sans les remplacer automatiquement.
6. Construire une matrice de tests de longueur et de glyphes accentués sur les principales fenêtres, les infobulles et les événements.
7. Auditer séparément les deux pages d’aide bitmap, les bitmaps d’interface susceptibles de contenir du texte, les crédits et les noms intégrés aux scénarios.
8. Définir avant publication un format de correctif qui n’embarque pas les fichiers propriétaires d’origine et ne redistribue que le travail original autorisé.
