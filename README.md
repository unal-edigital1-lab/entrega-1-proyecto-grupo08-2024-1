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
| Sensor de Movimiento | Sensor MPU 6050 | El giroscopio detecta si la mascota está durmiendo (nivel de energía aumenta porque está descansando) o boca arriba (está activo y va disminuyendo el nivel de energía).|
| Pantalla | LCD 16x2 | Se observan las 2 caras de la mascota (si se encuentra mal o bien). Además, muestra la necesidad a la que se está haciendo referencia mediante la visualización de un ícono.|
| Leds 7 segmentos | Ánodo común | Se muestra el porcentaje del nivel seleccionado.|
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


*Diagrama de Flujo*

![Diagrama de flujo](/Images/Diagrama%20de%20flujo.jpg)

En el diagrama de flujo se encuentran diamantes para ejemplificar un condicional que se debe tener en cuenta para la sucesión de los siguientes pasos y se utilizan rectángulos para mostrar las acciones que se deben realizar durante ese paso. Además, al inicio del diagrama se encuentran los valores iniciales de los registros que se utilizarán dentro del mismo, los cuales siempre se encontrarán en un constante ciclo de cambios dada la funcionalidad del tamagotchi, a menos que se siga el camino donde el reset está presionado por más de 5 segundos.

Los principales pasos del diagrama de flujo son los condicionales que se encuentran en la parte superior, los cuales son la base de las próximas acciones que se realizarán sobre los registros dentro del código para poder hacer cambios en las visualizaciones del proyecto. Lo más importante en el camino que sigue el diagrama al cumplirse el condicional donde la señal muestre el botón como oprimido, es el ciclo de espera para volver a oprimir este y así cambiar los niveles de cada estado, además dependiendo de este valor puede existir un cambio en el icono que se muestra en la pantalla LCD si el nivel está por debajo o encima de cierto valor.

Por último, existen 2 etapas dentro del diagrama de flujo que rompen el funcionamiento general de un tamagotchi, el primero es el botón reset donde se vuelve a los valores iniciales como si se empezara a jugar desde cero, el otro el modo test donde el tamagotchi se encuentra en un estado de "desarrollador" ya que cambia entre estados y al oprimir el botón o interactuar con el sensor que interactúa con el estado para poner el mismo en sus valores máximos o mínimos dependiendo de en cuál de estos se encontraba anteriormente.

*FSM General*

![FSM](/Images/FSM.jpg)

La máquina de estados finitos (FSM) es un modelo de comportamiento con un número finito de estados por los que el tamagotchi podría estar. En este proyecto, se plantean inicialmente 42 posibles momentos en los que podría encontrarse el dispositivo, representados con círculos. Las transiciones entre los estados se dan por señales de estado; por ejemplo, el paso entre la energía y la alimentación se da al oprimir el botón de alimentar por primera vez, por lo que la señal de estado es la que muestra cuando este botón está oprimido. Finalmente, se encuentran los registros dentro de cada uno de los círculos; estos son las señales de control que se encargan de decidir qué tipo de acciones se realizarán en cada momento. Por ejemplo, el momento después de oprimir por segunda vez el botón de alimentar, se activan las señales que se encargan de sumar 1 nivel y restarle valores a su contador para que su valor sea 0.

Para generalizar, los principales momentos están dados por los estados que tendrá el tamagotchi y de estos desencadenan las acciones que se pueden realizar en cada una de ellas, además están los dos momentos de test y reset.

*Data Path/Sistema de Caja Gris*

![Sistema de Caja Gris](/Images/Diagrama%20de%20Caja%20Gris.png)

El anterior diagrama es mucho más detallado que el sistema de caja negra. Este muestra cómo es que el tamagochi funciona internamente, reflejando en cierta parte una mayor complejidad y entendimiento de las operaciones internas y cómo se encuentran interconectadas, dando una idea más clara y amplia sobre cómo es que la máquina de estados finitos funciona como cerebro para todo el sistema (unidad de control). 

De esta representación queda visible la interacción y el control de los datos, mostrando claramente cómo se conectan los 2 sensores, los botones y la visualización del tamagochi mencionados anteriormente. Se nota las diferentes entradas y salidas de cada una de las cajas, observando la cantidad de memoria requerida para el traspaso de información en cada caso. Finalmente, de este diagrama se puede concluir que facilita la comprensión y el desarrollo del sistema de manera global.


**Segunda Entrega (20% del total de la nota del proyecto)**

### Desarrollo y simulación del diseño
*Módulo de Botones*

El módulo top de los botones contiene 2 submódulos: uno para manejar los botones de manera sencilla y otro para implementar los botones de reset y test, los cuales deben estar presionados por 5 segundos para enviar una señal.

+ Módulo btnAntirebote.v

El primer módulo [btnAntirebote.v](Botones/btn/btnAntirebote.v) implementa un módulo de botones antirebote, este inicialmente tiene 3 entradas: clk, boton_in y reset. La única salida que tiene el módulo es boton_out. Se tiene también un counter y un parámetro para indicar el valor final del contador: *COUNT_BOT = 50000*. En cada ciclo de reloj se revisará el valor de reset, si este es 0 se le asignará al boton_out el valor de boton_in y counter será cero. Si reset es uno, se tienen que revisar varias opciones: primero si boton_in es igual a boton_out, en ese caso el counter aumentará, sino continuará en cero; la segunda condición es que boton_in sea 0 y el counter llegue al limite COUNT_BOT, en ese caso se le asignará 0 a boton_out y el counter se reincia; la tercera condición es que el boton_in sea 1 y el counter sea igual a la centesima parte del limite COUNT_BOT, en ese caso el counter vuelve a cero y a boton_out se le asigna uno. Para mayor simplicidad y para evitar una entrada a este módulo, se definio a reset como un registro con el valor de cero, dejando que la salida del módulo sea igual a la entrada.

//simulalicon btnAntireb

+ Módulo btnRT.v

El otro módulo [btnRT.v](Botones/btn/btnRT.v) tiene las entradas boton_in y clk, su salida será boton_out. Este tiene counter y un parametro local *COUNT_LIMIT = 250 x 10⁶*. Lo que hace este módulo es esperar a que el boton este presionado 5 segundos para mandar la señal; el valor de COUNT_LIMIT viene de pasar esos 5 segundos a ciclos de reloj de la FPGA: 5 S = 5 * 10⁹ nS, frecuencia del clk de la tarjeta = 50 MHz -> 20 nS por ciclo, teniendo en cuenta esto se obtiene que 5 segundos corresponden a 250 millones de ciclos de reloj.

Al probar un código inicial, se observó que al presionar un botón la FPGA toma esa señal como un 0, entonces si el boton_in = 0 quiere decir que esta presionado. La señal boton_out siempre será 1 a menos que el boton este presionado por más de 5 segundos, en ese momento se converitrá en cero. Esto se logra con el counter: si el boton_in esta presionado, el counter aumenta por cada ciclo de reloj y cuando llegue a COUNT_LIMIT el boton_out tomará el valor de 0, en cualquier otro caso será 1.

Para visualizar mejor la simulación se tomó un valor de COUNT_LIMIT menor, igual a 500 uS. Para el prototipo se tomo el valor original. 

//Simulacion BtnRT

En ella se observa que boton_out solo bajará su valor si boton_in esta en bajo por 500uS y se mantendrá así hasta que boton_in vuelva a subir ó, como el counter tiene una cierta cantidad de bits, hasta que llegue counter llegue a su limite impuesto por la memoria.


+ Módulo topBtn.v

El módulo top de los botones [topBtn.v](Botones/btn/topBtn.v) tiene como entrada los 4 botones del tamagotchi: btn_heal, btn_alimentación, btn_RST y btn_TST. Tendrán como salida 4 señales que irán a la FSM (btn_salud, btn_hambre, btn_reset, btn_test) y 4 leds para visualizar su funcionamiento en la FPGA (estos no serán implementados en el tamagotchi, solo se crearon para ver el correcto funcionamiento del módulo). Para las entradas btn_heal y btn_ali, se instanció el módulo [btnAntirebote.v](Botones/btn/btnAntirebote.v) y para btn_RST y btn_TST el módulo [btnRT.v](Botones/btn/btnRT.v), para las salidas de cada submódulo se implementaron cables wire (heal, ali, RST y TST).

En el módulo [btnAntirebote.v](Botones/btn/btnAntirebote.v) la salida es igual a la entrada y como la FPGA está negando los botones, las salidas btn_salud y btn_hambre se les asignará el valor negado de los wire (heal y ali respectivamente). Es decir que el boton siempre estaŕa en uno y cuando se presiona será cero, entonces a la salida del módulo se le asignará el valor contrario de la entrada para que envíe un uno cuando se presione el boton. 

El módulo [btnRT.v](Botones/btn/btnRT.v) tiene como salida un cero cuando se tiene el boton presionado 5 segundos, entonces tambien se asignan los valores negados para las salidas btn_reset y btn_test. Los leds tendrán el mismo valor que los wire, entonces estarán prendidos siempre y cuando se presionen los botones se apagarán, o se apagrán depues de 5 segundos presionados para el caso de reset y test.

//simTopBtn

En la simulación, se observa que las entradas siempre son 1 y cuando bajan corresponden al boton presionado; las salidas siempre estarán en 0 y cambian a 1 cuando los botones se presionen. Para salud y hambre la salida cambia a 1 instantanemate y para reset y test después del tiempo determinado (para la simulación se muestra un tiempo de 500 uS pero para el prototipo real es un tiempo de 5 segundos).

*Ultrasonido*

Para instanciar el sensor ultrasónico se utilizaron 4 módulos y un Top. El sensor trabaja apartir de dos señales: trigger y echo, tal como se ve en la siguiente figura.

![SeñalesUltrasonido](Imagenes/SeñalesUltrasonido.png)

El sensor al recibir la señal trigger con una duración de 10 uS en estado alto, envía 8 pulsos de sonido de 40KHz y pone en alto la señal echo hasta que detecte que los pulsos de sonido vuelvan al sensor. Dependiendo de cuanto tiempo estuvo en alto la señal echo se puede determinar la distancia a la cual se encuentra el objeto con la siguiente fórmula: Distancia [cm] = Tiempo [uS] * 0,01715. Esta se obtiene mediante la velocidad del sonido que es aproximadamente 29 cm/uS. Si se tiene el tiempo en el que la señal estuvo en alto, la distancia se encuentra dividiendo ese tiempo entre la velocidad; hay que tener en cuenta que la señal echo esta encendida desde que se envía al objeto hasta que vuelve, es decir solo se necesita la mitad del tiempo en la que esta encendida. Por esto la formula quedaría: Distancia [cm] = Tiempo [uS] / 2 * 29 [cm/uS]. 

Teniendo claro esto, ahora se analiza los módulos, todos se encuentran en la carpeta [ultrasonido](ultrasonido) con todos sus detalles.

+ ContadorConTrigger.v

El primer módulo es [ContadorConTrigger.v](ultrasonido/ContadorConTrigger.v). Este envía la señal Trigger al ultrasonido, la cual estará en alto por 10 uS y bajará, esto gracias a un counter que se registra en el código. La señal se enviará constantemente para que siempre se revise si hay un objeto frente al sensor. Se realizó un testbench para la simulación de este módulo: [ContadorConTrigger_tb.v](ultrasonido/ContadorConTrigger_tb.v):


/testbench trigger/

En ella se puede ver que la señal trig esta en alto por 10 uS y reinicia su ciclo poniendose en bajo.

+ ContadorConEcho.v

El segundno Módulo [ContadorConEcho.v](ultrasonido/ContadorConEcho.v) tendrá como entrada la señal Echo que recibe del sensor. Este tiene un contador que aumentará una unidad por cada ciclo de reloj en el que Echo esté en alto, en otro caso será 0. Tiene una salida llamada **echo_duration** a la que se le asignará el valor del counter cuando echo vuelva a cero. A continuación se muestra la simulación realizada.

/simulacion_echo/

En ella se puede observar que el counter es igual a cero cuando echo está en bajo y que la salida echo_counter solo tiene un valor diferente a cero justo después de que la señal echo baje que corresponde al último valor que tenía el counter.

+ ControlLed.v

El tercer módulo llamado [ControlLed.v](ultrasonido/ControlLed.v) se encarga de verificar que el objeto que se detecta esta en el rango requerido entre 1 y 10 centímetros. Para esto hay que hallar la conversióń de centímetros a ciclos de reloj. Despejando de la ecuación que se mencionó anteriormente: distancia [cm] = tiempo [uS] * 0,01715, se obtienen los tiempos 58 uS y 290 uS. Se sabe que la FPGA tiene una frecuancia de 50 MHz, es decir que toma 20 nS por cada ciclo de reloj, realizando la conversión se obtiene que tienen que pasar entre 2.900 y 14.500 ciclos de reloj con echo activo para que el objeto este en la distancia exigida. Este módulo recibirá la salida echo_duration del módulo anterior y en caso de que esta tenga un valor entre 2.900 y 14.500 se activará una señal llama **aux** la cual será la salida del módulo. 
/simulacionLed/

En la simulación hecha se puede apreciar que si echo_duration está entre los valores demandados, se activará la señal aux, en otro caso se mantendrá en 0. 

+ Salida.v


El siguiente módulo [Salida.v](ultrasonido/Salida.v) recibe la señal **aux**, la cual avisá si el sensor percibe un objeto. Sus salidas son las señales sens_ult, esta irá directamente a la FSM, y led, para verificar el funcionamiento adecuado del sensor. La señal sens_ult siempre estará en 0 hasta que la señal aux se ponga en alto, para que se pueda observar mejor la actuación del ultrasonido, esta señal estará en alto por 100 mS desde el flanco de subida de **aux**. La señal led tiene los valores contrarios a sens_ult, esto debido a que los leds de la FPGA están negados, entonces cuando estos reciban un 0 (sens_ult = 1) se encenderán.

/simulacionSalida/


Solo para observar mejor la simulación se disminuyo el tiempo en el que sens_ult está en alto a 100 uS. Así se mira que **sens_ult** se activa y **led** baja cuando **aux** tiene un flanco de subida, así se mantienen por el tiempo determinado. Se observa que si se recibe constantemente la señal aux, sens_ult se mantendrá en alto; gracias a esto si un objeto se queda quieto frente al sensor por mucho tiempo, el módulo sabrá que siempre esta ahí, si la señal fuera intermitente, el módulo creerá que el objeto se está removiendo y reubicando.

+ top.v

El módulo [top.v](ultrasonido/top.v) simplemente realiza las conexiones entre los módulos. Sus entradas serán: clk (de la FPGA) y echo (del sensor). Sus salidas: trig (hacía el sensor), sens_ult (a la FSM) y led (a la FPGA). Y tiene cables internos: aux y echo_duration.

/simulacion top/

En la simulación del top se encuentra la señal trig enviandose constantemente, se simula la entrada echo, las señales sens_ult y led solo cambian si la señal echo está activa por el tiempo necesario, ni más ni menos. Por ejemplo la primera señal que se envía de echo es demasiado corta para activar las salidas, y la tercera es demasiado larga. Al final se ve que si recibe constantemente la misma señal de echo, las salidas se van a mantener en el mismo valor así echo este cambiando. En la simulación el tiempo en que las salidas están en alto es de 100uS, pero en la implementación el tiempo es de 100 mS; esto se hizo para poder observar mejor la simulación.





*MPU6050 Giroscopio*
Para el desarrollo de la MPU6050, se utilizaron 3 módulos y un top. El código **i2cmaster** es el encargado de utilizar el protocolo I2C para la comunicación con el sensor MPU6050 por entradas bidireccionales de solo un bit. Adicionalmente, el código **mpu5060** se encarga de enviar la información de inicialización del sensor además de recoger la recibida del propio sensor. Estos dos códigos en conjunto son los principales para poder llevar a cabo el registro de entrada y salida de datos con el sensor. Además, se tiene el código **compare**, que lo que hace es justamente transformar este registro de la posición del giroscopio, en una salida de un bit (led) mostrando si está despierto o dormido según el signo del eje. Finalmente, se tiene el código **demo_mpu6050** que instancia los anteriores códigos para finalmente marcar 2 entradas (el clock de la FPGA y un reset), 2 entradas bidireccionales (SDA y SCL) y una salida que sería la del led.


````verilog
// Definición de los estados de la MPU6050
    parameter S_IDLE = 3'b000, //Estado inicial
              S_PWRMGT0 = 3'b001, //Estado de energía 0
              S_PWRMGT1 = 3'b010, //Estado de energía 1
              S_READ0 = 3'b011, //Estado para iniciar lectura
              S_READ1 = 3'b100, //Estado para continuar lectura
              S_STABLE = 3'b101; //Estado de estabilidad después de completar operación
````



````verilog
// Definición de los estados del I2CMASTER
    parameter S_IDLE = 5'b00000, //Estado de espera
              S_START = 5'b00001, //Estado de inicio 
              S_SENDBIT = 5'b00010, //Estado de envío de bit
              S_WESCLUP = 5'b00011, //Estado de espera de la subida del reloj SCL
              S_WESCLDOWN = 5'b00100, //Estado de espera de la bajada del reloj SCL
              S_CHECKACK = 5'b00101, //Estado de verificación de ACK/NACK
              S_CHECKACKUP = 5'b00110, //Estado de verificación con reloj alto
              S_CHECKACKDOWN = 5'b00111, //Estado de verificación con reloj bajo
              S_WRITE = 5'b01000, //Estado de escritura de datos
              S_PRESTOP = 5'b01001, //Estado previo a la señal de parada 
              S_STOP = 5'b01010, //Estado de parada
              S_READ = 5'b01011, //Estado lectura de datos
              S_RECVBIT = 5'b01100, //Estado de recepción de bits (de esclavo a maestro)
              S_RDSCLUP = 5'b01101, //Espera para la subida del SCL de lectura
              S_RDSCLDOWN = 5'b01110, //Espera para la bajada del SCL de lectura
              S_SENDACK = 5'b01111, //Estado para enviar ACK al esclavo después de leer
              S_SENDACKUP = 5'b10000, //Espera con ACK y reloj alto
              S_SENDACKDOWN = 5'b10001, //Espera con ACK y reloj bajo
              S_RESTART = 5'b10010; //Estado de reinicio de la comunicación
````


Primeramente, para poder analizar el código de la MPU6050 se utiliza un comparador análogo, pasando los datos a protocolo I2C. De esta forma, se puede analizar lo que recibe el sensor y lo que se envía del código.
Adicionalmente, se realiza una simulación del código para verificar los datos del compardaror, siendo la simulación la situación deseada y el comparador lo realmente recibido.

![Valor I2C datos iniciales analizador ](Images/I2C%20comparador.png)

*FSM total*


**Tercera Entrega (40% del total de la nota del proyecto)**

### Finalización e implementación del prototipo
