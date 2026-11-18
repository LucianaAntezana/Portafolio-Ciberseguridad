# Redeemer — Hack The Box Starting Point

**Estado:** completada  
**Tipo de práctica:** reconocimiento de red y enumeración de servicio  
**Informe académico:** [Informe_Redeemer_UPB.pdf](Informe_Redeemer_UPB.pdf)

## Objetivo

Identificar el servicio expuesto en la máquina asignada y comprobar, dentro del laboratorio autorizado, si era posible consultar los datos almacenados.

## Entorno registrado

- Plataforma: Hack The Box, Starting Point
- Máquina: Redeemer
- Entorno: Pwnbox (terminal Parrot)
- Herramientas: `ping`, Nmap 7.95 y `redis-cli` 8.0.2
- Objetivo observado: `10.129.107.153` (IP de esa sesión; puede cambiar)
- Servicio identificado: Redis 5.0.7 en TCP/6379

## Procedimiento y explicación

1. **Comprobar conectividad:** `ping -c 4 <IP>` envía cuatro solicitudes ICMP. En la ejecución registrada hubo cuatro respuestas y ninguna pérdida. Esto confirma conectividad en ese momento, no disponibilidad permanente.
2. **Enumerar puertos TCP:** `nmap -p- -sV <IP>` recorre los puertos TCP y prueba identificar servicios/versiones. Se observó TCP/6379 abierto, asociado a Redis 5.0.7. El escaneo no cubrió UDP.
3. **Conectar al servicio:** `redis-cli -h <IP> -p 6379` abre el cliente contra el host y puerto detectados. `PING` recibió `PONG` sin que se proporcionaran credenciales.
4. **Inspeccionar la instancia:** `INFO` mostró cuatro claves en la base lógica 0. `SELECT 0` seleccionó esa base y `KEYS *` enumeró las claves `numb`, `flag`, `temp` y `stor`.
5. **Leer el dato del reto:** `GET flag` devolvió el valor de la clave. El informe académico conserva la evidencia de la sesión.

No se realizó fuerza bruta, escritura de datos ni escalamiento. El hallazgo demostrado es la lectura no autenticada de datos a través de un servicio Redis accesible por red.

## Hallazgo y mitigación

Una instancia accesible sin autenticación permitió enumerar claves y leer su contenido. En un entorno real se recomienda restringir Redis a interfaces y redes internas, aplicar reglas de firewall y autenticación/autorización, evitar exposición directa del puerto 6379 y mantener el servicio actualizado. Para enumeración de claves en producción, `KEYS *` puede afectar el servicio; se prefiere `SCAN`.

## Trazabilidad

El informe PDF contiene seis evidencias de terminal, desde conectividad hasta lectura de la clave, y una bitácora que relaciona cada evidencia con el resultado observado. No se agregan capturas recreadas.

## Reproducibilidad

Sustituye `<IP>` por la dirección asignada a tu propia sesión de laboratorio. Ejecuta únicamente en el objetivo autorizado. Las salidas, IP y versiones de la sesión original se describen en el PDF y podrían variar.
