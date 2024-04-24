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
| Botón para Alimentar | Pulsador con tapa (MCI00315)  | Cada vez que se oprima, da de comer a la mascota, aumentando los niveles de alimentación y energía. |
| Botón para Reset | Pulsador con tapa (MCI00315)  | Cuando esté presionado por 5 segundos, restablece el estado inicial del tamagotchi (todos los niveles al 100%).|
| Botón para Navegar Estados| Pulsador con tapa (MCI00315)  | Cada vez que se oprima, permite ver los porcentajes de las barras de los niveles en el 7 segmentos y el ícono en la pantalla.|
| Botón para Test| Pulsador con tapa (MCI00315)  | Cuando esté presionado por 5 segundos, permite modificar los porcentajes de los niveles (se utiliza el botón de Navegar Estados para cambiar el estado y el mismo botón de Test para modificar el porcentaje).|
| Sensor de Ultrasonido | Sensor HC-SR04 | Cuando detecte una proximidad de 1-5 cm la mascota aumentará su estado de diversión.|
| Sensor de Movimiento | Sensor MPU 6050 | Detecta la velocidad con la que se mueve y dependiendo de esta, determina si la mascota está paseando. El giroscopio detecta si la mascota está boca abajo y la pone en modo de descanso, si detecta que se vuelve a ubicar boca arriba, se desactiva el modo descanso.|
| Display 8x8 MAX7219 | Módulo MAX7219 | Se representa la mascota de manera visual, siendo controlada por un módulo en específico. Serían catorce íconos incluyendo los representados de los estados.|
| Leds 7 segmentos | Ánodo común | Se muestra el porcentaje del nivel que esté seleccionado.|
| FPGA | A-C4E6 Cyclone IV FPGA EP4CE6E22C8N | Controlador de las distintas operaciones que se desean hacer (contiene componentes lógicos programables).|


*Estados*
| Estado | Descripción | 
| ------------- | ------------- |
| Diversión | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado si la mascota está despierta pero no hace nada. Además, aumenta el estado si se lleva a pasear o se acaricia la mascota. |
| Salud | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado. Cuando todos los estados estén en un nivel alto, este porcentaje sube. Se pueden presentar situaciones aleatorias que hacen que el porcentaje de este estado disminuya (se hace uso del botón de curar). |
| Alimentación | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado. Para aumentarlo se debe presionar el botón de alimentación. |
| Energía | Cada vez que pase determinado tiempo, se baja el porcentaje de este estado. Cuando la mascota se lleva a pasear, baja el estado; mientras que cuando se alimenta, aumenta.|


*Sistema de Caja Negra General*

![Sistema de Caja Negra General](/Images/Diagrama%20de%20Caja%20Negra%20General.png)

*Sistema de Caja Negra Específico*

![Sistema de Caja Negra Específico](/Diagrama%20de%20cajas/Diagrama%20de%20caja%20negra.png)


*Visualización Matriz 8x8*
| Caras | Relación | 
| ------------- | ------------- |
| Divertido, triste | Felicidad |
| Saciado, hambriento | Alimentación |
|Activo, somnoliento | Energía |
| Corazón, pastilla cápsula | Salud |
| Árbol | Movimiento |
| Caricia | Ultrasonido |
| Despertar, Dormido | Movimiento |
| Manzana | Botón de alimentación |
|Jeringa | Botón de curar | 
| Cartel Test | Botón test |  
