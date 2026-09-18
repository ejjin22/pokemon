#!/bin/bash

# Comprobar argumento
NOMBRE=${1:?"Uso: $0 <nombre_pokemon_o_tipo>"}

# 1. Consultar si es un Pokémon directamente
RESPONSE=$(curl -s -w "\n%{http_code}" "https://pokeapi.co/api/v2/pokemon/${NOMBRE,,}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    # Extraer URLs de los tipos del Pokémon
    TYPE_URLS=$(echo "$BODY" | jq -r '.types[].type.url')
    
    echo "Pokémon: $NOMBRE"
    echo -n "Debilidades (daño x2 o más): "
    
    # Obtener el daño recibido x2 de cada tipo del Pokémon
    TYPES_DEBILIDADES=""
    for URL in $TYPE_URLS; do
        DEBS=$(curl -s "$URL" | jq -r '.damage_relations.double_damage_from[].name')
        TYPES_DEBILIDADES="$TYPES_DEBILIDADES $DEBS"
    done
    
    # Imprimir debilidades únicas separadas por coma
    echo "$TYPES_DEBILIDADES" | tr ' ' '\n' | grep -v '^$' | sort -u | paste -sd, - | sed 's/,/, /g'

elif [ "$HTTP_CODE" -eq 404 ]; then
    # 2. Si no es un Pokémon, intentar consultar como tipo de Pokémon directamente
    TYPE_RESP=$(curl -s -w "\n%{http_code}" "https://pokeapi.co/api/v2/type/${NOMBRE,,}")
    T_CODE=$(echo "$TYPE_RESP" | tail -n1)
    T_BODY=$(echo "$TYPE_RESP" | sed '$d')

    if [ "$T_CODE" -eq 200 ]; then
        echo "Tipo: $NOMBRE"
        echo -n "Recibe doble daño de: "
        echo "$T_BODY" | jq -r '[.damage_relations.double_damage_from[].name] | join(", ")'
    else
        echo "No encontrado"
        exit 1
    fi
else
    echo "Error en la consulta"
    exit 1
fi
