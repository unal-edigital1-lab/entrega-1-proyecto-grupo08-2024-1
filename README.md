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

![Tabla de SM visual](/Images/SM_table.png)

Consiste en 5 bits de los cuales los primeras 3 cifras se toman en cuenta para determinar el estado que se muestra, ya sea la energia (000), la diversión (001), la alimentación (010) y la salud (011) además de un estado neutro (100) para no mostrar nada en la visualización. La dos cifras restantes determinan si el estado con el q se combina es alto o bajo demostrando una cara feliz (00) o triste (01) además de su respectiva cara neutra(10) con la misma finalidad del estado neutro.


*Sistema de Caja Negra Específico*

![Sistema de Caja Negra Específico](/Diagrama%20de%20cajas/Diagrama%20de%20caja%20negra.png)


*Diagrama de Flujo*

![Diagrama de flujo](/Images/Diagrama%20de%20flujo.jpg)

En el diagrama de flujo se encuentran diamantes para ejemplificar un condiacional que se debe tener en cuenta para la sucesion de los siguientes pasos y se utilizan rectangulos para mostrar las acciones que se deben realizar durante ese paso. Ademas al inicio del diagrama se encuentran los valores iniciales de los registros que se utilizaran dentro del mismo, los cuales simpre se encontraran en un constante ciclo de cambios dada la funcionalidad del tamaguchi a menos que se siga el camino donde el reset esta presionado por mas de 5 segundos.

Los pricipales pasos del diagrama de flujo son los condicionales que se encuentran en la parte superior, los cuales son la base de las proximas acciones que se realizaran sobre los registros dentro del codigo para poder hacer cambios en las visualizaciones del proyecto. Lo mas importante en el camino que sigue el diagrama al cumplirse el condicional donde la señal muestre el boton como oprimido, es el ciclo de espera para volver a oprimir este y asi cambiar los niveles de cada estado, ademas dependiendo de este valor puede existir un cambio en el icono que se muestra en la pantalla LCD si el nivel esta por debajo o encima de cierto valor.

Por ultimo existen 2 etapas dentro del diagrama de flujo que rompen el funcionamiento general de un tamagochi, el primero es el boton reset donde se vuelve a los valores iniciales como si se empezara a jugar desde 0, el otro el modo test donde el tamagochi se encuentra en un estado de "desarrollador" ya que cambia entre estados y al oprimir el boton o interactuar con el sensor que interactua con el estado para poner el mismo en sus valores maximos o minimos dependiendo en cual de estos se encontraba anteriormente.

*FSM General*

![FSM](/Images/FSM.jpg)

La maquina de estados finitos (FSM) es un modelo de comportamiento con un numero finito de estados por los que el tamaguchi podria estar, en este proyecto se plantean inicialmente 42 posibles momentos en los que podria encontrarse el dispositivo representados con circulos. Las transiciones entre los estados se dan por señales de estado como por ejemplo el paso entre la energia y la alimentacion se da al oprimir el boton de alimentar por primera vez, por lo que la señal de estado es la que muestra cuando este boton esta oprimido. Y finalmente se encuentran los registros dentro de cada de los circulos, estos son las señales de control que se encargan de decidir que tipo de acciones se realizaran en cada momento, por ejemplo el momento despues de oprimir por segunda vez el boton de alimentar se activan las señales que se encargan de sumar 1 nivel y restarle valores a su contador para que su valor sea 0.

Para generalizar, los principales momentos estan dados por 

*Data Path*
