
/*NO EJECUTAR TODO EL SCRIPT EN MEMORIA

/*PROCEDIMIENTO

Para el primer procedimiento crearemos un procedimiento que nos recoja los productos de la
tabla productor y nos indique si es necesario pedir al proveedor dichos productos para ellos
tomaremos esta referencias

>70 unidades “No se vende”
<70 y >20 “Bien de Stock”
<20 Unidades “Pedir ya*

Lo normal y fácil pienso que es hacerlo por una llamada y que diga si el producto de
existencias como va pero voy a hacerlo para que recoja todos los de la tabla y me los muestre
en una tabla nueva que crearemos */

delimiter //

create procedure Estado inventario ()
begin

		/*--Variables--*/
		declare finalizar bool default false;
		declare inv int;
		declare resultado varchar(50);
		declare id_prod int;

		/*--Delcaramos el cursor para recorrer todo el inventario de la tabla inventario--*/
		declare cur_inventario cursor
			for select PRODUCTOID from PRODUCTOS order by 1;

		/*--Declaro el manejador --*/
		declare continue handler for not found
		set finalizar = true;

		/*--Creamos la tabla que almacenara dichos datos del enunciado--*/
		drop table if exists STATUS_INVEN;

		create table STATUS_INVEN(
			producto id int(11),
			producto varchar(50),
			estado varchar(50)
			: );

    	/*--Condiciones--*/
		if inv > 70 then set resultado='No_se_vende';
		elseif inv < 70 then set resultado='Bien_de_Stock';
		elseif inv < 20 then set resultado='Pedir_ya';
		end if;

		/*--Abrimos el cursor--*/
		open cur_inventario;

			fetch cur_inventario into id_prod;

		while (finalizar=false) do

		/*--Realizamos la consulta que nos permite introducir los datos en nuestra nueva tabla creada 
		    anteriormente para ello luego asiganmos la variable para que se aplique en la nueva tabla--*/

		insert into STATUS_INVEN (producto_id,producto,estado)
		select PRODUCTOID, DESCRIPCION, resultado from PRODUCTOS
		   where PRODUCTOID = id_prod order by PRODUCTOID ;

		fetch cur_inventario into id_prod;
		end while;

		/*--Cerramos el cursor--*/
		close cur_inventario;

		/*--Mostrar la tabla final--*/
		select * from STATUS_INVEN;
end;
//


/* 
FUNCIONES

Para el apartado de funciones voy a realizar una funcion que me calcule el total de existencia
disponibles de una categoría que le pongamos de parámetro de entrada

Este a pesar de que es muy secillo pude ser bastante util ya que pefectamente al hacer añalis
de la empresa podemos calcular que tipo de sector ya se de redes o de impresoras de
portatiles obtenemos más cantidad y cuales menos el cual me lleva a realizar otra el cual nos
indique qué categoría de sector estamos recibiendo más ingresor en caso de ventas.
*/


delimiter //
create function calc_inven (catid int)
returns int
deterministic
begin
	/*--Variables--*/
	declare resultado int;

	/*--haremos un select para indentificar la categoria id la cual estableceremos
	una relacioncon el prarametro de entrada que indica la categoria--*/
	select sum(Existencia) into resultado from PRODUCTOS
	where categoriaid = catid limit 1;

	return resultado;
end;

 
/*Resultas de las funciones debemos recordar que se realiza con*/

select calc_inven (100);


/*La segunda funcion vamor a realizar lo mencinado anteriormente vamos a cojer el campo de
precio de unidad y los vamos a multiplicar por su existecia de esta forma podemos ver lo que
ganamos por vender todas esas existencias de cada producto en caso de haber un campo que
nos pueda indicar las ventas podemos realizar otro para multiplicar el precio de unidad por el
número de ventas de unidades al ver que mi en mi base de datos no tenemos un campo asi
no podemos establecer algo a tiempo real como las vventas pero queria asimilarlo como algo

asi en vez de eso hago un calculo de beneficios por el stock que hay en la tienda.*/

delimiter //
create function calc_inven (produ int)
returns int
deterministic
begin

	/*--Variables--*/
	declare resultado int;

	/*--Haremos un select para indentificar la categoria id la cual estableceremos una
	realacion con el parametro de entrada que indica la categoria--*/
	
	select preciounit * existencia into resultado from PRODUCTOS
	where productoid = produ limit 1;

	return resultado;
end;


/*Resultado de la funcion ¡este resutado que nos da podremos utilizar siguientemnete en un
trigger con alguna funcionalidad de codificación para porporcinar un código dentro de un
número de pedido o otra cosa .*/

select calc_inven (1);


/*Nota:
Toda funcion que se crea tiene que indicar una valor de entrada y de salida en cambio al
utilizar un procedimiento no hace falta o no es necesario indicarle voleres de entradra y salida
las funcien en cambio si En la creacion y en el apartado del final del return .*/

 
/*TRIGGERS*/

 

/*Trigger inserción

Para el primer Trigger de insercion vamos a realizar un trigger bastante sencillo vamos a
establecer que no deja introdir datos vacíos como el nombre, en el móvil y en el correo
electronico y ademas el correo tiene que llevar € y el móvil maximo y minimo 9 caracteres
numericos

Primero decido hacer los triggers de correctocion de campos en blanco por un lado en un
trigger sólo queda mas uniforme también. He descubirto que admite null el email ya que es
uno de los campos que admite null de esta forma podemos negarlo en vez de cambiarlo con
alter o cambiandolo en el trigger*/

delimiter //

/*--- Borramos el trigger para poder volver crearlo si existe ---*/
drop trigger if exists clientes_bi0 //
/*--- creamos el trigger e indicamos si se va aplicar antes de introducir datos y donde---*/
create trigger clientes_bi0
before insert on CLIENTES
for each row
begin

/*--- Comprobamos si está en blanco ---*/
if new.NOMBRECONTACTO ='' then
	signal sqlstate '45000'
	set message_text = 'un nombre vacio no se permite';
	end if;
/*--- Comprobamos si está en blanco ---*/
if new.NOMBRECIA ='' then
	signal sqlstate '45000'
	set message_text = 'un nombre vacio no se permite';
	end if;
/*--- Comprobamos si está en blanco el numero de mobil ---*/
if new.MOVIL ='' then
	signal sqlstate '45000'
	set message_text = 'no se puede introducir si el movil esta vacio';
	end if;
/*--- Comprobamos si está en blanco el numero de mobil ---*/
if new.EMAIL ='' then
	signal sqlstate '45000'
	set message_text = 'No se puede introducir si el email esta vacio';
	end if;
/*--- Comprobamos si está en null el email ---*/
if new.EMAIL is null then
	signal sqlstate '45000'
	set message_text = 'No se permiten clientes sin eamil';
    end if;

end;
//

/*Comprobacion del trigger*/

INSERT INTO CLIENTES VALUES (15,'1244567888','SUPERMERCADO DESCUENTO','','AV.LA PRENSA',NULL,1234,099234561,NULL);


/*Para la segunda parte vamos de a establecer el límite para el email el € y para el movil 9
caracteres numericos esto lo guardar en otro trigger aparte como ya he comentado prefiero

realizarlo asi asi tenemos todo los de blanco de una tabla en un solo trigger

Usando La función length nos devuelve la longitud de una cadena en formato de bytes de tal
forma que podemos expresar loguitudes de cadenas. Con regexp establecemos una cadena
regular de caractere tipo cuando hacemos cadenar regulares usando el comando grep pues

con regexp nos permite añadir una cadena regular*/


delimiter //
/*--- Borramos el trigger si existe por seguridad ---*/
drop trigger if exists clientes2_bi0 //
/*--- creamos el trigger e indicamos si se va aplicar antes de introducir datos y donde ---*/
create trigger clientes2_bi0
before insert on CLIENTES
for each row
begin

/*--- Comprobamos si el numero  del mobil tiene 9 caracteres numericos --*/
	if length(new.MOVIL)<9 then
	signal sqlstate '45000'
	set message_text = 'Tiene menos de 9 dijitos el numero';
	end if;
/*--- Comprobamos si el email tiene @ el correo y si tiene el formato que indicamos ---*/
	if (new.EMAIL regexp '^[A-Z0-9._%-][emailprotected][A-Z0-9.-]+\.[A-Z](2,4)$')=0 then
	signal sqlstate '45000'
	set message_text = 'formato de correo incorrecto';
end if;

end;


/*Usando La función length nos devuelve la longitud de una cadena en formato de bytes de tal
forma que podemos expresar loguitudes de cadenas. Con regexp establecemos una cadena
regular de caractere tipo cuando hacemos cadenar regulares usando el comando grep pues
con regexp nos permite añadir una cadena regular
Comprobacion del trigger colocando 7 numero , Nota en caso de no especificar el la logitud
maxima de int del campode movil deberiamo hacer otra que indicar que fuera >8 caracteres
*/

INSERT INTO CLIENTES VALUES (15,'1244567888','SUPERMERCADO DESCUENTO','PACO','AV.LA PRENSA',NULL,1234,09923456,NULL);

 
/*Trigger modificación

Los triggers de modificacion como su nombre indica trantan el contenido de los datos que se
filtra pero solo cuando modificamos es decir cuando realizamos un update deberimaos
realizar una copia del los anteriroes para seguridad y modificacrla para que fuera de aplicable
el filtro en casode actualizacionde datos pero para no repetir el mismo trigger voy a realizar
uno nuevo que lo voy aplicar a la tabla empleados ya que e visto que tengo permitido null en
el nombre de empleado voy a corregir su actualizacion de datos mediante este triggger.*/

delimiter //
/*---borrmaos el trigger para volver a crearlo ---*/
drop trigger if exists empleados_bu //
/*---creamos el trigger e indicamos si se va aplicar antes de introducir datos y donde---*/
create trigger empleados_bu
before update on EMPLEADOS
for each row
begin

	if new.nombre is null then
		signal sqlstate '45000'
		set message text = 'No puede haber un empleado sin nombre';
	elseif new.nombre = ' ' then
		signal sqlstate '45000'
		set message text = 'No puede haber un empleado con el nombre vacio';
	end if;
end;

/*Conclusiones no podemos modificar el nombre de un Empledo en forma de null o vacio pero
seguramente inserta si, con esto ya estoy obserbando que para crear una base de datos
cuanto más grande sea mas trigger de filtrado habra que poner tanto para inserciion de datos
como para modificacion de los mismos.*/

UPDATE EMPLEADOS SET NOMBRE="" where EMPLEADOTID=1;

UPDATE EMPLEADOS SET NOMBRE=null where EMPLEADOID=1;


/*Trigger de borrado
Para finalizar el apartado de Triggers voy a crear un Trigger de borrado el cual mi idea era
intoducirlo para evitar si se ejecutara una borrado protejiera las ordenes de trabajo por
encima de la fecha que establecemos*/

delimiter //
/*--- Borramos el trigger para poder volver a crearlo ---*/
drop trigger if exists orden_bd //
/*--- Creamos el trigger e indicamos si se va a plicar despues de introducir datos y donde ---*/
create trigger orden_bd
before delete on ORDENES
for each row
begin
	/*--- Creamos las varables ---*/
	Declare fecha date;
    /*--- Asignamos variables al campo de columna ---*/
	set fecha = date_format(fechaorden,"%d%m%Y");
    /*--- condiciones de borrar ordenes con una fecha interior a la establecida ---*/
	1f fecha > 2012-06-07 then
		signal sqlstate '45000'
		set message text = 'Fecha no se puede borrar la ordenes superiores a la fecha 2012-06-07';

	end if;
end;

/*No he podido comprobarlo ya que me pone un error luego cuando ejecuto el el borrado

DELETE FROM ÓRDENES WHEREFECHAORDENES = 2002-06-07;

Si funciona deberia borrar esa fecha y en caso de poner un fecha superior a la indicada
debiara saltar la escepcion y lanzar el mensaje auxilirar,
Me informado a trvaes de internet por este error y muchos se referia al formato por lo que lo
cambie con la funcio date_format pero al final no se si es porque el DELETE no tabaja con
fechas

https://forum.openoffice.org/es/forum/viewtopic.php?f-39€t=5467*/

/*EVENTOS

Los eventos son tareas que se ejecutan de acuerdo a un horario. Por tanto, son eventos
programados que al establecer un cirto tiempo se ejecutan funciona parecido a trigger pero
simpre con la condicion es el tiempo.
Hay dos clases de eventos:
Los que se programan para una única ocasión
Los que se ocurren periódicamente cada cierto tiempo

Para llevar a cabo la funcionalidad de eventos en nuestra base deberemos activar el
programador de eventos.Ahora nuestra base de datos ya puede ejecutar eventos, sin el tener el programador de
eventos activado nos daria un error al ejecutar un evento creado

Primer evento a reliazar es uno que queria hacer y es que hay una orden que se ejecuta todas
la seman que es limpiar el almacén voy a insertarla mediante un insert no e caido como
incrementar el orden id así que e modificado dicha columna esto si fuera un evento de cada
hora no estaria bien por que siempre tendria que hacer la fase de alter table para bien

deberiamos realizar este alter table fuera del evento.*/

DELIMITER //
/*--- Creamos el evento con su nombre indicamos las veces que se ejucta y 
	   desde que fecha empiza podemos utilizar END para poner limite de finalizacion ---*/
CREATE EVENT ordenes_limp
ON SCHEDULE EVERY 1 WEEK
	STARTS '2021-05-20 18:30:00'
	ENABLE
DO
BEGIN
/*--- Modificamos el esquema de la tabla para que autoincremente 
	  en uno asi no es necesario  poner valor en su campo---*/
	ALTER TABLE ordenes ADD ordenid INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

/*--- Modificamos el esquema de la tabla que cojea lafecha hoy y lo inserte ---*/
	INSERT INTO ORDENES (EMPLEADOID, CLIENTEID, FECHAORDEN, DESCUENTO) VALUES (4,1,M0W(),1);

END//

/*Voy a hacer otro evento que me añada 5 al al asemana de stock a los productos con id 1,5 ,3
ya que son productos que tenemos constante demanda y queremos autoamtizarlo ya que los
demans productos rara vez hay demand*/a

DELIMITER //
/*--- Creamos el evento con su nombre indicamos las veces que se ejucta y 
	   desde que fecha empiza podemos utilizar END para poner limite de finalizacion ---*/
CREATE EVENT inserl53_existencia
ON SCHEDULE EVERY 1 month
	STARTS '2021-05-20 18:30:00'
	ENABLE
DO
BEGIN
/*--- Modificamos el campo de la tabla existenciasde producto +5 ---*/
	UPDATE PRODUCTOS SET EXISTENCIA=EXISTENCIA+5 WHERE PRODUCTOID=1;
	UPDATE PRODUCTOS SET EXISTENCIA=EXISTENCIA+5 WHERE PRODUCTOID=2;
	UPDATE PRODUCTOS SET EXISTENCIA=EXISTENCIA+5 WHERE PRODUCTOID=2;

END//

/*SHOW events;*/

/*ara finalizar el sistema de copia de seguridad considero que debido el tamano de la empresa
y la cantidad de datos que se maneja o se modifican o añaden es minusculos comparado con
empresas que mueven millones de registros considero hacer un script sencillo de un backup
fisico para realiazar la copia de seguridad de la base de datos ,ademans lo ejecutaremos
cuando insertemos o modificamos algun dato. En cambio un empresa con multitud de tráfico
en la base de datos esto no se puede dejar así habría que generar un escript y cargarlo en un
evento para que se realice una copia diariamente y la enviara remotamente y ademas
introduciria la base de datos en un en un sistema de almacenamiento raid 1 en caso de caida
del servidor*/

#/bin/bash

echo "comienza el backup"
echo
date
MYSQL_BACKUP_DIR=/home/christian

mysqldump --opt --single-transaction -u administrador --password=barcelona223- --routines PCRS>
$MYSQL_BACKUP_DIR/PCRS_$(date +$%d%m%y).sql

if [ $?==0 ]
then
	echo "Fin de la copia de seguridad"
	date 
	find $MYSQL_BACKUP_DIR -type f -mtime +10 -exec rm {} \;
	echo "Fin de la ejecucion se a realizado la copia correctamente"
else 
	echo "Ha habido algun error durante la copia"
	date
fi

/*RESUMEN PROBLEMA DE CAMBIO DE CONTRASEÑA Y SE  ARREGLA POR LACONECXION DEL USUARIO AL UTILIZAR /*
/*He tenido algunos problema al usar este usuario en vez de root ya que con root no tenia
ningun problema pero este usuario está con conecxion SSL lo habia creado con la funcion de
root pero sin root ya que poner root en un script y mostrar su contraseña no debe ser posible
por medidads de seguridad.
De tal forma e decidido cargarme el usuario crearlo sin SSL*/

DROP USER IF EXISTS'administrador'@'localhost';
CREATE USER 'administrador'@'localhost' IDENTIFIED BY 'barcelona223-';
GRANT ALL PRIVILEGES ON * , * TO 'administrador'@'localhost';
FLUSH PRIVILEGES;

/*Con esta seccion de la practica acado de descubrir eso mediante conecxiones SSL no puedes
realizar un Dump de la base de datos al igual que seguramnete alguno ora conecxion desde
un script

/*EJECUATR SCRIPT*/
/*sh Script_copiabase.sh*/

 

/*Finalmente podemos observar la copia de seguridad como se arealizado y esta albergada en
el directorio /home/christian. el escript almacenará maximo 10 copias de seguriad y
automaticamente borra la utlima crear sustituyendola*/


 

