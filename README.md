# Entrega 1 del proyecto WP01

* Juan José Delgado Estrada		
* Juan Jose Díaz Guerrero		
* Isabella Mendoza Cáceres
* Juan Angel Vargas Rodríguez

## Especificación de Diseño del Proyecto Tamagotchi en FPGA

Se desarrolla un sistema de Tamagotchi en FPGA (Field-Programmable Gate Array) que simule el cuidado de una mascota virtual. El diseño incorporará una lógica de estados para reflejar las diversas necesidades y condiciones de la mascota, junto con mecanismos de interacción a través de sensores y botones que permitan al usuario cuidar adecuadamente de la mascota.

Drive de Trabajo = https://docs.google.com/document/d/1uVYzq7XdJc5DKCoQSqGOa9-jXex2LjcXxlpm7lsy9yc/edit?usp=sharing 


**Primera Entrega (10% del total de la nota del proyecto)**

Objetivo: Definición periférica del proyecto y diseño inicial.


### Especificación detallada del sistema 
*Detalle de la especificación de los componentes del proyecto y su descripción funcional.*

| Componente  | Especificación | Funcionamiento|
| ------------- | ------------- | ------------- |
| Botón para Curar  | Pulsador con tapa (MCI00315)  | Cada vez que se oprima, elimina las diferentes condiciones adversas (solo funciona cuando la mascota tiene una enfermedad). |
| Botón para Alimentar | Pulsador con tapa (MCI00315)  | Cada vez que se oprima, da de comer a la mascota, aumentando el nivel de alimentación. |
| Botón para Reset | Pulsador con tapa (MCI00315)  | Cuando esté presionado por 5 segundos, restablece el estado inicial del tamagotchi (todos los niveles al 100%).|
| Botón para Test| Pulsador con tapa (MCI00315)  | Cuando esté presionado por 5 segundos, permite hacer un sondeo rápido entren estados, dejando interactuar de manera directa para modificar el nivel en el que se encuentra el estado.|
| Sensor de Ultrasonido | Sensor HC-SR04 | Cuando detecte una proximidad de 1-5 cm, la mascota aumentará su estado de diversión.|
| Sensor de Movimiento | Sensor MPU 6050 | El giroscopio detecta si la mascota está boca abajo (nivel de energía aumenta porque está descansando) o boca arriba (está activo y va disminuyendo el nivel de energía).|
| Pantalla | LCD 16x2 | Se observan las 2 caras de la mascota (si se encuentra mal o bien). Además, muestra la necesidad a la que se está haciendo referencia mediante la visualización de un ícono.|
| Leds 7 segmentos | Ánodo común | Se muestra el porcentaje de todos los niveles.|
| FPGA | A-C4E6 Cyclone IV FPGA EP4CE6E22C8N | Controlador de las distintas operaciones que se desean hacer (contiene componentes lógicos programables).|


*Estados*
| Estado | Descripción | 
| ------------- | ------------- |
| Diversión | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado si no se hace uso del sensor ultrasonido (caricia). |
| Salud | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado. Solo se aumenta cuando se hace uso del botón de curar. |
| Alimentación | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado. Para aumentarlo se debe presionar el botón de alimentación. |
| Energía | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado. Cuando se utilize el giroscopio aumenta este estado.|


*Sistema de Caja Negra General*

![Sistema de Caja Negra General](/Images/Diagrama%20de%20Caja%20Negra%20General.png)

*Sistema de Caja Negra Específico*

![Sistema de Caja Negra Específico](/Diagrama%20de%20cajas/Diagrama%20de%20caja%20negra.png)

*Diagrama de Flujo*

*FSM General*

*Data Path*