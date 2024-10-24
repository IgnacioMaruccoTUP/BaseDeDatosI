USE [2024_LIBRERIA_BDI]
GO
USE LIBRERIA
GO

SET DATEFORMAT DMY


--Problema 3.1: Introducción a la Programación en SQL Server

--1. Declarar 3 variables que se llamen codigo, stock y stockMinimo
--respectivamente. A la variable codigo setearle un valor. Las variables stock y
--stockMinimo almacenarán el resultado de las columnas de la tabla artículos
--stock y stockMinimo respectivamente filtradas por el código que se
--corresponda con la variable codigo.
declare @codigo int, @stock int, @stockMinimo int
set @codigo = 2
select @stock = stock, @stockMinimo = stock_minimo
from articulos
where cod_articulo = @codigo
print 'Codigo: ' + trim(str(@codigo))+ ' Stock: '  + trim(str(@stock))+ ' Stock Minimo: '  + trim(str(@stockMinimo))


--declare @codigo int = 2
--declare @stock int = (select stock from articulos where cod_articulo = @codigo)
--declare @stockMinimo int = (select stock_minimo from articulos where cod_articulo = @codigo)

select @codigo, @stock, @stockMinimo

select cod_articulo, stock, stock_minimo
from articulos
where cod_articulo = 2
--2. Utilizando el punto anterior, verificar si la variable stock o stockMinimo tienen
--algún valor. Mostrar un mensaje indicando si es necesario realizar reposición
--de artículos o no.
declare @codigo int, @stock int, @stockMinimo int
set @codigo = 3
select @stock = stock, @stockMinimo = stock_minimo
from articulos
where cod_articulo = @codigo

if @stock is null or @stockMinimo is null
	print 'El stock o el stock minimo no tienen valores validos'
else 
	if @stock >=  @stockMinimo
		print 'Es necesario realizar reposicion de articulos'
	else
		print 'No es necesario realizar reposicion de articulos'

--3. Modificar el ejercicio 1 agregando una variable más donde se almacene el precio
--del artículo. En caso que el precio sea menor a $500, aplicarle un incremento del
--10%. En caso de que el precio sea mayor a $500 notificar dicha situación y
--mostrar el precio del artículo.
declare @codigo int, @precio money
set @codigo = 3
select @precio = pre_unitario
from articulos
where cod_articulo = @codigo

if @precio < 500 
	begin
		update articulos
		set pre_unitario = pre_unitario*1.1
		where cod_articulo = @codigo
		print 'Precios actualizados'
	end
else
	print 'No se actualizo el precio'




--4. Declarar dos variables enteras, y mostrar la suma de todos los números
--comprendidos entre ellos. En caso de ser ambos números iguales mostrar un
--mensaje informando dicha situación
declare @num1 int, @num2 int, @result int
set @num1 = 1
set @num2 = 4
set @result = 0
if @num1 = @num2
	select 'Numeros iguales' Error
else
	while (@num1 < (@num2 - 1))
	 begin
		 set @result=@result + @num1 + 1
		 set @num1=@num1+1
	 end
	 select @result


--5. Mostrar nombre y precio de todos los artículos. Mostrar en una tercer columna
--la leyenda ‘Muy caro’ para precios mayores a $500, ‘Accesible’ para precios
--entre $300 y $500, ‘Barato’ para precios entre $100 y $300 y ‘Regalado’ para
--precios menores a $100.
SELECT descripcion, pre_unitario, mensaje =
case
	when pre_unitario > 500 then 'Muy Caro'
	when pre_unitario <= 500 and pre_unitario > 300 then 'Accessible'
	when pre_unitario <= 300 and pre_unitario > 100 then 'Barato'
	when pre_unitario < 100 then 'Regalado'
end
from articulos
--6. Modificar el punto 2 reemplazando el mensaje de que es necesario reponer
--artículos por una excepción.
declare @codigo int, @stock int, @stock_minimo int
set @codigo = 3
set @stock = (select stock from articulos where cod_articulo = @codigo)
set @stock_minimo = (select stock_minimo from articulos where cod_articulo = @codigo)

-- Mostrar los valores antes del if
print 'Stock actual: ' + CAST(@stock AS varchar(10))
print 'Stock mínimo: ' + CAST(@stock_minimo AS varchar(10))

if @stock < @stock_minimo
	RAISERROR('Se necesita reponer', 16, 1)
else
	print 'No se necesita reponer'


--Problema 3.2: Procedimientos Almacenados

--Ejercicio profe: listar las facturas emitidas antes de un año que se ingresa por parametro al momento de la ejecucion
create proc pa_facturas
@anio int = 0
as
select nro_factura, cod_cliente, fecha, cod_vendedor
from facturas
where year(fecha) < @anio

exec pa_facturas 2015

--Crear un procedimiento almacenado que muestre la descripción de un artículo
--de código determinado (enviado como parámetro de entrada) y nos retorne el total
--facturado para ese artículo y el promedio ponderado de los precios de venta de ese
--artículo
CREATE PROC PA_VENTAS_ARTICULO
@CODIGO INT,
@TOTAL DECIMAL(10,2) OUTPUT,
@PROM_POND DECIMAL(10,2) OUTPUT
AS
BEGIN
	-- Seleccionamos la descripción (solo para mostrar, no afecta los outputs)
	SELECT descripcion
	FROM articulos
	WHERE cod_articulo = @CODIGO;
	
	-- Asignamos el total de ventas al parámetro de salida @TOTAL
	SELECT @TOTAL = SUM(pre_unitario * cantidad)
	FROM detalle_facturas
	WHERE cod_articulo = @CODIGO;
	
	-- Asignamos el precio promedio ponderado al parámetro de salida @PROM_POND
	SELECT @PROM_POND = SUM(pre_unitario) / SUM(cantidad)
	FROM detalle_facturas
	WHERE cod_articulo = @CODIGO;
END

--Ejecutar el procedimiento:

DECLARE @s DECIMAL(12,2), @p DECIMAL(10,2)
EXECUTE PA_VENTAS_ARTICULO 5, @S OUTPUT, @P OUTPUT
SELECT @s TOTAL, @p 'Precio Promedio Ponderado'

--1. Cree los siguientes SP:
--a. Detalle_Ventas: liste la fecha, la factura, el vendedor, el cliente, el
--artículo, cantidad e importe. Este SP recibirá como parámetros de E un
--rango de fechas.


CREATE PROC PA_DETALLE_VENTAS
@fecha_inicial DATETIME,
@fecha_final DATETIME
AS
SELECT fecha Fecha, F.nro_factura NroFactura, V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
	C.ape_cliente + ' ' + C.nom_cliente Cliente, descripcion, DF.cantidad Cantidad, DF.cantidad * DF.pre_unitario Importe
FROM facturas F JOIN vendedores V ON F.cod_vendedor = V.cod_vendedor
	JOIN clientes C ON C.cod_cliente = F.cod_cliente
	JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
	JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE F.fecha BETWEEN @fecha_inicial AND @fecha_final

EXEC PA_DETALLE_VENTAS '01/01/2009', '01/01/2014'

--b. CantidadArt_Cli : este SP me debe devolver la cantidad de artículos o
--clientes (según se pida) que existen en la empresa.
CREATE PROC CantidadArt_Cli
@entidad VARCHAR(10),
@cantidad INT OUTPUT
AS
IF @entidad = 'Clientes'
	SELECT @cantidad = COUNT(distinct cod_cliente)
	FROM facturas

ELSE IF @entidad = 'Articulos'
	SELECT @cantidad = COUNT(distinct cod_articulo)
	FROM facturas F JOIN detalle_facturas DF ON F.nro_factura = DF.nro_factura

DECLARE @total INT
EXEC CantidadArt_Cli 'Articulos', @total OUTPUT
SELECT @total AS 'Cantidad'


--c. INS_Vendedor: Cree un SP que le permita insertar registros en la tabla
--vendedores.
CREATE PROC insert_vend
@nom_vendedor VARCHAR(50),
@ape_vendedor VARCHAR(50),
@calle VARCHAR(50),
@altura INT,
@cod_barrio INT,
@nro_tel BIGINT,
@email VARCHAR(50),
@fec_nac SMALLDATETIME
AS
	INSERT INTO vendedores (nom_vendedor, ape_vendedor, calle, altura, cod_barrio, nro_tel, [e-mail], fec_nac)
					VALUES (@nom_vendedor, @ape_vendedor, @calle, @altura, @cod_barrio, @nro_tel, @email, @fec_nac)

EXEC insert_vend 'Juan', 'Fior', 'Calle Falsa', 123, 1, 0303456, 'juan@email.com', '1980-05-10'

SELECT * from vendedores

--d. UPD_Vendedor: cree un SP que le permita modificar un vendedor cargado.
CREATE PROC mod_vend
@cod_vendedor INT,
@nom_vendedor VARCHAR(50),
@ape_vendedor VARCHAR(50),
@calle VARCHAR(50),
@altura INT,
@cod_barrio INT,
@nro_tel BIGINT,
@email VARCHAR(50),
@fec_nac SMALLDATETIME
AS
	UPDATE vendedores
	SET nom_vendedor = @nom_vendedor,
		ape_vendedor = @ape_vendedor,
		calle = @calle,
		altura = @altura,
		cod_barrio = @cod_barrio,
		nro_tel = @nro_tel,
		[e-mail] = @email,
		fec_nac = @fec_nac
		WHERE cod_vendedor = @cod_vendedor

EXEC mod_vend 7, 'Juan', 'Fior', 'Calle Falsa', 1234, 1, 0303456, 'juan@email.com', '1980-05-10'

SELECT * from vendedores
--e. DEL_Vendedor: cree un SP que le permita eliminar un vendedor ingresado.
--2. Modifique el SP 1-a, permitiendo que los resultados del SP puedan filtrarse por
--una fecha determinada, por un rango de fechas y por un rango de vendedores según se pida.
--3. Ejecute los SP creados en el punto 1 (todos).
--4. Elimine los SP creados en el punto 1.
--5. Programar procedimientos almacenados que permitan realizar las siguientes
--tareas:
--a. Mostrar los artículos cuyo precio sea mayor o igual que un valor que se envía por parámetro.
ALTER PROC most_art_precio_mayor
@precio INT
AS
	SELECT cod_articulo, descripcion, pre_unitario
	FROM articulos
	WHERE pre_unitario >= @precio
	ORDER BY 3

EXEC most_art_precio_mayor 1000
--b. Ingresar un artículo nuevo, verificando que la cantidad de stock que se
--pasa por parámetro sea un valor mayor a 30 unidades y menor que 100.
--Informar un error caso contrario.
CREATE PROC ins_art
@descripcion VARCHAR(50),
@stock_minimo SMALLINT,
@stock SMALLINT,
@pre_unitario DECIMAL(10,2),
@observaciones VARCHAR(50)
AS
	IF @stock BETWEEN 30 AND 100
		INSERT INTO articulos (descripcion, stock_minimo, stock, pre_unitario, observaciones)
					VALUES (@descripcion, @stock_minimo, @stock, @pre_unitario, @observaciones)
	ELSE
		RAISERROR('Stock fuera de rango (debe estar entre 30 y 100)', 16, 1)


EXEC ins_art 'Lapicera bic trazo fino', 75, 90, 1000, null


SELECT * FROM articulos

--c. Mostrar un mensaje informativo acerca de si hay que reponer o no stock
--de un artículo cuyo código sea enviado por parámetro
ALTER PROC inform_stock
@cod_articulo INT
AS
	DECLARE @stock_minimo INT, @stock INT
	SELECT @stock_minimo = stock_minimo, @stock = stock
	FROM articulos
	WHERE cod_articulo = @cod_articulo

	IF @stock_minimo > @stock
		print 'Reponer stock'
	ELSE
		print 'No hace falta reponer stock'

EXEC inform_stock 13


--GUIA:
create procedure pa_stock_art
@cod int
as
begin
if exists (select * from articulos where cod_articulo = @cod and stock < stock_minimo)
  print 'stock a reponer'
else
  print 'NO stock a reponer'
end
-- llamar
exec pa_stock_art 1
-- llamar
exec pa_stock_art 20

--d. Actualizar el precio de los productos que tengan un precio menor a uno
--ingresado por parámetro en un porcentaje que también se envíe por
--parámetro. Si no se modifica ningún elemento informar dicha situación
--e. Mostrar el nombre del cliente al que se le realizó la primer venta en un
--parámetro de salida.
--f. Realizar un select que busque el artículo cuyo nombre empiece con un
--valor enviado por parámetro y almacenar su nombre en un parámetro de 
--salida. En caso que haya varios artículos ocurrirá una excepción que
--deberá ser manejada con try catch.


--Problema 3.3: Funciones definidas por el usuario
--Crear una función a la cual se le envía una fecha y retorna el nombre del mes en español:
CREATE FUNCTION f_nombreMES
(@FECHA DATETIME = '2007/01/01') --Valor por defecto 2007/01/01
RETURNS VARCHAR(10)
AS
BEGIN
DECLARE @NOMBRE VARCHAR(10)
SET @NOMBRE = CASE MONTH(@FECHA)
		WHEN 1 THEN 'Enero'
		WHEN 2 THEN 'Febrero'
		WHEN 3 THEN 'Marzo'
		WHEN 4 THEN 'Abril'
		WHEN 5 THEN 'Mayo'
		WHEN 6 THEN 'Junio'
		WHEN 7 THEN 'Julio'
		WHEN 8 THEN 'Agosto'
		WHEN 9 THEN 'Septiembre'
		WHEN 10 THEN 'Octubre'
		WHEN 11 THEN 'Noviembre'
		WHEN 12 THEN 'Diciembre'
	END
RETURN @NOMBRE
END

--Probando funcion
SELECT dbo.f_nombreMES('2024/05/30')

--Listar todas las facturas emitidas en febrero, abril y agosto de los anios entre 2020 y 2023
--utilizando la funcion creada anteriormente
SELECT nro_factura, TRIM(STR(DAY(F.fecha))) + '-' +dbo.f_nombreMES(F.fecha) + '-' + TRIM(STR(YEAR(F.fecha))),
ape_vendedor + ' ' + nom_vendedor Vendedor
FROM facturas F
	JOIN Vendedores V ON V.cod_vendedor = F.cod_vendedor
WHERE dbo.f_nombreMES(F.fecha) IN ('febrero', 'abril', 'agosto')
AND YEAR(F.fecha) BETWEEN 2020 AND 2023

--Ejemplo Funciones de tabla de varias instrucciones
create function f_ofertas
(@minimo decimal(8,2))
returns @ofertas table-- nombre de la tabla
--formato de la tabla
(cod_articulo int,
 descripcion varchar(100),
 pre_unitario money,
 observaciones varchar(100)
)
as
begin
 insert @ofertas
 select cod_articulo,descripcion,pre_unitario,observaciones
 from articulos
 where pre_unitario < @minimo
 return
end


--Usando esa funcion

select *
from articulos as a
 join dbo.f_ofertas(600) as o
 on a.cod_articulo=o.cod_articulo;


 select descripcion,pre_unitario from dbo.f_ofertas(1000);

--6. Cree las siguientes funciones:
--a. Hora: una función que les devuelva la hora del sistema en el formato
--HH:MM:SS (tipo carácter de 8).
alter function f_dev_hora ()
returns varchar(8) as
begin
declare @hora varchar(8)
set @hora = (select convert(varchar, getdate(), 8))
return @hora
end

select dbo.f_dev_hora()

--b. Fecha: una función que devuelva la fecha en el formato AAAMMDD (en
--carácter de 8), a partir de una fecha que le ingresa como parámetro
--(ingresa como tipo fecha).
ALTER FUNCTION f_fecha
(@FECHA DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN 
	DECLARE @FECHAVARCHAR VARCHAR(8)
    --SET @FECHAVARCHAR = CONCAT(YEAR(@FECHA), 
    --                            RIGHT('0' + CAST(MONTH(@FECHA) AS VARCHAR(2)), 2), 
    --                            RIGHT('0' + CAST(DAY(@FECHA) AS VARCHAR(2)), 2))
	SET @FECHAVARCHAR = TRIM(STR(YEAR(@FECHA),4))+RIGHT('0'+TRIM(STR(MONTH(@FECHA))),2)+RIGHT('0'+TRIM(STR(DAY(@FECHA))),2)
	RETURN @FECHAVARCHAR
END


SELECT dbo.f_fecha('2024/01/31')


--c. Dia_Habil: función que devuelve si un día es o no hábil (considere como
--días no hábiles los sábados y domingos). Debe devolver 1 (hábil), 0 (no
--hábil)
ALTER FUNCTION f_diaHabil
(@FECHA DATETIME)
RETURNS INT
AS
BEGIN
	DECLARE @HABIL INT
	IF DATEPART(DW, @FECHA) = 1 OR DATEPART(DW, @FECHA) = 7
	SET @HABIL = 0
	ELSE
	SET @HABIL = 1
	RETURN @HABIL
END

SELECT dbo.f_diaHabil(getdate())

select getdate()



--7. Modifique la f(x) 1.c, considerando solo como día no hábil el domingo.
create function f_dev_hab_dom 
(@fec as date)
returns int as
begin
declare @hab int
declare @dia as int
set @dia = (SELECT DATEPART(DW, @fec))
set @hab = 1
if  @dia = 1
	set @hab = 0
return @hab
end

--8. Ejecute las funciones creadas en el punto 1 (todas).


--9. Elimine las funciones creadas en el punto 1.


--10. Programar funciones que permitan realizar las siguientes tareas:
--a. Devolver una cadena de caracteres compuesto por los siguientes datos:
--Apellido, Nombre, Telefono, Calle, Altura y Nombre del Barrio, de un
--determinado cliente, que se puede informar por codigo de cliente o email.
ALTER FUNCTION f_datos_cliente
(@id_cliente INT, @email VARCHAR(50))
RETURNS VARCHAR(100)
BEGIN
	DECLARE @DATOS VARCHAR(100)
	IF @id_cliente IS NOT NULL
		BEGIN
		SET @DATOS = (select 'Cliente: ' + nom_cliente + ' ' + ape_cliente + '-Telefono: ' + ' ' + 
		CAST(nro_tel AS VARCHAR(20)) +
		'Calle: ' + calle + ' ' + trim(str(altura))		
		from clientes where cod_cliente = @id_cliente)
		END
	ELSE
		BEGIN
		SET @DATOS = (select 'Cliente: ' + nom_cliente + ' ' + ape_cliente + '-Telefono: ' + ' ' + 
		CAST(nro_tel AS VARCHAR(20)) +
		'-Calle: ' + calle + ' ' + trim(str(altura))				
		FROM clientes WHERE [e-mail] = @email)
		END
	RETURN @DATOS
END

--Tomas:

CREATE function f_datos_cliente_tomas(
	@cod int = null,
	@email varchar(50)
)
returns varchar(100)
as
begin
	declare @ape varchar(50),@nom varchar(50), @tel varchar(50),@calle nvarchar(50), @altura int, @barrio nvarchar(50)
	if(@cod is not null)
		begin
		select @ape=c.ape_cliente, @nom = c.nom_cliente, @tel = c.nro_tel,
		@calle = c.calle,@altura = c.altura, @email = c.[e-mail], @barrio = b.barrio 
		from clientes c join barrios b on c.cod_barrio = b.cod_barrio
		where c.cod_cliente = @cod
		end
	else
		begin
		select @ape=c.ape_cliente, @nom = c.nom_cliente, @tel = c.nro_tel, @calle = c.calle, @barrio = b.barrio 
		from clientes c join barrios b on c.cod_barrio = b.cod_barrio
		where c.[e-mail] like @email
		end
	return concat (@ape,' - ', @nom,' - ', @tel,' - ', @calle,' - ', str(@altura,5),' - ', @barrio)

end

SELECT * FROM clientes
SELECT dbo.f_datos_cliente_tomas(2,'')

SELECT dbo.f_datos_cliente_tomas(null,'habarca@hotmail.com')

--b. Devolver todos los artículos, se envía un parámetro que permite ordenar
--el resultado por el campo precio de manera ascendente (‘A’), o
--descendente (‘D’).

-- (No se puede con funcion) PROCEDIMIENTO ALMACENADO:
CREATE PROC pa_articulos_ord
@ORDEN CHAR(1) = 'A'
AS
IF @ORDEN = 'A'
	SELECT * 
	FROM articulos
	ORDER BY pre_unitario
ELSE
IF @ORDEN = 'D'
	SELECT * 
	FROM articulos
	ORDER BY pre_unitario DESC
ELSE
	SELECT 'Se debe indicar un orden' Mensaje

EXEC pa_articulos_ord 'A'


--c. Crear una función que devuelva el precio al que quedaría un artículo en
--caso de aplicar un porcentaje de aumento pasado por parámetro.

--Problema 3.4: Triggers
--1. Crear un desencadenador para las siguientes acciones:
--a. Restar stock DESPUES de INSERTAR una VENTA
CREATE TRIGGER tr_venta
ON detalle_facturas
FOR INSERT
AS
	DECLARE @stock INT
	SELECT @stock = STOCK FROM articulos
					JOIN inserted ON articulos.cod_articulo = inserted.cod_articulo
	UPDATE articulos
	SET stock = (stock - inserted.cantidad)
	FROM inserted
	WHERE articulos.cod_articulo = inserted.cod_articulo
END

--TEORICO, CON ERROR
create trigger dis_ventas_insertar
on detalle_facturas
for insert
as
	declare @stock int
	select @stock= stock from articulos
	join inserted
	on inserted.cod_articulo=articulos.cod_articulo 
	--Aquí se está recuperando el stock actual del artículo afectado por la venta. 
	--La tabla inserted es una tabla especial generada automáticamente en los triggers, 
	--que contiene las filas recién insertadas (en este caso, la venta).
	if (@stock>=(select cantidad from inserted))
		update articulos 
		set stock=stock-inserted.cantidad
		from articulos
		join inserted
		on inserted.cod_articulo=articulos.cod_articulo
	else
		begin
		raiserror ('El stock en articulos es menor que la cantidad
		solicitada', 16, 1)
		rollback transaction
end
--b. Para no poder modificar el nombre de algún artículo
CREATE TRIGGER tr_no_mod_nombre
on articulos
for update
AS
	if update(descripcion)
		RAISERROR('No se puede modificar la descripcion de un articulo',16,1)


--c. Insertar en la tabla HistorialPrecio el precio anterior de un artículo si el mismo ha cambiado
ALTER TRIGGER tr_guardar_historialprecio
ON articulos
FOR UPDATE
AS
	if UPDATE(pre_unitario)
		INSERT INTO historial_precios (cod_articulo, precio, fecha_hasta)
		SELECT d.cod_articulo, d.pre_unitario,GETDATE()
		FROM deleted d


SELECT * FROM articulos

UPDATE articulos
SET pre_unitario = 1650
WHERE cod_articulo = 1

SELECT * FROM historial_precios
--d. Bloquear al vendedor con código 4 para que no pueda registrar ventas
--en el sistema

--Problema 3.5: Manejo de errores
--1. Modificar el ejercicio 2 del problema 3.1 reemplazando los mensajes mostrados
--en consola con print, por excepciones. Verificar el comportamiento en el SQL
--Server Management.
--2. Modificar el ejercicio anterior agregando las cláusulas de try catch para manejo
--de errores, y mostrar el mensaje capturado en la excepción con print. 