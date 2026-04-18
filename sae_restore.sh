#!/bin/bash

#sae_restore.sh-------------------------------------------------------

#Vérifier si le script est exécuté dans le dossier spécifié
working_directory="sae_broyeur"
if ! pwd | grep "" > /dev/null 2>&1; then
    echo "Vous n'êtes pas dans le dossier  !"
    exit 1
fi

#Définition des variables de répertoire et de fichiers
trashbox_directory=".sh-trashbox"   #Répertoire où sont stockés les fichiers/dossiers supprimés
id_file="ID"                        #Fichier contenant le prochain ID à utiliser
index_file="INDEX"                  #Fichier contenant les informations des fichiers/dossiers supprimés

echo "-----------------------------------------------"

#Vérifier les argument et le option [-d:-r:  ]
if [ $# -gt 0 ]; then
    option="$1"
    if [ "$option" = "-r" ];then
        if [ $# -lt 2 ];then
            echo "Usage: $0 [-r : pour_recréer_l'arborescence ]  nom_element"
            echo "-----------------------------------------------"
            exit 1
        else
            shift 1
        fi
    elif [ "$option" = "-d" ];then
        if [ $# -lt 3 ];then
            echo "Usage: $0 [-d : pour le restorer l'element dans un dossier ] nom_dossier nom_element"
            echo "-----------------------------------------------"
            exit 1
        else
            dossier_s="$2"
            shift 2
        fi
    fi
else
    echo "Usage: $0 [-r : pour recréer l'arborescence, -d : pour le restorer l'element dans un dossier ] nom_dossier nom_element"
    echo "-----------------------------------------------"
    exit 1
fi

#verifier si le dossier .sh-trashbox et les ficheir INDEX ID -----
if [ ! -d "$trashbox_directory" ] || [ ! -f "$trashbox_directory/$index_file" ] || [ ! -f "$trashbox_directory/$id_file" ]; then
    echo "Le répertoire ou les fichiers nécessaires dans $trashbox_directory sont absents !"
    exit 1
fi
move_recursive() {
    local src=$1
    local dest=$2

    #Si la destination n'existe pas, créez-la
    if [ ! -d "$dest" ]; then
        mkdir -p "$dest"
    fi

    #Parcourir les éléments dans le dossier source
    for item in "$src"/*; do
        if [ -e "$item" ]; then
            local base_item=$(basename "$item")
            local dest_item="$dest/$base_item"

            #Si c'est un dossier
            if [ -d "$item" ]; then
                if [ -e "$dest_item" ]; then
                    if [ -d "$dest_item" ]; then
                        #Fusionner récursivement les sous-dossiers
                        move_recursive "$item" "$dest_item"
                    else
                        #Conflit avec un fichier existant
                        echo "Conflit : $dest_item est un fichier, impossible de fusionner avec le dossier $item"
                    fi
                else
                    #Déplacer le dossier si la cible n'existe pas
                    mv "$item" "$dest/"
                fi
            elif [ -f "$item" ]; then
                #Si c'est un fichier
                if [ -e "$dest_item" ]; then
                    echo "Remplacement du fichier $dest_item par $item"
                    mv -f "$item" "$dest/"
                else
                    mv "$item" "$dest/"
                fi
            fi
        fi
    done

    #Supprimer le dossier source vide après fusion
    rmdir "$src" 2>/dev/null
}

#On compte le nombre de lignes (éléments) dans le fichier INDEX
nb_items=$(cat "$trashbox_directory/$index_file" | wc -w)

#Parcourt chaque argument passé au script
for j in "$@"; do
    #Indicateur pour vérifier l'existence de l'élément dans la poubelle
    exists=0

    #recuperer le dossier parant du param
    param_p1=$(echo "$j" | sed -E 's#^(\./)?([^/]+)/.*#\2#')

    #Extraire le nom de l'élément sans le chemin du répertoire parent
    element_param=$(echo "$j" | sed "s|$(dirname "$j")/||")

    #Recherche des lignes contenant l'élément à restaurer dans le fichier INDEX
    lignes=$(grep "$param_p1" "$trashbox_directory/$index_file")

    if [ -z "$lignes" ]; then
        echo "$element_param ---- n'est pas dans la poubelle !!"
        exit 1
    fi

    #nombre d'elements dans la corbielle
    nb_items_f=$(echo "$lignes" | wc -w)
    #Extrait une ligne spécifique de INDEX pour analyse
    ligne=$(echo "$lignes" | tail -n 1)
    #Extrait une ligne spécifique de INDEX pour analyse
    full_path=$(echo $(echo $ligne | sed -E 's/^[0-9]*:\/|:[^:]*\([^)]*\)$//g') | sed "s|:||")
    #Extraction du chemin précédent
    dirname=$(dirname "$full_path")
    #Extraction du nom de l'élément uniquement (sans le chemin)
    filename=$(echo "$full_path" | sed "s|$dirname/||")
    #Extraction de l'ID de l'élément supprimé
    order=$(echo $ligne | cut -d ":" -f 1)

    real_full_path=$(echo "$j" | sed "s|^[^/]*|$trashbox_directory/$order|")

    if [ -e "$real_full_path" ]; then
        exists=1

        #Vérifier si l'élément à récupérer est un fichier ou un dossier
        if [ -d "$real_full_path" ]; then
            type='d'
        elif [ -f "$real_full_path" ]; then
            type='f'
        fi
        
        #Gestion de la recréation de l'arborescence et le placement du fichier recuperé
        if [ "$option" = "-r" ]; then
            #Appeler la fonction restorer recursivement 
            if [ "$param_p1" = "$element_param" ]; then
                if [ ! -e "$dirname" ]; then
                    mkdir -p "$dirname"
                fi

                if [ -e "$dirname/$param_p1" ]; then
                    if [ -d "$dirname/$param_p1" ] && [ -d "$real_full_path" ]; then
                        move_recursive "$real_full_path" "$dirname/$param_p1"
                    fi
                else
                    mv "$real_full_path" "$dirname/$param_p1"
                fi
            else
                if [ ! -d "$(dirname "$j")" ]; then
                    mkdir -p "$(dirname "$j")"
                fi

                if [ -e "$(dirname "$j")/$element_param" ]; then
                    if [ -d "$(dirname "$j")/$element_param" ] && [ -d "$real_full_path" ]; then
                        move_recursive "$real_full_path" "$(dirname "$j")/$element_param"
                    fi
                else
                    mv "$real_full_path" "$(dirname "$j")/$element_param"
                fi
            fi
        elif [ "$option" = "-d" ]; then
            if [ ! -d $dossier_s ];then
                echo "Le dossier \"$dossier_s\" n'esiste pas !!!"
                echo "Usage: $0 [-r : pour recréer l'arborescence, -d : pour le restorer l'element dans un dossier] nom_dossier nom_element"
                echo "-----------------------------------------------"
                exit 1
            fi
            mv "$real_full_path" "$dossier_s/$element_param"
        else
            mv "$real_full_path" "./$element_param"
        fi
        if [[ $param_p1 == $element_param ]]; then
            #Supprimer l'entrée du fichier INDEX
            sed -i "\|$ligne|d" "$trashbox_directory/$index_file"

            nb_items=$(wc -w < "$trashbox_directory/$index_file" )

            cpt=$((nb_items + 1))
            #echo $cpt
            echo $cpt > "$trashbox_directory/$id_file"
            
            
            #Réorganise les ordres dans le fichier INDEX
            for i in $(seq 1 $nb_items); do
                ligne_l=$(tail -n $(($nb_items - $i + 1)) "$trashbox_directory/$index_file" | head -n 1)

                order_l=$(echo "$ligne_l" | cut -d ":" -f 1)

                sed -i "s|$order_l|$i|" "$trashbox_directory/$index_file"

                #Réorganise les fichiers/dossiers dans la poubelle
                mv "$trashbox_directory/$order_l" "$trashbox_directory/$i.tmp"
            done

            #Renomme les fichiers temporaires pour restaurer l'ordre
            if [ $(echo $trashbox_directory | wc -w ) -ne 0 ];then
                for i in $(seq 1 $nb_items); do
                    mv "$trashbox_directory/$i.tmp" "$trashbox_directory/$i"
                done
            fi
        fi

        #Vérifie si le déplacement a réussi
        if [ $? -eq 0 ]; then
                    #Débogage (optionnel, à activer si nécessaire)
                    #echo "-----------------------------------------------"
                    #echo "La ligne $i: $ligne"
                    #echo "L'adressage précédent est : $dirname"
                    #echo "Chemin complet : $full_path"
                    #echo "Le numéro d'ordre est : $order"
                    #echo "Le nom du fichier : $filename"
                    #echo "L'élément en paramètre : $element_param"
                    #echo "-----------------------------------------------"
            #Vérifie le type de l'élément et affiche un message
            if [ $type == 'd' ]; then
                echo "Le dossier \"$element_param\" a été récupéré avec succès !"
            elif [ $type == 'f' ]; then
                echo "Le fichier \"$element_param\" a été récupéré avec succès !"
            fi
        fi
    else
        exists=0
    fi

    #Affiche un message si l'élément n'est pas trouvé dans la poubelle
    if [ $exists -eq 0 ]; then
        echo ""$element_param" ---- n'est pas dans la poubelle !!"
    fi
    echo "-----------------------------------------------"
done