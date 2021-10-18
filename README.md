# Desarrollo de Software en Sistemas Distribuidos 2021 - Entrega 3 

## Grupo 7: 

- Ocampos Juan Cruz, 13626/2
- Cabrera Ulises Martin, 6054/4
- Gutierrez Fernando, 12088/3

## Endpoints

**POST /login** - Genera el token, espera 2 parámetros: username y password.

Pueden ser:

username: walterbates password: bpm

username: test password: test

- Ejemplo de uso:

![Uso de /login](./capturas/captura1.png?raw=true)


**POST /api/stamp** - Genera el hash para un expediente. Necesita el token en un header Authorization y 2 paramétros, el numero de expediente y el estatuto.

- Ejemplo de uso:

![Uso de /api/stamp parametros](./capturas/captura2.png?raw=true)
![Uso de /api/stamp header](./capturas/captura3.png?raw=true)
