if [ $# -eq 0 ]; then
  echo "Uso: $0 <nombre_o_id_pokemon_1> [nombre_o_id_pokemon_2 ...]"
  echo "Ejemplo: $0 pikachu 1"
  exit 1
fi

for QUERY in "$@"; do
  QUERY_LOWER=$(echo "$QUERY" | tr '[:upper:]' '[:lower:]')
  
  RESPONSE=$(curl -s -w "\n%{http_code}" "https://pokeapi.co/api/v2/pokemon/${QUERY_LOWER}")
  HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

  if [ "$HTTP_STATUS" -eq 404 ]; then
    echo "Error 404: El Pokémon '$QUERY' no existe."
    echo "----------------------------------------"
    continue
  elif [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Error $HTTP_STATUS al consultar '$QUERY'."
    echo "----------------------------------------"
    continue
  fi

  NAME=$(echo "$HTTP_BODY" | jq -r '.name')
  ABILITIES=$(echo "$HTTP_BODY" | jq -r '[.abilities[].ability.name] | join(", ")')

  echo "Pokémon: $NAME"
  echo "Habilidades: $ABILITIES"
  echo "----------------------------------------"
done
