USE LIBRERIA_LCI2023
GO
SET DATEFORMAT DMY
--UNIDAD 1
--Problema 1.1 Consultas Sumarias
--7. Se quiere saber la cantidad de ventas que hizo el vendedor de código 3.
SELECT COUNT(F.nro_factura) CantidadVentas
FROM facturas F
JOIN vendedores V ON F.cod_vendedor = V.cod_vendedor 
WHERE V.cod_vendedor = 3
--8. ¿Cuál fue la fecha de la primera y última venta que se realizó en este negocio?
SELECT MIN(fecha) PrimeraVenta, MAX(fecha) UltimaVenta
FROM facturas
--9. Mostrar la siguiente información respecto a la factura nro.: 450: cantidad
--total de unidades vendidas, la cantidad de artículos diferentes vendidos y el importe total.
SELECT SUM(cantidad) 'Cantidad total de unidades vendidas', 
COUNT(DISTINCT cod_articulo) 'Cantidad de articulos diferentes vendidos', 
SUM(cantidad * pre_unitario) 'Importe Total' 
FROM facturas F
JOIN detalle_facturas DF ON F.nro_factura = DF.nro_factura
WHERE F.nro_factura = 450
--10.¿Cuál fue la cantidad total de unidades vendidas, importe total y el importe
--promedio para vendedores cuyos nombres comienzan con letras que van de la “d” a la “l”?
SELECT SUM(cantidad) 'Cantidad total de unidades vendidas', 
SUM(cantidad * pre_unitario) 'Importe Total',
SUM(cantidad * pre_unitario) / COUNT(DISTINCT F.nro_factura) 'Importe Promedio'
FROM facturas F 
JOIN detalle_facturas DF ON F.nro_factura = DF.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
WHERE v.nom_vendedor LIKE '[d-l]%'
--11.Se quiere saber el importe total vendido, el promedio del importe vendido y
--la cantidad total de artículos vendidos para el cliente Roque Paez.
SELECT SUM(DF.cantidad * DF.pre_unitario) 'Importe Total Vendido',
SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) 'Promedio del importe vendido',
SUM(DF.cantidad) 'Cantidad total de articulos vendidos'
FROM facturas F 
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE C.ape_cliente = 'Paez' AND C.nom_cliente = 'Roque'

--Resolucion guia AVG?????
select sum(pre_unitario*cantidad) 'Precio Tototal Vendido',
 avg(pre_unitario*cantidad) 'Promedio del importe vendido',
 sum(cantidad)'Cantidad de Articulos'
from facturas f
join detalle_facturas d on d.nro_factura=f.nro_factura
join clientes c on f.cod_cliente=c.cod_cliente
where ape_cliente = 'Paez' and nom_cliente= 'Roque'

--12.Mostrar la fecha de la primera venta, la cantidad total vendida y el importe
--total vendido para los artículos que empiecen con “C”.
SELECT MIN(F.fecha) 'Fecha de la Primer Venta',
SUM(DF.cantidad) 'Cantidad Total Vendida',
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total Vendido'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE A.descripcion LIKE 'C%'
--13.Se quiere saber la cantidad total de artículos vendidos y el importe total
--vendido para el periodo del 15/06/2011 al 15/06/2017.
SELECT SUM(DF.cantidad) 'Cantidad total vendida',
SUM(DF.cantidad * DF.pre_unitario) 'Importe total vendido'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE F.fecha BETWEEN '15/06/2011' AND '15/06/2017'
--14.Se quiere saber la cantidad de veces y la última vez que vino el cliente de
--apellido Abarca y cuánto gastó en total.
SELECT COUNT(distinct F.nro_factura) 'Cantidad de veces que vino el cliente',
MAX(F.fecha) 'Ultima vez que vino',
SUM(DF.cantidad * DF.pre_unitario) 'Cuanto gasto en total'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE C.ape_cliente = 'Abarca'
--15.Mostrar el importe total y el promedio del importe para los clientes cuya
--dirección de mail es conocida.
SELECT SUM(DF.cantidad * DF.pre_unitario) 'Importe Total',
SUM(DF.cantidad * DF.pre_unitario) / COUNT(distinct F.nro_factura) 'Promedio de importe'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE C.[e-mail] IS NOT NULL

--16.Obtener la siguiente información: el importe total vendido y el importe
--promedio vendido para números de factura que no sean los siguientes: 13, 5, 17, 33, 24.
SELECT SUM(DF.cantidad * DF.pre_unitario) 'Importe Total',
SUM(DF.cantidad * DF.pre_unitario) / COUNT(distinct F.nro_factura) 'Promedio de importe'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE F.nro_factura NOT IN (13, 5, 17, 33, 24)


--Problema 1.2 Consultas Agrupadas Clausula GROUP BY
--2. Por cada factura emitida mostrar la cantidad total de artículos vendidos
--(suma de las cantidades vendidas), la cantidad ítems que tiene cada factura
--en el detalle (cantidad de registros de detalles) y el Importe total de la facturación de este año.
SELECT F.nro_factura NroFactura,
SUM(DF.cantidad) 'Cantidad total de articulos vendidos',
COUNT(distinct cod_articulo) 'Cantidad de items de cada factura',
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 0
GROUP BY F.nro_factura 
--3. Se quiere saber en este negocio, cuánto se factura:
--a. Diariamente
--b. Mensualmente
--c. Anualmente 
--a Diariamente
SELECT F.fecha, 
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
GROUP BY F.fecha
ORDER BY 1
--b. Mensualmente
SELECT MONTH(F.fecha) MES, YEAR(F.fecha) 'Año', 
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
GROUP BY MONTH(F.fecha), YEAR(F.fecha)
ORDER BY 2, 1
--c. Anualmente 
SELECT YEAR(F.fecha) 'Año', 
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
GROUP BY YEAR(F.fecha)
ORDER BY 1
--4. Emitir un listado de la cantidad de facturas confeccionadas diariamente,
--correspondiente a los meses que no sean enero, julio ni diciembre. Ordene
--por la cantidad de facturas en forma descendente y fecha.
SELECT F.fecha,
COUNT(distinct F.nro_factura) 'Cantidad de Facturas'
FROM facturas F
WHERE MONTH(F.fecha) NOT IN (1, 7, 12)
GROUP BY F.fecha
ORDER BY 2 DESC, 1
--5. Se quiere saber la cantidad y el importe promedio vendido por fecha y
--cliente, para códigos de vendedor superiores a 2. Ordene por fecha y cliente.
SELECT F.fecha,
F.cod_cliente 'Cod Cliente',
C.ape_cliente 'Apellido Cliente',
SUM(DF.cantidad) 'Cantidad',
SUM(DF.cantidad * DF.pre_unitario) / SUM(distinct F.nro_factura) 'Importe promedio'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE V.cod_vendedor > 2
GROUP BY F.fecha, F.cod_cliente, C.ape_cliente
ORDER BY 1, 2

--6. Se quiere saber el importe promedio vendido y la cantidad total vendida por
--fecha y artículo, para códigos de cliente inferior a 3. Ordene por fecha y artículo.
SELECT F.fecha,
A.cod_articulo,
A.descripcion,
SUM(DF.cantidad * DF.pre_unitario) / COUNT(distinct F.nro_factura) 'Importe promedio',
SUM(DF.cantidad ) 'Cantidad Total'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE C.cod_cliente < 3
GROUP BY F.fecha, A.cod_articulo, A.descripcion
ORDER BY F.fecha, A.cod_articulo
--7. Listar la cantidad total vendida, el importe total vendido y el importe
--promedio total vendido por número de factura, siempre que la fecha no oscile entre el 13/7/2007 y el 13/7/2010.
SELECT F.nro_factura 'Nro Factura',
SUM(DF.cantidad ) 'Cantidad Total',
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total',
SUM(DF.cantidad * DF.pre_unitario) / COUNT(distinct F.nro_factura) 'Importe promedio'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE F.fecha NOT BETWEEN '13/07/2007' AND '13/07/2010'
GROUP BY F.nro_factura
ORDER BY F.nro_factura, 2

--8. Emitir un reporte que muestre la fecha de la primer y última venta y el
--importe comprado por cliente. Rotule como CLIENTE, PRIMER VENTA, ÚLTIMA VENTA, IMPORTE.
SELECT 
C.ape_cliente + ' ' + C.nom_cliente 'CLIENTE',
MIN(F.fecha) 'PRIMER VENTA',
MAX(F.fecha) 'ULTIMA VENTA',
SUM(DF.cantidad * DF.pre_unitario) 'IMPORTE'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN clientes C ON C.cod_cliente = F.cod_cliente
GROUP BY C.cod_cliente, C.ape_cliente, C.nom_cliente

--9. Se quiere saber el importe total vendido, la cantidad total vendida y el precio
--unitario promedio por cliente y artículo, siempre que el nombre del cliente
--comience con letras que van de la “a” a la “m”. Ordene por cliente, precio
--unitario promedio en forma descendente y artículo. Rotule como IMPORTE
--TOTAL, CANTIDAD TOTAL, PRECIO PROMEDIO.
SELECT 
C.nom_cliente + ' ' + C.ape_cliente Cliente,
A.cod_articulo,
A.descripcion,
SUM(DF.cantidad ) 'Cantidad Total',
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total',
SUM(DF.pre_unitario) / COUNT(distinct F.nro_factura) 'Importe promedio'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE C.nom_cliente LIKE '[a-m]%'
GROUP BY C.cod_cliente, C.ape_cliente, C.nom_cliente,A.cod_articulo, A.descripcion
ORDER BY Cliente DESC, 'Importe promedio' DESC, A.cod_articulo

--10.Se quiere saber la cantidad de facturas y la fecha la primer y última factura
--por vendedor y cliente, para números de factura que oscilan entre 5 y 30.
--Ordene por vendedor, cantidad de ventas en forma descendente y cliente.
SELECT 
V.ape_vendedor 'Vendedor',
C.ape_cliente 'Cliente',
COUNT(distinct nro_factura) 'Cantidad de Facturas',
MIN(F.fecha) 'Primer Factura',
MAX(F.fecha) 'Ultima Factura'
FROM facturas F
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE F.nro_factura BETWEEN 5 AND 30
GROUP BY V.cod_vendedor, C.cod_cliente, V.ape_vendedor, C.ape_cliente
ORDER BY V.cod_vendedor, COUNT(distinct nro_factura) DESC, C.cod_cliente

--Problema 1.3: Consultas agrupadas: Cláusula HAVING
--1. Se necesita saber el importe total de cada factura, pero solo aquellas donde
--ese importe total sea superior a 2500.
SELECT F.nro_factura NroFactura,
SUM(DF.cantidad * DF.pre_unitario) 'Importe Total'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
GROUP BY F.nro_factura
HAVING SUM(DF.cantidad * DF.pre_unitario) > 2500
--2. Se desea un listado de vendedores y sus importes de ventas del año 2017
--pero solo aquellos que vendieron menos de $ 17.000.- en dicho año.
SELECT V.cod_vendedor Codigo,
V.ape_vendedor + ' ' + V.nom_vendedor 'Vendedor',
SUM(DF.cantidad * DF.pre_unitario) 'Importe'
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
WHERE YEAR(F.fecha) = 2017
GROUP BY V.cod_vendedor, V.ape_vendedor, V.nom_vendedor
HAVING SUM(DF.cantidad * DF.pre_unitario) < 17000
--3. Se quiere saber la fecha de la primera venta, la cantidad total vendida y el
--importe total vendido por vendedor para los casos en que el promedio de
--la cantidad vendida sea inferior o igual a 56.
SELECT MIN(F.fecha) 'Fecha Primer Venta',
SUM(DF.cantidad) 'Cantidad total',
SUM(DF.cantidad * DF.pre_unitario) 'Importe',
V.cod_vendedor CodigoVendedor, V.ape_vendedor + ' ' + V.nom_vendedor NombreVendedor
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
GROUP BY V.cod_vendedor, V.ape_vendedor, V.nom_vendedor
HAVING SUM(DF.cantidad) / COUNT(distinct F.nro_factura) <= 56

--4. Se necesita un listado que informe sobre el monto máximo, mínimo y total
--que gastó en esta librería cada cliente el año pasado, pero solo donde el
--importe total gastado por esos clientes esté entre 300 y 800.
SELECT 
C.cod_cliente CodCliente, C.ape_cliente + ' ' + C.nom_cliente Cliente,
MAX(DF.cantidad * DF.pre_unitario) MontoMaximo,
MIN(DF.cantidad * DF.pre_unitario) MontoMinimo,
SUM(DF.cantidad * DF.pre_unitario) MontoTotal
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE DATEDIFF(YEAR,F.fecha, GETDATE()) = 1
GROUP BY C.cod_cliente, C.ape_cliente, C.nom_cliente
HAVING SUM(DF.cantidad * DF.pre_unitario) BETWEEN 300 AND 800
--5. Muestre la cantidad facturas diarias por vendedor; para los casos en que
--esa cantidad sea 2 o más.
SELECT 
DAY(F.fecha),
V.cod_vendedor CodVendedor,
V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
COUNT(distinct F.nro_factura) CantFacturas
FROM facturas F
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
GROUP BY V.cod_vendedor, V.ape_vendedor, V.nom_vendedor, 
DAY(F.fecha)
HAVING COUNT(distinct F.nro_factura) >= 2

Select day(fecha)+'-'+ month(fecha)+'-'+year(fecha) día,
count(distinct nro_factura) 'Facturas vendidas',
upper(ape_vendedor)+ ',' + space(1) + nom_vendedor 'Vendedor'
from facturas f
join vendedores v on v.cod_vendedor = f.cod_vendedor
group by day(fecha)+'-'+month(fecha)+'-'+year(fecha),
v.ape_vendedor, v.nom_vendedor
having count(distinct nro_factura) >=2
--6. Desde la administración se solicita un reporte que muestre el precio
--promedio, el importe total y el promedio del importe vendido por artículo
--que no comiencen con “c”, que su cantidad total vendida sea 100 o más o
--que ese importe total vendido sea superior a 700.
SELECT
A.descripcion Articulo,
SUM(DF.pre_unitario) / COUNT(DISTINCT DF.pre_unitario) PrecioPromedio,
SUM(DF.cantidad * DF.pre_unitario) ImporteTotal,
SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) PromedioImporte
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE A.descripcion NOT LIKE 'C%'
GROUP BY A.descripcion
HAVING SUM(DF.cantidad) >= 100 OR SUM(DF.cantidad * DF.pre_unitario) > 700

Select ar.descripcion 'Articulo',
avg(df.pre_unitario) 'Precio Promedio',
sum(df.pre_unitario*df.cantidad) 'Importe total',
sum(df.pre_unitario*df.cantidad)/count(distinct df.nro_factura)
'Promedio Importe'
from detalle_facturas df
inner join articulos ar on ar.cod_articulo=df.cod_articulo
where ar.descripcion not like 'c%'
group by ar.descripcion
having sum(df.cantidad)>=100 or sum(df.pre_unitario*df.cantidad)>700
order by 1

--7. Muestre en un listado la cantidad total de artículos vendidos, el importe
--total y la fecha de la primer y última venta por cada cliente, para lo
--números de factura que no sean los siguientes: 2, 12, 20, 17, 30 y que el
--promedio de la cantidad vendida oscile entre 2 y 6.
SELECT
A.descripcion Articulo,
SUM(DF.cantidad * DF.pre_unitario) ImporteTotal,
MIN(F.fecha) PrimerVenta,
MAX(F.fecha) UltimaVenta,
SUM(DF.cantidad) / COUNT(DF.cantidad) PromedioCantidad,
C.ape_cliente + ' ' + C.nom_cliente Cliente
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE F.nro_factura NOT IN (2,12,20,17,30)
GROUP BY A.descripcion, C.cod_cliente, C.ape_cliente, C.nom_cliente
HAVING SUM(DF.cantidad) / COUNT(DF.cantidad) BETWEEN 2 AND 6


Select Concat(c.nom_cliente,' ', c.ape_cliente)'Cliente',
SUM(dF.pre_unitario*dF.cantidad) 'Importe total',
SUM(df.cantidad) 'Cantidad total' ,
max(F.fecha) 'Factura mas reciente',
min(F.fecha) 'Factura mas antigua'
From detalle_facturas Df
Join facturas F on Df.nro_factura=F.nro_factura
Join clientes C on f.cod_cliente=c.cod_cliente
Where F.nro_factura Not in (2,12,20,17,30)
Group by c.cod_cliente,C.nom_cliente,C.ape_cliente
Having Avg(df.cantidad) between 2 and 6

--8. Emitir un listado que muestre la cantidad total de artículos vendidos, el
--importe total vendido y el promedio del importe vendido por vendedor y
--por cliente; para los casos en que el importe total vendido esté entre 200
--y 600 y para códigos de cliente que oscilen entre 1 y 5.
SELECT
SUM(DF.cantidad) CantidadArticulos,
SUM(DF.cantidad * DF.pre_unitario) ImporteTotal,
SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) PromedioImporte,
V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
C.ape_cliente + ' ' + C.nom_cliente Cliente
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE C.cod_cliente BETWEEN 1 AND 5
GROUP BY V.cod_vendedor, V.ape_vendedor, V.nom_vendedor, C.cod_cliente, C.ape_cliente, C.nom_cliente
HAVING SUM(DF.cantidad * DF.pre_unitario) BETWEEN 200 AND 600 


Select v.ape_vendedor + ' ' + v.nom_vendedor 'Vendedor',
c.ape_cliente + ' ' + c.nom_cliente 'Cliente',
SUM(dF.pre_unitario*dF.cantidad) 'Importe total',
SUM(df.cantidad) 'Cantidad total' ,
avg(dF.pre_unitario*dF.cantidad) 'Promedio'
From detalle_facturas Df
join facturas F on Df.nro_factura=F.nro_factura
Join clientes C on f.cod_cliente=c.cod_cliente
join vendedores v ON f.cod_vendedor = v.cod_vendedor
Where c.cod_cliente between 1 and 5
group by v.cod_vendedor,v.ape_vendedor + ' ' + v.nom_vendedor,
c.cod_cliente, c.ape_cliente + ' ' + c.nom_cliente
Having SUM(dF.pre_unitario*dF.cantidad) between 200 and 600
--9. ¿Cuáles son los vendedores cuyo promedio de facturación el mes pasado supera los $ 800?
SELECT 
V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) PromedioFacturacion
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
WHERE DATEDIFF(MONTH, F.fecha, GETDATE()) = 1
GROUP BY V.cod_vendedor, V.ape_vendedor, V.nom_vendedor
HAVING SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) > 800

Select v.cod_vendedor, v.nom_vendedor 'Nombre',
v.ape_vendedor 'Apellido',
avg(pre_unitario*cantidad) 'Promedio'
from facturas f
join vendedores v on f.cod_vendedor=v.cod_vendedor
join detalle_facturas dt on f.nro_factura = dt.nro_factura
where datediff(month, f.fecha,getdate())=1
group by v.cod_vendedor, v.nom_vendedor, v.ape_vendedor
having avg(pre_unitario*cantidad) > 800
--10.¿Cuánto le vendió cada vendedor a cada cliente el año pasado siempre
--que la cantidad de facturas emitidas (por cada vendedor a cada cliente) sea menor a 5?
SELECT
V.ape_vendedor + ' ' + V.nom_vendedor Vendedor,
C.ape_cliente + ' ' + C.nom_cliente Cliente,
SUM(DF.cantidad * DF.pre_unitario) Importe
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 1
GROUP BY V.cod_vendedor, V.ape_vendedor, V.nom_vendedor, C.cod_cliente, C.ape_cliente, C.nom_cliente
HAVING COUNT(DISTINCT F.nro_factura) < 5

--Problema 1.4: Combinación de resultados de consultas. UNION
--1. Confeccionar un listado de los clientes y los vendedores indicando a qué grupo pertenece cada uno. 


SELECT cod_cliente, ape_cliente + ' ' + nom_cliente, 'Cliente' Tipo	
FROM clientes
UNION
SELECT cod_vendedor, ape_vendedor + ' ' + nom_vendedor, 'Vendedor'
FROM vendedores
ORDER BY 3,2

--2. Se quiere saber qué vendedores y clientes hay en la empresa; para los casos en
--que su teléfono y dirección de e-mail sean conocidos. Se deberá visualizar el
--código, nombre y si se trata de un cliente o de un vendedor. Ordene por la columna
--tercera y segunda.
SELECT cod_cliente, ape_cliente + ' ' + nom_cliente, 'Cliente' Tipo	
FROM clientes
WHERE nro_tel IS NOT NULL
AND [e-mail] IS NOT NULL
UNION
SELECT cod_vendedor, ape_vendedor + ' ' + nom_vendedor, 'Vendedor'
FROM vendedores
WHERE nro_tel IS NOT NULL
AND [e-mail] IS NOT NULL
ORDER BY 3,2

--3. Emitir un listado donde se muestren qué artículos, clientes y vendedores hay en
--la empresa. Determine los campos a mostrar y su ordenamiento.
SELECT cod_cliente, ape_cliente + ' ' + nom_cliente, 'Cliente' Tipo	
FROM clientes
UNION
SELECT cod_vendedor, ape_vendedor + ' ' + nom_vendedor, 'Vendedor'
FROM vendedores
UNION
SELECT cod_articulo, descripcion, 'Articulo'
FROM articulos
ORDER BY 3,2

--4. Se quiere saber las direcciones (incluido el barrio) tanto de clientes como de
--vendedores. Para el caso de los vendedores, códigos entre 3 y 12. En ambos casos
--las direcciones deberán ser conocidas. Rotule como NOMBRE, DIRECCION,
--BARRIO, INTEGRANTE (en donde indicará si es cliente o vendedor). Ordenado por
--la primera y la última columna.
SELECT ape_cliente + ' ' + nom_cliente Nombre, C.calle + ' ' + TRIM(STR(C.altura)) Direccion, B.barrio Barrio,'Cliente' Integrante	
FROM clientes C
JOIN barrios B ON C.cod_barrio = B.cod_barrio
WHERE  C.calle + ' ' + TRIM(STR(C.altura)) IS NOT NULL
UNION
SELECT ape_vendedor + ' ' + nom_vendedor, V.calle + ' '+ TRIM(STR(V.altura)) Direccion, B.barrio Barrio, 'Vendedor'
FROM vendedores V
JOIN barrios B ON V.cod_barrio = B.cod_barrio
WHERE V.calle + ' '+ TRIM(STR(V.altura)) IS NOT NULL
AND V.cod_vendedor BETWEEN 3 AND 12
ORDER BY 1, 4

--5. Ídem al ejercicio anterior, sólo que además del código, identifique de donde
--obtiene la información (de qué tabla se obtienen los datos).


--6. Listar todos los artículos que están a la venta cuyo precio unitario oscile entre 10
--y 50; también se quieren listar los artículos que fueron comprados por los clientes
--cuyos apellidos comiencen con “M” o con “P”.
SELECT A.cod_articulo Codigo, A.descripcion Nombre, A.pre_unitario PrecioUnitario
FROM articulos A
WHERE A.pre_unitario BETWEEN 10 AND 50
UNION
SELECT A.cod_articulo Codigo, A.descripcion Nombre, A.pre_unitario PrecioUnitario
FROM articulos A
JOIN detalle_facturas DF ON A.cod_articulo = DF.cod_articulo
JOIN facturas F ON F.nro_factura = DF.nro_factura
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE C.ape_cliente LIKE '[M,P]%'

--7. El encargado del negocio quiere saber cuánto fue la facturación del año pasado.
--Por otro lado, cuánto es la facturación del mes pasado, la de este mes y la de hoy
--(Cada pedido en una consulta distinta, y puede unirla en una sola tabla de resultado)
SELECT SUM(DF.cantidad * DF.pre_unitario) Facturacion, 'Año Pasado' Tipo
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 1
UNION
SELECT SUM(DF.cantidad * DF.pre_unitario) Facturacion, 'Mes Pasado' Tipo
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE DATEDIFF(MONTH, F.fecha, GETDATE()) = 1
UNION
SELECT SUM(DF.cantidad * DF.pre_unitario) Facturacion, 'Este Mes' Tipo
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE DATEDIFF(MONTH, F.fecha, GETDATE()) = 0
UNION
SELECT SUM(DF.cantidad * DF.pre_unitario) Facturacion, 'Hoy' Tipo
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE DATEDIFF(DAY, F.fecha, GETDATE()) = 0