#!/bin/bash

# Comprobar argumento
if [ $# -eq 0 ]; then
  echo "Uso: $0 <nombre_o_id_pokemon>"
  echo "Ejemplo: $0 charizard"
  exit 1
fi

NOMBRE=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# 1. Consultar el Pokémon a la PokéAPI
RESPONSE=$(curl -s -w "\n%{http_code}" "https://pokeapi.co/api/v2/pokemon/${NOMBRE}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "Error: No se encontró el Pokémon '$1' (Código HTTP: $HTTP_CODE)."
  exit 1
fi

POKE_NAME=$(echo "$BODY" | jq -r '.name')
TYPE_URLS=$(echo "$BODY" | jq -r '.types[].type.url')
POKE_TYPES=$(echo "$BODY" | jq -r '[.types[].type.name] | join(", ")')

echo "========================================"
echo "Pokémon: $POKE_NAME (Tipos: $POKE_TYPES)"
echo "========================================"

# 2. Consultar debilidades (daño recibido x2) de cada tipo
DEBILIDADES_RAW=""
for URL in $TYPE_URLS; do
    DEBS=$(curl -s "$URL" | jq -r '.damage_relations.double_damage_from[].name')
    DEBILIDADES_RAW="$DEBILIDADES_RAW $DEBS"
done

# 3. Eliminar tipos duplicados y formatear con comas DEBILIDADES_UNICAS=$(echo "$DEBILIDADES_RAW" | tr ' ' '\n' | grep -v '^$' | sort -u | paste -sd, - | sed 's/,/, /g')

if [ -z "$DEBILIDADES_UNICAS" ]; then
  echo "Debilidades: Ninguna encontrada"
else
  echo "Debilidades (daño x2 o más): $DEBILIDADES_UNICAS"
fi
echo "========================================"

