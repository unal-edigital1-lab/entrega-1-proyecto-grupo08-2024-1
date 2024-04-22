# Entrega 1 del proyecto WP01

* Juan José Delgado Estrada		
* Juan Jose Díaz Guerrero		
* Isabella Mendoza Cáceres
* Juan Angel Vargas Rodríguez

## Especificación de Diseño del Proyecto Tamagotchi en FPGA

Drive de Trabajo = https://docs.google.com/document/d/1uVYzq7XdJc5DKCoQSqGOa9-jXex2LjcXxlpm7lsy9yc/edit?usp=sharing 

**Primera Entrega (10% del total de la nota del proyecto)**

Objetivo: Definición periférica del proyecto y diseño inicial.

### Especificación detallada del sistema (Completo).
*Detalle de la especificación de los componentes del proyecto y su descripción funcional.*

| Componente  | Especificación | Funcionamiento|
| ------------- | ------------- | ------------- |
| Botón para Curar  | Pulsador con tapa (MCI00315)  | Cada vez que se oprima, elimina las diferentes condiciones adversas (solo funciona cuando la mascota tiene una enfermedad). |
| Botón para Alimentar | Pulsador con tapa (MCI00315)  | Cada vez que se oprima, da de comer a la mascota, aumentando los niveles de alimentación y energía. |
| Botón para Saltar la Cuerda | Pulsador con tapa (MCI00315)  | Cada vez que se oprima, cambia de escenario y se inicia un mini juego (aumenta el nivel de diversión pero baja el de energía). |
| Botón para Reset | Pulsador con tapa (MCI00315)  | Cuando esté presionado por 5 segundos, restablece el estado inicial del tamagotchi (todos los niveles al 100%).|
| Botón para Navegar Estados| Pulsador con tapa (MCI00315)  | Cada vez que se oprima, permite ver los porcentajes de las barras de los niveles.|
| Botón para Test| Pulsador con tapa (MCI00315)  | Cuando esté presionado por 5 segundos, permite modificar los porcentajes de los niveles (se utiliza el botón de Navegar Estados para cambiar el estado y el mismo botón de Test para modificar el porcentaje).|
| Sensor de Ultrasonido | Sensor HC-SR04 | Cuando detecte una proximidad de 1-5 cm la mascota aumentará su estado de diversión.|
| Sensor de Movimiento | Sensor MPU 6050 | Detecta la velocidad con la que se mueve y dependiendo de esta, determina si la mascota está paseando. El giroscopio detecta si la mascota está boca abajo y la pone en modo de descanso, si detecta que se vuelve a ubicar boca arriba, se desactiva el modo descanso.|
| Display 8x8 MAX7219 | Módulo MAX7219 | Se muestran el entorno de la mascota y también los porcentajes de los niveles de la mascota.|
| Leds 7 segmentos | Ánodo común | Se muestra el porcentaje del nivel que esté seleccionado.|
| FPGA | A-C4E6 Cyclone IV FPGA EP4CE6E22C8N | Controlador de las distintas operaciones que se desean hacer (contiene componentes lógicos programables).|


*Sistema de Caja Negra*

