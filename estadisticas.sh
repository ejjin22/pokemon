#!/bin/bash

# Recibe el nombre del pokemon como argumento
pokemon="$1"

# Validación: no hay argumento
if [ -z "$pokemon" ]; then
    echo "Error: escribe el nombre de un pokemon" >&2
    exit 1
fi

# Consulta a la PokeAPI
respuesta=$(curl -s "https://pokeapi.co/api/v2/pokemon/$pokemon")

# Validación: si el pokemon no existe, la API devuelve "Not Found"
if echo "$respuesta" | grep -q "Not Found"; then
    echo "Error: el pokemon '$pokemon' no existe" >&2
    exit 1
fi

# Extraer estadísticas con jq
echo "=== $pokemon ==="
echo "PS:          $(echo "$respuesta" | jq -r '.stats[0].base_stat')"
echo "Ataque:      $(echo "$respuesta" | jq -r '.stats[1].base_stat')"
echo "Defensa:     $(echo "$respuesta" | jq -r '.stats[2].base_stat')"
echo "Ataque esp:  $(echo "$respuesta" | jq -r '.stats[3].base_stat')"
echo "Defensa esp: $(echo "$respuesta" | jq -r '.stats[4].base_stat')"
echo "Velocidad:   $(echo "$respuesta" | jq -r '.stats[5].base_stat')"
