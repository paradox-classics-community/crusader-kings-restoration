# Résultats — sélection de langue CK1

Date de consignation : 18 juillet 2026

## Périmètre

Ce compte rendu consigne des observations manuelles déjà obtenues sur la copie de test, ainsi qu'une sélection statique de clés `@` à observer lors de la prochaine phase. Il a été produit sans nouvelle exécution du jeu ni modification manuelle de ses fichiers. Il consigne toutefois des observations provenant d'essais antérieurs durant lesquels le jeu a été lancé et certains fichiers runtime, notamment `config.eu`, ont été modifiés automatiquement par le moteur. Aucune sentinelle n'a été créée pour ce compte rendu.

## Résultats confirmés directement

| Observation | Résultat confirmé |
|---|---|
| Accès à la console | `F12` ouvre la console seulement après le chargement d'une campagne. |
| Commande `language 0` | La langue affichée est l'anglais. |
| Commande `language 1` | La langue affichée est le français. |
| Prise d'effet | Le changement de langue est immédiat dans la session en cours. |
| Persistance | Après redémarrage, le jeu revient à l'anglais. |
| Interface française | De nombreux boutons n'affichent aucun libellé. |
| Événements français | Des événements sont traduits, mais certains textes débordent sur les portraits ou hors de leur cadre. |

## Identifications linguistiques à confiance élevée, fondées sur lecture visuelle

| Commande | Langue identifiée | Niveau de confiance | Réserve |
|---|---|---|---|
| `language 2` | Allemand | Élevé | Identification visuelle ; elle n'a pas été confirmée par instrument ou par une clé de contrôle dédiée. |
| `language 3` | Espagnol | Élevé | Identification visuelle ; même réserve. |
| `language 4` | Italien | Élevé | Identification visuelle ; même réserve. |

## Conclusions techniques

- La commande interne `language <n>` sélectionne une langue durant la session chargée ; `language 1` active bien le français dans l'installation testée.
- Cette sélection n'est pas persistée de façon observable entre deux démarrages : le retour à l'anglais est constaté, sans attribuer la cause à un fichier ou mécanisme précis.
- Les boutons vides sont cohérents avec l'audit : la colonne française de `config/text.csv` contient des cellules vides. Pour le panneau de province de Rome, les correspondances précises sont maintenant fortement étayées ci-dessous ; toute modification future exige néanmoins une confirmation visuelle clé-écran.
- Le comportement moteur du marqueur `@` demeure non confirmé. Les candidats ci-dessous doivent d'abord être observés sans modification.
- Les débordements constatés confirment un risque de mise en page pour les textes français existants ; chaque fenêtre concernée nécessitera une vérification visuelle dédiée.

## Comparaison du panneau de province : Rome, scénario 1066

### Observations manuelles directes

| Élément observé | Anglais (`language 0`) | Français (`language 1`) |
|---|---|---|
| Libellés du panneau | Les libellés Income, Plunder, Religion, Culture, Terrain, Fortification et Supply Limit sont visibles. | Presque tous ces libellés disparaissent. |
| Valeur de culture | `Italian` est visible. | La valeur devient `Italien`. |
| Valeurs numériques | Visibles. | Restent visibles. |
| Bouton d'action | `Pillage!` possède un libellé. | Le libellé disparaît. |
| Nom de province en haut du panneau | `Roma` est visible. | `Roma` reste visible et paraît identique. |

### Preuves statiques pour les libellés d'interface

Les huit correspondances ci-dessous forment un bloc continu de `config/text.csv` dédié au panneau de province. Les cellules anglaises correspondent exactement aux libellés observés et chaque cellule française est vide, non `@`.

| Libellé observé | Clé identifiée | Fichier et ligne | État de la cellule française |
|---|---|---|---|
| Income | `IW_PROV_INCOME` | `config/text.csv:1125` | Vide |
| Plunder | `IW_PROV_PLUNDER` | `config/text.csv:1126` | Vide |
| Religion | `IW_PROV_RELIGION` | `config/text.csv:1127` | Vide |
| Culture | `IW_PROV_CULTURE` | `config/text.csv:1128` | Vide |
| Terrain | `IW_PROV_TERRAIN` | `config/text.csv:1129` | Vide |
| Fortification | `IW_PROV_FORTS` | `config/text.csv:1130` | Vide |
| Supply Limit | `IW_PROV_SUPPORT` | `config/text.csv:1132` | Vide |
| Pillage! | `IW_PROV_PILLAGE_ACTION` | `config/text.csv:1131` | Vide |

### Source probable de `Roma`

| Fichier | Preuve statique | Portée de la conclusion |
|---|---|---|
| `config/province_names.csv` | La clé `PROV333` a `Roma` dans la cellule anglaise et une cellule française vide. | Source localisée la plus probable du nom en haut du panneau de la province 333. |
| `db/province.csv` | L'enregistrement de province 333 porte également `Roma` dans son champ `#Name`. | Source de données brute possible ou repli possible ; la capture seule ne permet pas de distinguer ce chemin de celui de `province_names.csv`. |
| `config/world_names.csv` | La clé `ROMA` a une cellule française `@`, mais sa cellule anglaise n'est pas `Roma`. Elle correspond aussi à un tag de titre dans le scénario. | Cette clé ne peut pas être la source du `Roma` observé dans cette comparaison. |

La source localisée la plus probable est donc `config/province_names.csv`, via `PROV333`. L'identité du texte entre ce fichier et `db/province.csv` empêche toutefois d'établir, sans instrumenter ou modifier le jeu, si le moteur lit directement ce CSV ou s'il utilise le nom brut comme repli.

### Conclusions limitées sur les cellules vides et `@`

- Pour ce panneau précis, les observations et le bloc de clés correspondant apportent une preuve forte qu'une cellule française vide produit un libellé absent plutôt qu'un repli anglais. Cette conclusion est limitée aux huit clés `IW_PROV_*` identifiées.
- La valeur de culture traduite confirme que le français est bien actif dans le même panneau, alors que les valeurs numériques restent indépendantes de ces cellules de texte.
- Cette comparaison ne confirme pas le comportement de `@` : `ROMA` de `world_names.csv` n'est pas relié au texte visible `Roma`. Il est donc interdit d'en déduire un repli vers l'anglais.

## Comparaison binaire de `config.eu`

### Observations

Les trois fichiers comparés font 460 octets. `settings.txt` est resté identique à sa sauvegarde initiale : 21 octets, même SHA-256 et aucun octet différent.

| Version | SHA-256 |
|---|---|
| Originale | `04481F5C7FE03FFB71152121A86372BD05E03CD9109CCC047484816D64690BFA` |
| Après session normale | `B249AE91037B20460BA138043151C529CA50770758EA26B40C2F2BE79C37216E` |
| Après essais `language 0` à `4` | `27EE1A0B94C0805A2ED769280820A334F1523D207B1DFF5FDECB4E5A0A36E791` |

| Comparaison | Octets différents | Plage contiguë |
|---|---:|---|
| Originale / session normale | 1 | `0x01C4-0x01C4` |
| Originale / essais de langues | 1 | `0x01C4-0x01C4` |
| Session normale / essais de langues | 1 | `0x01C4-0x01C4` |

| Offset | Originale | Session normale | Essais de langues |
|---|---:|---:|---:|
| `0x01C4` (452) | `1D` | `1E` | `1F` |

### Interprétation limitée

- À `0x01C4`, les quatre octets forment, dans chaque version, un entier non signé little-endian : 29, 30 puis 31. Les octets de poids fort restent nuls.
- Cette progression est compatible avec un compteur ou un champ numérique simple ; elle ne correspond pas à un booléen et ne ressemble pas à une chaîne, les valeurs modifiées n'étant pas des caractères ASCII imprimables.
- `config.eu` est modifié après une session normale. Sa modification après les commandes `language` ne prouve donc pas une persistance de la langue.
- Le jeu revient à l'anglais au redémarrage ; la signification précise de cette différence binaire reste à déterminer.

## Problèmes d'interface observés

- Libellés absents sur de nombreux boutons en français.
- Textes d'événements parfois superposés aux portraits.
- Textes d'événements parfois affichés hors de leur cadre.

## Prochaine observation du marqueur `@`

La meilleure clé unique retenue est `MILA`. Sa cellule française vaut `@` dans `config/world_names.csv` et le même identifiant est un `tag` de titre dans les fichiers de titres des scénarios 1066, 1187 et 1337. L'association statique avec un élément affichable est donc démontrée, contrairement à `ROMA` dans le panneau de province.

Préparation de l'observation, sans sentinelle ni modification : charger le scénario 1066 avec un personnage jouable, par exemple la France, localiser Milan sur la carte, ouvrir la fiche de son détenteur puis son panneau de titres, et comparer l'affichage du titre sous `language 0` puis `language 1`. Il n'est pas nécessaire que le détenteur du titre `MILA` soit lui-même jouable. Ne préparer une sentinelle dans la cellule française de `MILA` qu'après avoir confirmé visuellement que cet écran résout bien cette clé.
