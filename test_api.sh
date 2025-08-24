#!/bin/bash

# Script para probar la API de licencias
# Uso: ./test_api.sh

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# URL base de la API
API_BASE="http://localhost:3000/api/leaves"

echo -e "${BLUE}=== SCRIPT DE PRUEBA PARA API DE LICENCIAS ===${NC}"
echo "Asegúrate de que el servidor Rails esté corriendo en localhost:3000"
echo ""

# Función para mostrar respuestas de manera legible
show_response() {
    if command -v jq &> /dev/null; then
        echo "$1" | jq '.'
    else
        echo "$1"
    fi
}

# Función para mostrar separadores
separator() {
    echo -e "\n${YELLOW}=== $1 ===${NC}\n"
}

# Función para mostrar éxito/error
show_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

# 1. CREAR LICENCIAS
separator "1. CREANDO LICENCIAS DE PRUEBA"

echo "Creando licencia 1 (Vacaciones)..."
RESPONSE1=$(curl -s -w "\n%{http_code}" -X POST $API_BASE \
  -H "Content-Type: application/json" \
  -d '{
    "leave": {
      "start_date": "2024-02-01",
      "end_date": "2024-02-05",
      "leave_type": "vacations",
      "state": "pending"
    }
  }')

HTTP_CODE1=$(echo "$RESPONSE1" | tail -n1)
BODY1=$(echo "$RESPONSE1" | head -n -1)

if [ "$HTTP_CODE1" -eq 201 ]; then
    echo -e "${GREEN}✓ Licencia 1 creada exitosamente${NC}"
    LICENCIA1_ID=$(echo "$BODY1" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    echo "ID de licencia 1: $LICENCIA1_ID"
else
    echo -e "${RED}✗ Error al crear licencia 1 (HTTP: $HTTP_CODE1)${NC}"
    show_response "$BODY1"
fi

echo ""
echo "Creando licencia 2 (Licencia médica)..."
RESPONSE2=$(curl -s -w "\n%{http_code}" -X POST $API_BASE \
  -H "Content-Type: application/json" \
  -d '{
    "leave": {
      "start_date": "2024-02-10",
      "end_date": "2024-02-12",
      "leave_type": "medical",
      "state": "pending"
    }
  }')

HTTP_CODE2=$(echo "$RESPONSE2" | tail -n1)
BODY2=$(echo "$RESPONSE2" | head -n -1)

if [ "$HTTP_CODE2" -eq 201 ]; then
    echo -e "${GREEN}✓ Licencia 2 creada exitosamente${NC}"
    LICENCIA2_ID=$(echo "$BODY2" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    echo "ID de licencia 2: $LICENCIA2_ID"
else
    echo -e "${RED}✗ Error al crear licencia 2 (HTTP: $HTTP_CODE2)${NC}"
    show_response "$BODY2"
fi

echo ""
echo "Creando licencia 3 (Licencia por maternidad)..."
RESPONSE3=$(curl -s -w "\n%{http_code}" -X POST $API_BASE \
  -H "Content-Type: application/json" \
  -d '{
    "leave": {
      "start_date": "2024-03-01",
      "end_date": "2024-06-01",
      "leave_type": "maternity",
      "state": "approved"
    }
  }')

HTTP_CODE3=$(echo "$RESPONSE3" | tail -n1)
BODY3=$(echo "$RESPONSE3" | head -n -1)

if [ "$HTTP_CODE3" -eq 201 ]; then
    echo -e "${GREEN}✓ Licencia 3 creada exitosamente${NC}"
    LICENCIA3_ID=$(echo "$BODY3" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    echo "ID de licencia 3: $LICENCIA3_ID"
else
    echo -e "${RED}✗ Error al crear licencia 3 (HTTP: $HTTP_CODE3)${NC}"
    show_response "$BODY3"
fi

# 2. LISTAR TODAS LAS LICENCIAS
separator "2. LISTANDO TODAS LAS LICENCIAS"

echo "Obteniendo todas las licencias..."
RESPONSE_INDEX=$(curl -s -w "\n%{http_code}" -X GET $API_BASE)
HTTP_CODE_INDEX=$(echo "$RESPONSE_INDEX" | tail -n1)
BODY_INDEX=$(echo "$RESPONSE_INDEX" | head -n -1)

if [ "$HTTP_CODE_INDEX" -eq 200 ]; then
    echo -e "${GREEN}✓ Lista de licencias obtenida exitosamente${NC}"
    echo "Total de licencias: $(echo "$BODY_INDEX" | grep -o '"id":[0-9]*' | wc -l)"
    show_response "$BODY_INDEX"
else
    echo -e "${RED}✗ Error al obtener lista de licencias (HTTP: $HTTP_CODE_INDEX)${NC}"
    show_response "$BODY_INDEX"
fi

# 3. VER LICENCIAS INDIVIDUALES
separator "3. VIENDO LICENCIAS INDIVIDUALES"

if [ ! -z "$LICENCIA1_ID" ]; then
    echo "Viendo licencia 1 (ID: $LICENCIA1_ID)..."
    RESPONSE_SHOW1=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/$LICENCIA1_ID")
    HTTP_CODE_SHOW1=$(echo "$RESPONSE_SHOW1" | tail -n1)
    BODY_SHOW1=$(echo "$RESPONSE_SHOW1" | head -n -1)
    
    if [ "$HTTP_CODE_SHOW1" -eq 200 ]; then
        echo -e "${GREEN}✓ Licencia 1 obtenida exitosamente${NC}"
        show_response "$BODY_SHOW1"
    else
        echo -e "${RED}✗ Error al obtener licencia 1 (HTTP: $HTTP_CODE_SHOW1)${NC}"
        show_response "$BODY_SHOW1"
    fi
fi

# 4. ACTUALIZAR LICENCIAS
separator "4. ACTUALIZANDO LICENCIAS"

if [ ! -z "$LICENCIA1_ID" ]; then
    echo "Cambiando estado de licencia 1 de 'pending' a 'approved'..."
    RESPONSE_UPDATE1=$(curl -s -w "\n%{http_code}" -X PATCH "$API_BASE/$LICENCIA1_ID" \
      -H "Content-Type: application/json" \
      -d '{
        "leave": {
          "state": "approved"
        }
      }')
    
    HTTP_CODE_UPDATE1=$(echo "$RESPONSE_UPDATE1" | tail -n1)
    BODY_UPDATE1=$(echo "$RESPONSE_UPDATE1" | head -n -1)
    
    if [ "$HTTP_CODE_UPDATE1" -eq 200 ]; then
        echo -e "${GREEN}✓ Licencia 1 actualizada exitosamente${NC}"
        show_response "$BODY_UPDATE1"
    else
        echo -e "${RED}✗ Error al actualizar licencia 1 (HTTP: $HTTP_CODE_UPDATE1)${NC}"
        show_response "$BODY_UPDATE1"
    fi
fi

if [ ! -z "$LICENCIA2_ID" ]; then
    echo ""
    echo "Cambiando estado de licencia 2 de 'pending' a 'rejected'..."
    RESPONSE_UPDATE2=$(curl -s -w "\n%{http_code}" -X PATCH "$API_BASE/$LICENCIA2_ID" \
      -H "Content-Type: application/json" \
      -d '{
        "leave": {
          "state": "rejected"
        }
      }')
    
    HTTP_CODE_UPDATE2=$(echo "$RESPONSE_UPDATE2" | tail -n1)
    BODY_UPDATE2=$(echo "$RESPONSE_UPDATE2" | head -n -1)
    
    if [ "$HTTP_CODE_UPDATE2" -eq 200 ]; then
        echo -e "${GREEN}✓ Licencia 2 actualizada exitosamente${NC}"
        show_response "$BODY_UPDATE2"
    else
        echo -e "${RED}✗ Error al actualizar licencia 2 (HTTP: $HTTP_CODE_UPDATE2)${NC}"
        show_response "$BODY_UPDATE2"
    fi
fi

# 5. PROBAR VALIDACIONES Y ERRORES
separator "5. PROBANDO VALIDACIONES Y ERRORES"

echo "Intentando crear licencia sin fecha de inicio (debería fallar)..."
RESPONSE_ERROR1=$(curl -s -w "\n%{http_code}" -X POST $API_BASE \
  -H "Content-Type: application/json" \
  -d '{
    "leave": {
      "end_date": "2024-02-05",
      "leave_type": "vacations",
      "state": "pending"
    }
  }')

HTTP_CODE_ERROR1=$(echo "$RESPONSE_ERROR1" | tail -n1)
BODY_ERROR1=$(echo "$RESPONSE_ERROR1" | head -n -1)

if [ "$HTTP_CODE_ERROR1" -eq 422 ]; then
    echo -e "${GREEN}✓ Validación funcionando correctamente - fecha de inicio requerida${NC}"
    show_response "$BODY_ERROR1"
else
    echo -e "${RED}✗ Error inesperado en validación (HTTP: $HTTP_CODE_ERROR1)${NC}"
    show_response "$BODY_ERROR1"
fi

echo ""
echo "Intentando crear licencia con fecha fin anterior a fecha inicio (debería fallar)..."
RESPONSE_ERROR2=$(curl -s -w "\n%{http_code}" -X POST $API_BASE \
  -H "Content-Type: application/json" \
  -d '{
    "leave": {
      "start_date": "2024-02-10",
      "end_date": "2024-02-05",
      "leave_type": "vacations",
      "state": "pending"
    }
  }')

HTTP_CODE_ERROR2=$(echo "$RESPONSE_ERROR2" | tail -n1)
BODY_ERROR2=$(echo "$RESPONSE_ERROR2" | head -n -1)

if [ "$HTTP_CODE_ERROR2" -eq 422 ]; then
    echo -e "${GREEN}✓ Validación funcionando correctamente - fecha fin debe ser posterior a fecha inicio${NC}"
    show_response "$BODY_ERROR2"
else
    echo -e "${RED}✗ Error inesperado en validación (HTTP: $HTTP_CODE_ERROR2)${NC}"
    show_response "$BODY_ERROR2"
fi

echo ""
echo "Intentando acceder a licencia inexistente (debería fallar)..."
RESPONSE_ERROR3=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/99999")
HTTP_CODE_ERROR3=$(echo "$RESPONSE_ERROR3" | tail -n1)
BODY_ERROR3=$(echo "$RESPONSE_ERROR3" | head -n -1)

if [ "$HTTP_CODE_ERROR3" -eq 404 ]; then
    echo -e "${GREEN}✓ Error 404 manejado correctamente para licencia inexistente${NC}"
    show_response "$BODY_ERROR3"
else
    echo -e "${RED}✗ Error inesperado (HTTP: $HTTP_CODE_ERROR3)${NC}"
    show_response "$BODY_ERROR3"
fi

# 6. VERIFICAR ESTADOS ACTUALIZADOS
separator "6. VERIFICANDO ESTADOS ACTUALIZADOS"

echo "Listando todas las licencias para ver los cambios..."
RESPONSE_FINAL=$(curl -s -w "\n%{http_code}" -X GET $API_BASE)
HTTP_CODE_FINAL=$(echo "$RESPONSE_FINAL" | tail -n1)
BODY_FINAL=$(echo "$RESPONSE_FINAL" | head -n -1)

if [ "$HTTP_CODE_FINAL" -eq 200 ]; then
    echo -e "${GREEN}✓ Estado final de licencias obtenido${NC}"
    show_response "$BODY_FINAL"
else
    echo -e "${RED}✗ Error al obtener estado final (HTTP: $HTTP_CODE_FINAL)${NC}"
    show_response "$BODY_FINAL"
fi

# 7. ELIMINAR LICENCIAS
separator "7. ELIMINANDO LICENCIAS"

if [ ! -z "$LICENCIA1_ID" ]; then
    echo "Eliminando licencia 1 (ID: $LICENCIA1_ID)..."
    RESPONSE_DELETE1=$(curl -s -w "\n%{http_code}" -X DELETE "$API_BASE/$LICENCIA1_ID")
    HTTP_CODE_DELETE1=$(echo "$RESPONSE_DELETE1" | tail -n1)
    
    if [ "$HTTP_CODE_DELETE1" -eq 204 ]; then
        echo -e "${GREEN}✓ Licencia 1 eliminada exitosamente${NC}"
    else
        echo -e "${RED}✗ Error al eliminar licencia 1 (HTTP: $HTTP_CODE_DELETE1)${NC}"
    fi
fi

if [ ! -z "$LICENCIA2_ID" ]; then
    echo "Eliminando licencia 2 (ID: $LICENCIA2_ID)..."
    RESPONSE_DELETE2=$(curl -s -w "\n%{http_code}" -X DELETE "$API_BASE/$LICENCIA2_ID")
    HTTP_CODE_DELETE2=$(echo "$RESPONSE_DELETE2" | tail -n1)
    
    if [ "$HTTP_CODE_DELETE2" -eq 204 ]; then
        echo -e "${GREEN}✓ Licencia 2 eliminada exitosamente${NC}"
    else
        echo -e "${RED}✗ Error al eliminar licencia 2 (HTTP: $HTTP_CODE_DELETE2)${NC}"
    fi
fi

if [ ! -z "$LICENCIA3_ID" ]; then
    echo "Eliminando licencia 3 (ID: $LICENCIA3_ID)..."
    RESPONSE_DELETE3=$(curl -s -w "\n%{http_code}" -X DELETE "$API_BASE/$LICENCIA3_ID")
    HTTP_CODE_DELETE3=$(echo "$RESPONSE_DELETE3" | tail -n1)
    
    if [ "$HTTP_CODE_DELETE3" -eq 204 ]; then
        echo -e "${GREEN}✓ Licencia 3 eliminada exitosamente${NC}"
    else
        echo -e "${RED}✗ Error al eliminar licencia 3 (HTTP: $HTTP_CODE_DELETE3)${NC}"
    fi
fi

# 8. VERIFICAR ELIMINACIÓN
separator "8. VERIFICANDO ELIMINACIÓN"

echo "Verificando que todas las licencias fueron eliminadas..."
RESPONSE_CLEAN=$(curl -s -w "\n%{http_code}" -X GET $API_BASE)
HTTP_CODE_CLEAN=$(echo "$RESPONSE_CLEAN" | tail -n1)
BODY_CLEAN=$(echo "$RESPONSE_CLEAN" | head -n -1)

if [ "$HTTP_CODE_CLEAN" -eq 200 ]; then
    LICENCIAS_RESTANTES=$(echo "$BODY_CLEAN" | grep -o '"id":[0-9]*' | wc -l)
    if [ "$LICENCIAS_RESTANTES" -eq 0 ]; then
        echo -e "${GREEN}✓ Todas las licencias fueron eliminadas correctamente${NC}"
    else
        echo -e "${YELLOW}⚠ Quedan $LICENCIAS_RESTANTES licencias en la base de datos${NC}"
    fi
    show_response "$BODY_CLEAN"
else
    echo -e "${RED}✗ Error al verificar estado final (HTTP: $HTTP_CODE_CLEAN)${NC}"
    show_response "$BODY_CLEAN"
fi

# RESUMEN FINAL
separator "RESUMEN DE PRUEBAS"

echo -e "${BLUE}Script de pruebas completado.${NC}"
echo ""
echo "Para ejecutar este script:"
echo "1. Asegúrate de que el servidor Rails esté corriendo: rails server"
echo "2. Dale permisos de ejecución: chmod +x test_api.sh"
echo "3. Ejecuta: ./test_api.sh"
echo ""
echo "Si tienes jq instalado, las respuestas se mostrarán formateadas."
echo "Para instalar jq: sudo apt install jq (Ubuntu/Debian)"
