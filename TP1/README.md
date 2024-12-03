Petit script d'auto-correction pour le [TP1 INF2171](https://inf2171.uqam.ca/tp1/)

## Utilisation

* Copiez les fichiers quelque part chez vous [archive zip](https://gitlab.info.uqam.ca/inf2171/20241/tp1-corrige/-/archive/master/tp1-corrige-master.zip)
* Lancez `./corrige.py` avec le chemin de `poule.s` en argument (par défaut il est cherché dans le répertoire local).
* Les tests sont dans le sous répertoire tests, et correspondent aux exemples de l'énoncé.

Note: vous pouvez bricoler le script et ajouter des tests.

## Intégration continue gitlab (optionelle)

Une configuration gitlab-ci minimale est incluse dans le dépôt.
Vous pouvez donc simplement forker ce dépôt et développer votre code assembleur dedans.

**Important**: un fork gitlab est par défaut public.
Vous devez donc rendre privé votre dépot personnel: *Settings*>*General*>*Visibility*>*Project visibility*.
