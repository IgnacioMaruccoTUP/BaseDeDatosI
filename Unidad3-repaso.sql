USE libreria
GO

SET DATEFORMAT DMY

--Problema 3.1: Introducción a la Programación en SQL Server
--1. Declarar 3 variables que se llamen codigo, stock y stockMinimo respectivamente.
--A la variable codigo setearle un valor. Las variables stock y stockMinimo almacenarán 
--el resultado de las columnas de la tabla artículos stock y stockMinimo respectivamente filtradas por el código que se
--corresponda con la variable codigo.
DECLARE @codigo INT, @stock INT, @stockMinimo INT
SET @codigo = 1

SELECT @stock = stock, @stockMinimo = stock_minimo
FROM articulos
WHERE cod_articulo = @codigo

SELECT @stock stock, @stockMinimo stockMinimo
--2. Utilizando el punto anterior, verificar si la variable stock o stockMinimo tienen
--algún valor. Mostrar un mensaje indicando si es necesario realizar reposición de artículos o no.
IF @stock IS NULL OR @stockMinimo IS NULL
	print 'Stock o Stock Minimo no tienen valor'
ELSE
	IF @stockMinimo > @stock
		print 'Hace falta reponer articulos'
	ELSE
		print 'No hace falta reponer articulos'

--3. Modificar el ejercicio 1 agregando una variable más donde se almacene el precio
--del artículo. En caso que el precio sea menor a $500, aplicarle un incremento del
--10%. En caso de que el precio sea mayor a $500 notificar dicha situación y mostrar el precio del artículo.

DECLARE @codigo INT, @stock INT, @stockMinimo INT
DECLARE @precio MONEY
SET @codigo = 2
SELECT @stock = stock, @stockMinimo = stock_minimo, @precio = pre_unitario
FROM articulos
WHERE cod_articulo = @codigo
SELECT @stock stock, @stockMinimo stockMinimo, @precio Precio

IF @stock IS NULL OR @stockMinimo IS NULL
	print 'Stock o Stock Minimo no tienen valor'
ELSE
	IF @stockMinimo > @stock
		print 'Hace falta reponer articulos'
	ELSE
		print 'No hace falta reponer articulos'

IF @precio < 500
	UPDATE articulos
	SET pre_unitario = pre_unitario * 1.1
	WHERE cod_articulo = @codigo
ELSE
	print concat('No hace falta actualizar precio. El precio del articulo es de : $', @precio)
--4. Declarar dos variables enteras, y mostrar la suma de todos los números
--comprendidos entre ellos. En caso de ser ambos números iguales mostrar un mensaje informando dicha situación
DECLARE @num1 INT, @num2 INT, @total INT, @aux INT
SET @num1 = 1 -- 2 + 3 + 4
SET @num2 = 5
SET @total = 0
SET @aux = @num1 + 1

IF @num1 = @num2
	print 'Ambos numeros son iguales'
ELSE 
	while @num2 > @aux
	begin
	  set @total = @total + @aux 
	  set @aux = @aux + 1  
	end
	print CONCAT('La suma de todos los numeros comprendidos entre ', @num1, ' y ', @num2, ' es: ', @total)

--5. Mostrar nombre y precio de todos los artículos. Mostrar en una tercer columna
--la leyenda ‘Muy caro’ para precios mayores a $500, ‘Accesible’ para precios
--entre $300 y $500, ‘Barato’ para precios entre $100 y $300 y ‘Regalado’ para precios menores a $100.
SELECT descripcion Nombre, pre_unitario Precio, mensaje = 
	CASE
		WHEN pre_unitario > 500 then 'Muy caro' 
		WHEN pre_unitario BETWEEN 300 AND 500 THEN 'Accesible'
		WHEN pre_unitario BETWEEN 100 AND 300 THEN 'Barato'
		WHEN pre_unitario < 100 THEN 'Regalado'
	END
	FROM articulos
	ORDER BY 2
--6. Modificar el punto 2 reemplazando el mensaje de que es necesario reponer artículos por una excepción.


DECLARE @codigo INT, @stock INT, @stockMinimo INT
SET @codigo = 13

SELECT @stock = stock, @stockMinimo = stock_minimo
FROM articulos
WHERE cod_articulo = @codigo

SELECT @stock stock, @stockMinimo stockMinimo

IF @stock IS NULL OR @stockMinimo IS NULL
	RAISERROR ('Stock o Stock Minimo no tienen valor',16,1)
ELSE
	IF @stockMinimo > @stock
		RAISERROR ('Hace falta reponer articulos',16,1)
	ELSE
		print 'No hace falta reponer articulos'

--1. Cree los siguientes SP:
--a. Detalle_Ventas: liste la fecha, la factura, el vendedor, el cliente, el
--artículo, cantidad e importe. Este SP recibirá como parámetros de E un rango de fechas.
CREATE PROC detalle_venta_por_fecha
@fecha1 DATETIME,
@fecha2 DATETIME
AS
	SELECT F.fecha Fecha, F.nro_factura NroFactura, V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
		C.ape_cliente + ' ' + C.nom_cliente Cliente, A.descripcion Articulo, DF.cantidad Cantidad,
		DF.pre_unitario Importe
	FROM facturas F
		JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
		JOIN vendedores V ON F.cod_vendedor = V.cod_vendedor
		JOIN clientes C ON C.cod_cliente = F.cod_cliente
		JOIN articulos A ON A.cod_articulo = DF.cod_articulo
	WHERE F.fecha BETWEEN @fecha1 AND @fecha2

EXEC detalle_venta_por_fecha '20/05/2015', '20/05/2024'

SELECT * FROM facturas

SELECT * FROM detalle_facturas
--b. CantidadArt_Cli : este SP me debe devolver la cantidad de artículos o
--clientes (según se pida) que existen en la empresa.
CREATE PROC cantidad_art_cli
@parametro VARCHAR(3)
AS
	IF @parametro = 'art'
		SELECT COUNT(DISTINCT cod_articulo)
		FROM articulos
	ELSE
		SELECT COUNT(DISTINCT cod_cliente)
		FROM clientes

EXEC cantidad_art_cli ''


--c. INS_Vendedor: Cree un SP que le permita insertar registros en la tabla
--vendedores.
CREATE PROC ins_vendedor
@nombre VARCHAR(50),
@apellido VARCHAR(50),
@calle VARCHAR(50),
@altura INT,
@cod_barrio INT,
@nro_tel BIGINT,
@email VARCHAR(50),
@fecha_nac SMALLDATETIME
AS
	INSERT INTO vendedores(nom_vendedor, ape_vendedor, calle, altura, cod_barrio, nro_tel, [e-mail], fec_nac)
			VALUES(@nombre, @apellido, @calle, @altura, @cod_barrio, @nro_tel, @email, @fecha_nac)

EXEC ins_vendedor 'Pepito', 'Messi', 'Falsa', 456, 3, 0303456, 'agustinmurua@gmail.com', '1990/30/05'

SELECT * FROM vendedores

--d. UPD_Vendedor: cree un SP que le permita modificar un vendedor cargado.
ALTER PROC mod_vendedor
@codigo INT,
@nombre VARCHAR(50),
@apellido VARCHAR(50),
@calle VARCHAR(50),
@altura INT,
@cod_barrio INT,
@nro_tel BIGINT,
@email VARCHAR(50),
@fecha_nac SMALLDATETIME
AS
	UPDATE vendedores
	SET nom_vendedor = @nombre, ape_vendedor = @apellido, calle = @calle,altura = @altura,cod_barrio = @cod_barrio, 
	nro_tel = @nro_tel, [e-mail] = @email, fec_nac = @fecha_nac
	WHERE cod_vendedor = @codigo

EXEC mod_vendedor 1, 'Julian', 'Lencina', 'Octavio Pinto', 123, 1, null, 'valkrian@gmail.com', '1990/30/05'


--e. DEL_Vendedor: cree un SP que le permita eliminar un vendedor ingresado.
CREATE PROC elim_vendedor
@codigo INT
AS
	DELETE vendedores
	WHERE cod_vendedor = @codigo

EXEC elim_vendedor 8
--2. Modifique el SP 1-a, permitiendo que los resultados del SP puedan filtrarse por
--una fecha determinada, por un rango de fechas y por un rango de vendedores según se pida.
ALTER PROC detalle_venta_por_fecha_2
@fecha1 DATETIME = '04-08-2016',
@fecha2 DATETIME,
@cod_1 INT,
@cod_2 INT
AS
	IF @fecha2 IS NULL AND @cod_1 IS NULL 
		BEGIN
			SELECT F.fecha Fecha, F.nro_factura NroFactura, V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
				C.ape_cliente + ' ' + C.nom_cliente Cliente, A.descripcion Articulo, DF.cantidad Cantidad,
				DF.pre_unitario Importe
			FROM facturas F
				JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
				JOIN vendedores V ON F.cod_vendedor = V.cod_vendedor
				JOIN clientes C ON C.cod_cliente = F.cod_cliente
				JOIN articulos A ON A.cod_articulo = DF.cod_articulo
				WHERE F.fecha = @fecha1
			print 'test1'
		END
	ELSE 
		IF @fecha2 IS NULL
			BEGIN
				SELECT F.fecha Fecha, F.nro_factura NroFactura, V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
					C.ape_cliente + ' ' + C.nom_cliente Cliente, A.descripcion Articulo, DF.cantidad Cantidad,
					DF.pre_unitario Importe
				FROM facturas F
					JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
					JOIN vendedores V ON F.cod_vendedor = V.cod_vendedor
					JOIN clientes C ON C.cod_cliente = F.cod_cliente
					JOIN articulos A ON A.cod_articulo = DF.cod_articulo
				WHERE V.cod_vendedor BETWEEN @cod_1 AND @cod_2
				print 'test2'
			END
	
	ELSE 
		BEGIN
			SELECT F.fecha Fecha, F.nro_factura NroFactura, V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
				C.ape_cliente + ' ' + C.nom_cliente Cliente, A.descripcion Articulo, DF.cantidad Cantidad,
				DF.pre_unitario Importe
			FROM facturas F
				JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
				JOIN vendedores V ON F.cod_vendedor = V.cod_vendedor
				JOIN clientes C ON C.cod_cliente = F.cod_cliente
				JOIN articulos A ON A.cod_articulo = DF.cod_articulo
			WHERE F.fecha BETWEEN @fecha1 AND @fecha2
			print 'test3'
		END

--Por rango de fechas:
EXEC detalle_venta_por_fecha_2 @fecha1 = '20/05/2015', @fecha2 = '20/05/2020', @cod_1 = null, @cod_2 = null

--Fecha por defecto
EXEC detalle_venta_por_fecha_2 @fecha2 = null, @cod_1 = null, @cod_2 = null

--Por rango de vendedor:
EXEC detalle_venta_por_fecha_2 @fecha1 = null, @fecha2 = null, @cod_1 = 1, @cod_2 = 4

SELECT * FROM vendedores

SELECT * FROM facturas

SELECT * FROM detalle_facturas

--3. Ejecute los SP creados en el punto 1 (todos).
--4. Elimine los SP creados en el punto 1.
DROP PROC detalle_venta_por_fecha_2
--5. Programar procedimientos almacenados que permitan realizar las siguientes tareas:
--a. Mostrar los artículos cuyo precio sea mayor o igual que un valor que se envía por parámetro.
ALTER PROC art_pre_mayor
@precio_minimo MONEY
AS
SELECT descripcion Articulo, pre_unitario Precio, stock Stock, stock_minimo StockMinimo
FROM articulos
WHERE pre_unitario >= @precio_minimo
ORDER BY pre_unitario ASC

EXEC art_pre_mayor 1500

select * from articulos
--b. Ingresar un artículo nuevo, verificando que la cantidad de stock que se
--pasa por parámetro sea un valor mayor a 30 unidades y menor que 100.
--Informar un error caso contrario.
CREATE PROC ins_art_verif_stock
@descripcion VARCHAR(50),
@stockMinimo INT,
@stock INT,
@precio MONEY,
@observaciones VARCHAR(50)
AS
IF @stock BETWEEN 30 AND 100
	INSERT INTO articulos(descripcion, stock_minimo, stock, pre_unitario, observaciones)
	VALUES(@descripcion, @stockMinimo, @stock, @precio, @observaciones)
ELSE
	RAISERROR('El stock debe estar entre 30 y 100', 10, 1)


EXEC ins_art_verif_stock 'Lapicera bic trazo grueso', 50, 70, 1000, null
--c. Mostrar un mensaje informativo acerca de si hay que reponer o no stock
--de un artículo cuyo código sea enviado por parámetro
CREATE PROC mensaje_stock
@codigo INT
AS
	DECLARE @stock INT, @stockMinimo INT
	SELECT @stock = stock, @stockMinimo = stock_minimo
	FROM articulos
	WHERE cod_articulo = @codigo

	IF @stockMinimo > @stock
		print 'Reponer stock'
	ELSE
		print 'No reponer Stock'

select * from articulos
order by pre_unitario
EXEC mensaje_stock 13
--d. Actualizar el precio de los productos que tengan un precio menor a uno
--ingresado por parámetro en un porcentaje que también se envíe por
--parámetro. Si no se modifica ningún elemento informar dicha situación
CREATE PROC act_artic_precio
@precio MONEY,
@porc DECIMAL (10,1)
AS
	IF EXISTS (SELECT * FROM articulos WHERE pre_unitario < @precio)
		UPDATE articulos
		SET pre_unitario = pre_unitario * @porc
		WHERE pre_unitario < @precio
	ELSE
		print 'No se modificó ningun articulo'
EXEC act_artic_precio 140, 0.9 
--e. Mostrar el nombre del cliente al que se le realizó la primer venta en un parámetro de salida.
CREATE PROC nombre_primer_cliente
@nombre VARCHAR(50) OUTPUT
AS
	SELECT TOP 1 @nombre = C.nom_cliente
	FROM facturas F
		JOIN clientes C ON C.cod_cliente = F.cod_cliente
	ORDER BY F.fecha ASC

DECLARE @nombre VARCHAR(50)
EXEC nombre_primer_cliente @nombre OUT
print @nombre

SELECT *
FROM facturas F
JOIN clientes C ON C.cod_cliente = F.cod_cliente
--f. Realizar un select que busque el artículo cuyo nombre empiece con un
--valor enviado por parámetro y almacenar su nombre en un parámetro de 
--salida. En caso que haya varios artículos ocurrirá una excepción que
--deberá ser manejada con try catch.
ALTER PROC artic_nombre
@caracter VARCHAR(1),
@nombre VARCHAR(50) OUTPUT
AS
	BEGIN TRY
		IF 1 < (SELECT COUNT(DISTINCT cod_articulo)
				FROM articulos
				WHERE descripcion LIKE @caracter + '%')
			RAISERROR ('Existen múltiples artículos que coinciden con el criterio.',10,1)
		ELSE
			SELECT @nombre = descripcion
			FROM articulos
			WHERE descripcion LIKE @caracter + '%'
	END TRY
	BEGIN CATCH
		PRINT 'Error: ' + ERROR_MESSAGE();
	END CATCH

DECLARE @articulo VARCHAR(50)
EXEC artic_nombre 'S', @articulo OUT
PRINT @articulo

SELECT * FROM articulos order by descripcion


--Problema 3.3: Funciones definidas por el usuario
--6. Cree las siguientes funciones:
--a. Hora: una función que les devuelva la hora del sistema en el formato HH:MM:SS (tipo carácter de 8).
CREATE FUNCTION devolver_hora_sistema()
RETURNS VARCHAR(8)
BEGIN
	DECLARE @HORA VARCHAR(8)
	SET @HORA = TRIM(STR(DATEPART(hh,GETDATE())))+ ':' + TRIM(STR(DATEPART(mi, GETDATE()))) + ':' + TRIM(STR(DATEPART(ss, GETDATE())))
	RETURN @HORA
END

SELECT TRIM(STR(DATEPART(hh,GETDATE())))+ ':' + TRIM(STR(DATEPART(mi, GETDATE()))) + ':' + TRIM(STR(DATEPART(ss, GETDATE())))

SELECT dbo.devolver_hora_sistema()
--b. Fecha: una función que devuelva la fecha en el formato AAAMMDD (en
--carácter de 8), a partir de una fecha que le ingresa como parámetro (ingresa como tipo fecha).
ALTER FUNCTION devolver_fecha
(@FECHA DATETIME)
RETURNS VARCHAR(8)
BEGIN
	DECLARE @CADENA VARCHAR(8)
	SET @CADENA = CONCAT(TRIM(STR(DATEPART(yyyy, @FECHA))),TRIM(STR(DATEPART(mm, @FECHA))),TRIM(STR(DATEPART(dd, @FECHA))))
	RETURN @CADENA
END

SELECT dbo.devolver_fecha('13/05/1990')	
--c. Dia_Habil: función que devuelve si un día es o no hábil (considere como
--días no hábiles los sábados y domingos). Debe devolver 1 (hábil), 0 (no hábil)
CREATE FUNCTION dia_habil
(@FECHA DATETIME)
RETURNS INT
BEGIN
	DECLARE @RESULTADO INT
		IF DATEPART(dw, @FECHA) = 1 OR DATEPART(dw, @FECHA) = 7
			SET @RESULTADO = 0
		ELSE
			SET @RESULTADO = 1
	RETURN @RESULTADO
END

SELECT dbo.dia_habil(GETDATE()+5)
--7. Modifique la f(x) 1.c, considerando solo como día no hábil el domingo.
CREATE FUNCTION dia_habil_2
(@FECHA DATETIME)
RETURNS INT
BEGIN
	DECLARE @RESULTADO INT
		IF DATEPART(dw, @FECHA) = 1
			SET @RESULTADO = 0
		ELSE
			SET @RESULTADO = 1
	RETURN @RESULTADO
END

SELECT dbo.dia_habil_2(GETDATE()+7)
--8. Ejecute las funciones creadas en el punto 1 (todas).
--9. Elimine las funciones creadas en el punto 1.
--10. Programar funciones que permitan realizar las siguientes tareas:
--a. Devolver una cadena de caracteres compuesto por los siguientes datos:
--Apellido, Nombre, Telefono, Calle, Altura y Nombre del Barrio, de un
--determinado cliente, que se puede informar por codigo de cliente o email.
CREATE FUNCTION devolver_cliente
(@CODIGO INT,
@EMAIL VARCHAR(50))
RETURNS VARCHAR(100)
BEGIN
	DECLARE @CADENA VARCHAR(100)
	
	IF @CODIGO IS NOT NULL AND @EMAIL IS NULL
		SELECT @CADENA = CONCAT('Cliente: ', ape_cliente, ' ' ,nom_cliente,' Telefono: ' ,nro_tel, ' Direccion: ' ,calle, ' ' ,altura, ' Barrio: ' ,B.barrio)
		FROM clientes C
			JOIN barrios B ON C.cod_barrio = B.cod_barrio
		WHERE C.cod_cliente = @CODIGO
	ELSE
		IF @CODIGO IS NULL AND @EMAIL IS NOT NULL
			SELECT @CADENA = CONCAT('Cliente: ', ape_cliente, ' ' ,nom_cliente,' Telefono: ' ,nro_tel, ' Direccion: ' ,calle, ' ' ,altura, ' Barrio: ' ,B.barrio)
			FROM clientes C
				JOIN barrios B ON C.cod_barrio = B.cod_barrio
			WHERE C.[e-mail] = @EMAIL
	RETURN @CADENA
END

SELECT dbo.devolver_cliente(1,null)

SELECT dbo.devolver_cliente(null, 'habarca@hotmail.com')

SELECT * FROM clientes
--b. Devolver todos los artículos, se envía un parámetro que permite ordenar
--el resultado por el campo precio de manera ascendente (‘A’), o descendente (‘D’).

--No se puede con funcion
ALTER PROC devolver_articulos_ordenados
@ORDER VARCHAR(1)
AS
	IF @ORDER = 'A'
		SELECT cod_articulo, descripcion, stock_minimo, stock, pre_unitario, observaciones
		FROM articulos
		ORDER BY pre_unitario ASC
	ELSE
		IF @ORDER = 'D'
			SELECT cod_articulo, descripcion, stock_minimo, stock, pre_unitario, observaciones
			FROM articulos
			ORDER BY pre_unitario DESC
		ELSE
			SELECT 'Indicar un orden de precios'

EXEC devolver_articulos_ordenados 'A'

--c. Crear una función que devuelva el precio al que quedaría un artículo en
--caso de aplicar un porcentaje de aumento pasado por parámetro.CREATE FUNCTION devolver_precio_modificado(@CODIGO INT,@PORCENTAJE DECIMAL(10,2))RETURNS TABLEAS	RETURN(		SELECT pre_unitario PrecioOriginal, pre_unitario * @PORCENTAJE PrecioConAumento		FROM articulos		WHERE cod_articulo = @CODIGO		)SELECT * FROM dbo.devolver_precio_modificado(1,1.1)--Problema 3.4: Triggers
--1. Crear un desencadenador para las siguientes acciones:
--a. Restar stock DESPUES de INSERTAR una VENTA
CREATE TRIGGER restar_stock
ON detalle_facturas
FOR insert
AS
BEGIN
	DECLARE @codigo INT
	DECLARE @cantidad INT
	SELECT @cantidad = cantidad, @codigo = cod_articulo FROM inserted
	UPDATE articulos
	SET stock = stock - @cantidad
	WHERE cod_articulo = @codigo
END

SELECT * FROM articulos
SELECT * FROM detalle_facturas

SELECT * from facturas

INSERT INTO facturas (fecha, cod_cliente, cod_vendedor) values (getdate(), 4, 4)
INSERT INTO detalle_facturas(nro_factura, cod_articulo, pre_unitario, cantidad) values(701, 29, 1005, 5)

INSERT INTO detalle_facturas(nro_factura)
--b. Para no poder modificar el nombre de algún artículo
CREATE TRIGGER no_modificar_nombre
ON articulos
FOR update
AS
BEGIN
	IF UPDATE (descripcion)
		begin
		raiserror('No se puede modificar el nombre de un articulo',16,1)
		rollback transaction
		end
end


--c. Insertar en la tabla HistorialPrecio el precio anterior de un artículo si el mismo ha cambiado
CREATE TRIGGER insertar_historico
ON articulos
FOR update
AS
BEGIN
	DECLARE @precio_historico MONEY 
	DECLARE @cod_articulo INT
	DECLARE @fecha_desde DATETIME
	IF UPDATE(pre_unitario)
		BEGIN
			SELECT @cod_articulo = cod_articulo, @precio_historico = pre_unitario FROM inserted
			SELECT @fecha_desde = max(fecha_desde) FROM historial_precios WHERE cod_articulo = @cod_articulo
			--Actualizar fecha_hasta 
			UPDATE historial_precios
			SET fecha_hasta = GETDATE()
			WHERE fecha_desde = @fecha_desde

			--Insertar Precio Historico
			INSERT INTO historial_precios(cod_articulo, precio, fecha_desde, fecha_hasta)
				VALUES(@cod_articulo, @precio_historico, GETDATE(), NULL)
		END
END

SELECT * FROM articulos
UPDATE articulos
SET  pre_unitario = 1008
WHERE cod_articulo = 29
SELECT * FROM historial_precios

DROP trigger tr_guardar_historialprecio
--d. Bloquear al vendedor con código 4 para que no pueda registrar ventas en el sistema.CREATE TRIGGER bloquear_vendedor_4ON facturasFOR insertASBEGIN	IF EXISTS (SELECT * FROM inserted WHERE cod_vendedor = 4)		begin		raiserror('El vendedor 4 no puede realizar ventas', 16,1)		rollback transaction		endENDSelect * from facturasinsert into facturas(fecha, cod_cliente, cod_vendedor) values (getdate(), 2, 3)Delete facturaswhere nro_factura = 703