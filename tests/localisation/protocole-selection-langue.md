# Protocole expérimental — sélection de langue CK1

Date de préparation : 18 juillet 2026

## Objet et garde-fous

Ce document prépare une expérimentation réversible du système de langues de Crusader Kings Complete / Deus Vult. Il ne constitue pas encore une exécution de test.

Pendant toute future expérimentation :

- ne jamais modifier `games/ck1-vanilla-reference` ;
- intervenir uniquement dans `games/ck1-testing` ;
- ne pas modifier le manifeste Steam, le registre Windows, la langue Windows ou les options de lancement Steam ;
- ne pas installer de composant ni lancer l’exécutable depuis la référence ;
- ne pas copier de contenu du jeu dans le dépôt ni publier de capture contenant des textes du jeu ;
- restaurer les octets d’origine des CSV et réglages contrôlés après chaque variante, avant de passer à la suivante ;
- archiver séparément les journaux runtime afin de ne pas perdre leurs indices ; ne les réinitialiser que si leur accumulation empêche d’isoler un essai.

Le présent travail est limité à l’analyse statique des fichiers et de l’exécutable, à une lecture du manifeste Steam local et à une recherche documentaire communautaire. Le jeu n’a pas été lancé.

## Mécanismes de sélection recherchés

| Mécanisme | Indice observé | Niveau de preuve | Conclusion opérationnelle |
|---|---|---|---|
| Langue Steam de l’application | `C:\Program Files (x86)\Steam\steamapps\appmanifest_204940.acf` contient `language = english` dans `UserConfig` et `MountedConfig`. | Confirmé pour cette installation Steam. | Steam possède une préférence de langue pour l’App ID `204940`. Son effet exact sur l’exécutable lancé depuis `games/ck1-testing` reste à démontrer. Ne pas modifier ce manifeste pendant le protocole. |
| Commande interne | L’exécutable contient l’aide `language num`, une borne numérique dynamique et le jeton `LANGUAGE`. Les chaînes voisines sont des commandes du jeu. | Fort indice statique. | Tester la commande dans la console du jeu de la copie de test, sans présumer la correspondance entre numéro et langue. |
| Accès à la console | Une source communautaire indique l’usage de `F12` pour saisir des commandes dans CKDV. | Indice externe non officiel. | Essayer `F12` uniquement sur `games/ck1-testing`. Si la console n’est pas accessible, arrêter ce chemin et documenter l’échec. |
| Locale Windows | `Crusaders.exe` importe `GetUserDefaultLCID`, `GetLocaleInfoA` et `GetLocaleInfoW`. | Confirmé pour l’exécutable ; rôle précis inconnu. | La locale utilisateur Windows peut contribuer à la langue par défaut ou au repli. Ne pas la modifier : ce protocole ne doit pas toucher à l’environnement global. |
| `config.eu` | Fichier binaire de 460 octets, sans jeton textuel relatif à la langue ; même SHA-256 dans la référence et la copie de test avant essai. | Écarte une préférence textuelle évidente, sans exclure un champ binaire. | Ne jamais l’éditer à l’aveugle. Le sauvegarder et comparer son empreinte avant/après un changement de langue exécuté en jeu. |
| `settings.txt` | Aucun jeton de langue ; les réglages connus concernent l’affichage et la musique. | Écarté comme sélecteur apparent. | Ne pas l’utiliser pour ce test. |
| Option de ligne de commande | L’exécutable importe `GetCommandLineA`, mais aucune chaîne littérale `-language`, `/language`, `-lang` ou `/lang` n’a été trouvée. | Négatif partiel. | Aucun paramètre de lancement n’est validé. Ne pas tester de variantes inventées. |
| Registre Paradox | Aucun sous-arbre pertinent n’a été trouvé dans les emplacements Paradox usuels accessibles au profil courant et aux vues 32 bits examinées. | Négatif dans cet environnement uniquement. | Aucun réglage de langue dans le registre n’est identifié. Ne créer ni ne modifier de clé. |

## Indices sur le marqueur `@`

L’audit de localisation trouve 789 cellules françaises égales à `@` : 710 dans `config/deus_vult.csv`, 4 dans `config/extra_text.csv` et 75 dans `config/world_names.csv`.

La structure est très régulière :

- pour 788 de ces 789 lignes, la cellule anglaise est renseignée et les quatre cellules française, allemande, espagnole et italienne sont toutes `@` ;
- une seule ligne suit le motif anglais renseigné, français `@`, allemand et espagnol renseignés, italien `@` ;
- l’analyse statique indique que le marqueur est très probablement une valeur de contrôle, et non un texte destiné à être affiché littéralement ; son comportement doit encore être confirmé dans le moteur.

L’hypothèse la plus forte est un repli sur l’anglais lorsqu’une traduction n’est pas fournie. Elle doit néanmoins être validée à l’exécution : le moteur pourrait aussi produire une cellule vide, utiliser une autre colonne ou appliquer une règle spéciale selon le type de texte.

## Clés minimales retenues

Les clés suivantes ont été choisies pour leur petite taille, leur structure sans variable de substitution et une voie d’affichage identifiable. Les libellés eux-mêmes ne sont pas reproduits.

| Cas | Fichier et ligne | Clé | État français | Longueur anglaise / française | Voie d’observation proposée |
|---|---|---|---|---:|---|
| Français explicite et accentué | `config/world_names.csv:5` | `CULTURE_SWEDISH` | Valeur explicite contenant au moins un caractère non ASCII | 7 / 7 | Écran de personnage ou de province avec culture suédoise. Les trois scénarios contiennent de telles occurrences. |
| Français vide | `config/text.csv:293` | `FEOPT_OK` | Cellule vide | 2 / 0 | Bouton de validation des options de l’interface frontale. `OK` dans le même fichier est une solution de repli si cette clé ne s’affiche pas. |
| Marqueur `@` candidat provisoire | `config/world_names.csv:341` | `LANG` | `@` | 4 / 1 | À utiliser seulement si son association avec un élément visible est confirmée sans ambiguïté ; sinon choisir une autre clé `@` observable. |

Dans ce protocole uniquement, `text.csv` et `world_names.csv` sont les deux CSV cibles structurés sur 12 colonnes, avec point-virgule, Windows-1252 probable et CRLF. Cette règle des 12 colonnes ne s’applique pas aux autres fichiers de localisation. Chaque édition future de ces deux fichiers doit préserver ces propriétés et ne toucher que la troisième colonne de la clé ciblée.

## Fichiers qui seraient modifiés ou produits pendant le test

| Chemin | Action future autorisée | Rôle |
|---|---|---|
| `games/ck1-testing/config/text.csv` | Modification temporaire de la troisième cellule de `FEOPT_OK`, puis restauration exacte. | Vérifier le comportement d’une cellule française initialement vide. |
| `games/ck1-testing/config/world_names.csv` | Modification temporaire de la troisième cellule de `CULTURE_SWEDISH` et, seulement si `LANG` est confirmé comme visible, de cette clé ou d’une autre clé `@` retenue, puis restauration exacte. | Vérifier une valeur française explicite, les accents Windows-1252 et le marqueur `@`. |
| `games/ck1-testing/config.eu` | Aucune édition manuelle ; copie de sauvegarde et comparaison d’empreinte avant/après. | Détecter une éventuelle persistance binaire du choix de langue. |
| `games/ck1-testing/history.txt`, `exceptions.log` | Aucune édition manuelle ; archivage séparé par variante, avec réinitialisation uniquement si nécessaire pour isoler un essai. | Conserver les indices produits par l’exécutable. |
| `games/ck1-testing/.localisation-backups/<horodatage>/` et `.../.localisation-runtime/<horodatage>/<variante>/` | Création future de copies de sécurité et d’archives privées, hors dépôt public. | Restaurer les CSV/réglages contrôlés et conserver séparément les journaux runtime. |

Ne doivent jamais être modifiés : `games/ck1-vanilla-reference/**`, `C:\Program Files (x86)\Steam\steamapps\appmanifest_204940.acf`, les clés de registre, la locale Windows, les options Steam et les fichiers du dépôt autres que ce protocole.

## Protocole proposé

### 0. Préparation et point de restauration

1. Confirmer que l’exécutable à lancer est `games/ck1-testing/Crusaders.exe` et que la référence vanilla n’est pas ouverte.
2. Créer dans `games/ck1-testing/.localisation-backups/<horodatage>/` des copies binaires de `config/text.csv`, `config/world_names.csv`, `config.eu` et `settings.txt` s’ils existent. Créer en parallèle une archive séparée dans `games/ck1-testing/.localisation-runtime/<horodatage>/` pour `history.txt` et `exceptions.log`.
3. Relever les SHA-256, tailles, encodage, fins de ligne et nombre de colonnes des deux CSV cibles.
4. Vérifier que `config/text.csv` contient bien `FEOPT_OK` avec une troisième cellule vide, et que `config/world_names.csv` contient `CULTURE_SWEDISH` et `LANG` aux états indiqués ci-dessus.
5. Préparer une fiche privée d’observation : date, numéro de langue demandé, écran ouvert, clé ciblée, résultat visible, empreintes avant/après et éventuelle erreur. Ne pas joindre de capture propriétaire au dépôt.

### 1. Établir le chemin de sélection de langue

1. Lancer uniquement `games/ck1-testing/Crusaders.exe` sans option inventée et relever la langue initiale visible sur l’écran d’accueil.
2. Ouvrir la console avec `F12` si elle est effectivement disponible. Si elle ne l’est pas, ne pas essayer d’autres raccourcis au hasard : noter l’échec et arrêter cette branche.
3. Dans la console, saisir `language 0`, puis observer l’une des clés de contrôle. Redémarrer la copie de test si le changement n’est pas immédiat.
4. Tester ensuite les valeurs numériques suivantes progressivement : si `0` a été accepté et s’est montré stable, poursuivre avec `1`, puis demander la valeur suivante seulement si la précédente est acceptée et stable. Ne présumer ni la plage ni la correspondance avec les colonnes ; s’arrêter immédiatement en cas de valeur refusée, d’erreur ou d’instabilité.
5. Ne pas supposer que le français est l’index `2` ou un autre index. Déterminer l’index français par l’affichage de `CULTURE_SWEDISH`, dont la cellule française explicite contient un caractère accentué.
6. Après chaque essai, fermer proprement le jeu, archiver séparément `history.txt` et `exceptions.log` avec l’identifiant de la variante, puis comparer les empreintes de `config.eu` et `settings.txt` aux copies initiales. Ne réinitialiser les journaux que si leur accumulation empêche d’isoler l’essai suivant ; ne pas les restaurer systématiquement.

Critère de succès de cette phase : un numéro identifie de façon reproductible la colonne française, sans modification du manifeste Steam, du registre ou de la locale Windows.

### 2. Observations sans modification

Cette phase doit être entièrement terminée avant toute écriture dans un CSV.

1. Avec le numéro français identifié, observer `CULTURE_SWEDISH` dans une fiche de personnage ou de province et relever le rendu de son caractère accentué.
2. Observer `FEOPT_OK` dans l’écran d’options frontal alors que sa cellule française est encore vide ; utiliser `OK` seulement comme solution de repli si `FEOPT_OK` n’est pas localisable avec certitude.
3. Pour `LANG`, ne poursuivre que si le tag peut être associé sans ambiguïté à un élément réellement visible dans la carte, un titre ou un scénario. Sinon, sélectionner ici une autre clé contenant `@` et facilement observable, et consigner ce choix avant toute modification.
4. Pour la clé `@` retenue, observer d’abord son comportement original, sans modifier le CSV.
5. Archiver `history.txt` et `exceptions.log` séparément pour cette phase. Les journaux ne sont réinitialisés que si un essai précédent les rend ambigus.

À l’issue de cette phase, les observations possibles sans modification doivent être consignées. Les sentinelles temporaires ne sont autorisées qu’ensuite.

### 3. Vérifier une cellule française explicite et les accents

1. Activer le numéro français identifié à la phase 1.
2. Ouvrir une fiche de personnage ou de province dont la culture est suédoise, présente dans les trois scénarios installés.
3. Observer l’affichage de `CULTURE_SWEDISH` : le libellé doit être distinct de l’anglais et afficher correctement son caractère accentué.
4. Pour dissocier la sélection de langue de la police, et seulement après l’observation sans modification, remplacer temporairement uniquement la cellule française de cette clé par la sentinelle originale `É_TEST`, encodée en Windows-1252. Pour `text.csv` et `world_names.csv` uniquement, préserver le point-virgule, les 12 colonnes, les CRLF et le marqueur final de la ligne.
5. Relancer ou rafraîchir l’écran. Si `É_TEST` est visible sans caractère corrompu ni glyphe manquant, la lecture de la troisième colonne et la chaîne Windows-1252 sont confirmées pour cet écran.
6. Restaurer immédiatement l’octet-à-octet du CSV depuis la copie de sauvegarde et vérifier son SHA-256.

### 4. Vérifier une cellule française vide

1. Reprendre l’observation de `FEOPT_OK` effectuée en phase 2, sans modifier le CSV.
2. Seulement après cette observation, placer temporairement la sentinelle `VIDE_TEST` dans la troisième cellule de `FEOPT_OK`, sans toucher aux autres cellules.
3. Relancer ou rafraîchir l’écran et vérifier si la sentinelle apparaît sur le même contrôle. Cette étape valide l’association clé-écran avant toute interprétation du comportement initial.
4. Restaurer le fichier de sauvegarde, relancer une dernière fois et vérifier le retour au comportement observé à l’étape 1.

Si `FEOPT_OK` ne peut pas être localisé avec certitude, utiliser la clé de repli `OK`, également vide en français, puis documenter ce remplacement avant toute sentinelle.

### 5. Vérifier le marqueur `@`

1. Reprendre l’observation originale de la clé `@` retenue en phase 2, sans modifier le fichier.
2. Noter le résultat du marqueur `@` : repli anglais, vide, autre langue ou erreur.
3. Seulement après cette observation, remplacer temporairement uniquement le `@` de la troisième cellule par `AROBASE_TEST`.
4. Relancer ou rafraîchir l’écran. L’apparition de cette sentinelle confirme que l’écran résout bien cette clé dans la colonne française.
5. Restaurer `@` depuis la copie binaire, relancer et comparer l’affichage à l’étape 2.

Le rapprochement des étapes 2 et 5 permet d’établir le comportement réel de `@` sans altérer la colonne anglaise ni les autres langues.

### 6. Clôture et restauration

1. Fermer le jeu normalement.
2. Restaurer `text.csv`, `world_names.csv` et `config.eu` ou `settings.txt` s’ils ont été modifiés, depuis les sauvegardes de l’horodatage courant. Conserver `history.txt` et `exceptions.log` dans leurs archives séparées ; ne les réinitialiser qu’en cas de besoin d’isolation documenté.
3. Vérifier que les SHA-256 finaux de `text.csv`, `world_names.csv`, `config.eu` et `settings.txt` correspondent à l’état de départ du test.
4. Vérifier que rien n’a été écrit dans `games/ck1-vanilla-reference` et que le dépôt ne contient ni extrait, ni sauvegarde, ni capture du jeu.
5. Conserver uniquement un compte rendu factuel privé : index de langue établi, persistance éventuelle, résultat vide, résultat `@`, rendu des accents et erreurs. Une synthèse publiable ne doit contenir que des métadonnées et conclusions techniques.

## Incertitudes et conditions d’arrêt

- La relation exacte entre la préférence Steam `language = english` et l’exécutable hors répertoire Steam n’est pas démontrée.
- Le numéro correspondant au français dans `language num` est inconnu.
- La commande est très probablement une commande de console, non une option de lancement ; l’exécutable lit bien la ligne de commande, mais aucun paramètre de langue n’est confirmé.
- `config.eu` peut contenir un réglage binaire de langue malgré l’absence de jeton textuel ; il ne faut jamais le modifier par inférence.
- Les appels de locale Windows peuvent participer au choix initial ou à un repli, mais le protocole ne doit pas changer la langue du système.
- L’écran exact de `FEOPT_OK` et la voie la plus courte vers `LANG` doivent être confirmés dans l’interface anglaise avant toute mutation de CSV ; `LANG` doit être remplacée par une autre clé `@` si cette association reste ambiguë.

Arrêter immédiatement le test et restaurer les sauvegardes si :

- le jeu écrit dans la référence vanilla ;
- `text.csv` ou `world_names.csv` perd ses 12 colonnes, ses CRLF ou son encodage Windows-1252 ; cette règle ne vaut pas pour les autres fichiers de localisation ;
- l’exécutable signale une erreur de fichier de langue ;
- la console ou une valeur de langue produit une instabilité empêchant une restauration contrôlée ;
- le test nécessiterait de modifier Steam, le registre ou Windows.

## Résultat attendu de l’expérimentation

À l’issue du protocole, le projet doit pouvoir répondre, avec une observation reproductible, aux cinq questions suivantes :

1. Quelle voie active réellement la colonne française dans cette installation ?
2. Quel index interne, s’il existe, correspond au français ?
3. Que produit une cellule française vide ?
4. Que produit exactement `@` ?
5. Les caractères accentués Windows-1252 sont-ils affichés correctement dans une fenêtre réelle du jeu ?
