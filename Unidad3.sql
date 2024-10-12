USE [2024_LIBRERIA_BDI]
GO
--1. Declarar 3 variables que se llamen codigo, stock y stockMinimo
--respectivamente. A la variable codigo setearle un valor. Las variables stock y
--stockMinimo almacenar�n el resultado de las columnas de la tabla art�culos
--stock y stockMinimo respectivamente filtradas por el c�digo que se
--corresponda con la variable codigo.declare @codigo int, @stock int, @stockMinimo intset @codigo = 2select @stock = stock, @stockMinimo = stock_minimofrom articuloswhere cod_articulo = @codigoprint 'Codigo: ' + trim(str(@codigo))+ ' Stock: '  + trim(str(@stock))+ ' Stock Minimo: '  + trim(str(@stockMinimo))--declare @codigo int = 2--declare @stock int = (select stock from articulos where cod_articulo = @codigo)--declare @stockMinimo int = (select stock_minimo from articulos where cod_articulo = @codigo)select @codigo, @stock, @stockMinimoselect cod_articulo, stock, stock_minimofrom articuloswhere cod_articulo = 2--2. Utilizando el punto anterior, verificar si la variable stock o stockMinimo tienen
--alg�n valor. Mostrar un mensaje indicando si es necesario realizar reposici�n
--de art�culos o no.
declare @codigo int, @stock int, @stockMinimo intset @codigo = 3select @stock = stock, @stockMinimo = stock_minimofrom articuloswhere cod_articulo = @codigo

if @stock is null or @stockMinimo is null
	print 'El stock o el stock minimo no tienen valores validos'
else 
	if @stock >=  @stockMinimo
		print 'Es necesario realizar reposicion de articulos'
	else
		print 'No es necesario realizar reposicion de articulos'

--3. Modificar el ejercicio 1 agregando una variable m�s donde se almacene el precio
--del art�culo. En caso que el precio sea menor a $500, aplicarle un incremento del
--10%. En caso de que el precio sea mayor a $500 notificar dicha situaci�n y
--mostrar el precio del art�culo.
declare @codigo int, @precio moneyset @codigo = 3select @precio = pre_unitariofrom articuloswhere cod_articulo = @codigo

if @precio < 500 	begin
		update articulos
		set pre_unitario = pre_unitario*1.1
		where cod_articulo = @codigo
		print 'Precios actualizados'
	end
else
	print 'No se actualizo el precio'




--4. Declarar dos variables enteras, y mostrar la suma de todos los n�meros
--comprendidos entre ellos. En caso de ser ambos n�meros iguales mostrar un
--mensaje informando dicha situaci�n
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
	 end	 select @result

--5. Mostrar nombre y precio de todos los art�culos. Mostrar en una tercer columna
--la leyenda �Muy caro� para precios mayores a $500, �Accesible� para precios
--entre $300 y $500, �Barato� para precios entre $100 y $300 y �Regalado� para
--precios menores a $100.
SELECT descripcion, pre_unitario, mensaje =
case
	when pre_unitario > 500 then 'Muy Caro'
	when pre_unitario <= 500 and pre_unitario > 300 then 'Accessible'
	--when pre_unitario 
end
from articulos
--6. Modificar el punto 2 reemplazando el mensaje de que es necesario reponer
--art�culos por una excepci�n.

declare @codigo int, @stock int, @stock_minimo int
set @codigo = 22
set @stock = (select stock from articulos where cod_articulo = @codigo)
set @stock_minimo = (select stock_minimo from articulos where cod_articulo = @codigo)
select @codigo, @stock, @stock_minimo

if @stock < @stock_minimo
	RAISERROR(15600, -1, -1, 'Se necesita reponer')
else
	print 'No se necesita reponer'

--listar las facturas emitidas antes de un a�o que se ingresa por parametro al momento de la ejecucion
create proc pa_facturas
@anio int = 0
as
select nro_factura, cod_cliente, fecha, cod_vendedor
from facturas
where year(fecha) < @anio

exec pa_facturas @anio