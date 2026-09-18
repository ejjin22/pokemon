 # Convertir a minúsculas usando Bash nativo (sin tr)
  QUERY_LOWER="${QUERY,,}"

  # Realizar petición
  RESPONSE=$(curl -s -w "\n%{http_code}" "https://pokeapi.co/api/v2/pokemon/${QUERY_LOWER}")
  HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
  HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)

  # Validar si HTTP_STATUS es un número antes de comparar
  if ! [[ "$HTTP_STATUS" =~ ^[0-9]+$ ]]; then
    echo "Error de conexión al consultar '$QUERY'."
    echo "----------------------------------------"
    continue
  fi

  # Manejo de códigos HTTP
  if [ "$HTTP_STATUS" -eq 404 ]; then
    echo "Error 404: El Pokémon '$QUERY' no existe."
    echo "----------------------------------------"
    continue
  elif [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Error $HTTP_STATUS al consultar '$QUERY'."
    echo "----------------------------------------"
    continue
  fi

  # Extraer Nombre y Habilidades en una sola llamada a jq
  read -r NAME ABILITIES <<< "$(echo "$HTTP_BODY" | jq -r '[.name, ([.abilities[].ability.name] | join(", "))] | @tsv')"

  echo "Pokémon: $NAME"
  echo "Habilidades: $ABILITIES"
  echo "----------------------------------------"
done
