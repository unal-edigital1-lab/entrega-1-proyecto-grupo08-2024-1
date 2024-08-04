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
| Botón para Curar  | Pulsador con tapa (MCI00315)  | Cada vez que se oprima, aumenta el estado de Salud, cura al Tamogotchi. |
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
| Diversión | Cada vez que pasen 30 segundos, se baja el porcentaje de este estado si no se hace uso del sensor ultrasonido (caricia). |
| Salud | Cada vez que pasen 100 segundos, se baja el porcentaje de este estado. Solo se aumenta cuando se hace uso del botón de curar. |
| Alimentación | Cada vez que pasen 20 segundos, se baja el porcentaje de este estado. Para aumentarlo se debe presionar el botón de alimentación. |
| Energía | Cada vez que pasen 50 segundos, se baja el porcentaje de este estado. Cuando el giroscopio este invertido, es decir cuando el tamagotchi este boca abajo, aumenta este estado.|


*Sistema de Caja Negra General*

![Sistema de Caja Negra General](/Diagrama%20de%20cajas/Diagrama%20de%20flujo-Página-6.jpg)

Al plantear el diseño incial del Tamagotchi, se tomaron como elementos iniciales el set de botones, al menos un sensor y el sistema de visualización. Para esto se definieron 4 botones con sus respectivas funciones: botón de reset, botón de test, botón para curar a la mascota y otro para alimentarla. Todos estos serán entradas para el sistema, tal como se muestra en el diagrama general de caja negra. Otras entradas del sistema son los sensores, los que se eligieron son el sensor de Ultrasonido  HC-SR04 y el giroscopio MPU6050. Tanto los botones como los sensores son entradas de un solo bit. En caso de los botones, si están activados o no, para el sensor de ultrasonido se pide que detecte si existe una proximidad a este entre 1-5cm por lo cual la señal que enviará es de si se presenta o no esta proximidad y para
el giroscopio se pide únicamente que detecte si este está orientado "cabeza arriba o abajo" por lo tanto también es una entrada de un bit. Y a las entradas se sumaría la señal clock.

Las visualizaciones tanto de los 7 segmentos como de la pantalla LCD 16x2 corresponden a las salidas. Las salidas que se observan: **datap_hp, datap_ali, datap_fun** y **datap_ener** son los porcentajes de cada estado que se mostrarán en los 7 segmentos, salud, alimentación, diversión y energía respectivamente. La salida **data_cara** corresponde a la imagen que se va a mostrar en la pantalla LCD.


*Tabla de SM visual*

Para la visualización se utiliza la siguiente convención:
<p align="center">
![Tabla de SM visual](/Images/SM_table.png)
</p>
Consiste en 5 bits de los cuales los primeras 3 cifras se toman en cuenta para determinar el estado que se muestra, ya sea la energia(000), la diversión(001), la alimentación(010) y la salud(011) además de un estado neutro(100) para no mostrar nada en la visualización. La dos cifras restantes determinan si el estado con el q se combina es alto obajo demostrando una cara triste(00) o felíz(01) además de su respectiva cara neutra(10) con la misma finalidad del estado neutro.
*Sistema de Caja Negra Específico*

![Sistema de Caja Negra Específico](/Diagrama%20de%20cajas/Diagrama%20de%20caja%20negra.png)


*Diagrama de Flujo*

*FSM General*

*Data Path*
