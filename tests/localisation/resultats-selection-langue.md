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
- Les boutons vides sont cohérents avec l'audit : la colonne française de `config/text.csv` contient des cellules vides. Le lien entre chaque bouton et une clé précise reste à confirmer avant toute modification.
- Le comportement moteur du marqueur `@` demeure non confirmé. Les candidats ci-dessous doivent d'abord être observés sans modification.
- Les débordements constatés confirment un risque de mise en page pour les textes français existants ; chaque fenêtre concernée nécessitera une vérification visuelle dédiée.

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

## Candidats `@` à observer sans modification

Les trois clés suivantes ont une cellule française égale à `@` dans `config/world_names.csv`. Elles sont retenues car le même identifiant est un `tag` de titre dans les fichiers de scénarios installés. Cette correspondance structurelle relie directement la clé de localisation à un titre affichable, sans reproduire son libellé.

| Clé technique | Scénario concerné | Entité ou type d'écran | Chemin de navigation le plus court | Raisons de fiabilité |
|---|---|---|---|---|
| `MILA` | 1066, 1187 et 1337 | Fiche du détenteur du titre, puis panneau de ses titres ou de sa province principale. | Charger l'un des trois scénarios avec le détenteur du titre `MILA`, puis ouvrir sa fiche et son panneau de titres. | La clé figure avec `@` dans `world_names.csv` ; `MILA` est aussi déclaré comme `tag` de titre dans les trois fichiers `*_scenario_titles.inc` et attribué dans les données de scénario. |
| `CATA` | 1066 et 1337 | Fiche du détenteur du titre, puis panneau de ses titres ou de sa province principale. | Charger 1066 avec le détenteur du titre `CATA`, puis ouvrir sa fiche et son panneau de titres. | La clé figure avec `@` dans `world_names.csv` ; `CATA` est déclaré comme `tag` dans les fichiers de titres 1066 et 1337, et il est attribué dans les données de ces scénarios. |
| `ROMA` | 1066 et 1187 | Panneau du titre territorial et fiche de son détenteur. | Charger 1066 ou 1187, sélectionner sur la carte le titre portant le tag `ROMA`, puis ouvrir le panneau du titre ou la fiche du détenteur. | La clé figure avec `@` dans `world_names.csv` ; `ROMA` est déclaré comme `tag` de titre et comme liege dans les fichiers de titres 1066 et 1187. |

`LANG` n'est pas retenue : son association avec un élément visible n'est pas démontrée sans ambiguïté par les fichiers examinés. Elle ne doit donc pas servir de test avant une preuve visuelle directe.

## Suite recommandée

1. Reprendre les trois candidats en français avec `language 1`, sans toucher aux CSV.
2. Consigner, pour chacun, l'affichage réel du `@` : repli, vide, autre langue ou anomalie.
3. Ne choisir une sentinelle temporaire qu'après une association clé-écran confirmée visuellement.
