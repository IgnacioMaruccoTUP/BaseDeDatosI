USE Libreria
GO
SET DATEFORMAT DMY
--SUBCONSULTAS:
----COMPARACION
--Listado de articulos cuyos precios son menores al promedio
SELECT cod_articulo, descripcion, pre_unitario
FROM articulos
WHERE pre_unitario < 
(SELECT avg(pre_unitario)
FROM articulos)

----PERTENENCIA AL CONJUNTO
--Listado de clientes que compraron este año
SELECT cod_cliente, ape_cliente, nom_cliente
FROM clientes
WHERE cod_cliente IN
(SELECT cod_cliente
FROM facturas F 
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 0)

--Listado de clientes que NO compraron el año pasado
SELECT cod_cliente, ape_cliente, nom_cliente
FROM clientes
WHERE cod_cliente NOT IN
(SELECT cod_cliente
FROM facturas F 
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 1)

----EXISTS
--Listar los datos de los clientes que compraron este año
SELECT C.cod_cliente, C.ape_cliente, C.nom_cliente
FROM clientes C
WHERE EXISTS
(SELECT cod_cliente
FROM facturas F 
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 0
AND C.cod_cliente = F.cod_cliente)

--Listar los datos de los clientes que NO compraron el año pasado
SELECT C.cod_cliente, C.ape_cliente, C.nom_cliente
FROM clientes C
WHERE NOT EXISTS
(SELECT cod_cliente
FROM facturas F 
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 1
AND C.cod_cliente = F.cod_cliente)

----ANY
--Listar los clientes que alguna vez compraron un producto menor a $10
SELECT C.ape_cliente, C.nom_cliente
FROM clientes C
JOIN facturas F ON F.cod_cliente = C.cod_cliente
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE 10 > ANY 
(SELECT DF.pre_unitario
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE C.cod_cliente = F.cod_cliente)

--Listar los clientes que siempre fueron atendidos por el vendedor 3
SELECT C.ape_cliente, C.nom_cliente
FROM clientes C
WHERE 3 = ALL
(SELECT cod_vendedor
FROM facturas F
WHERE C.cod_cliente = F.cod_cliente)

--Listar los clientes que compraron algun producto menor a $10
SELECT C.cod_cliente, C.ape_cliente, C.nom_cliente
FROM clientes C
WHERE 10 > ANY 
(SELECT DF2.pre_unitario
FROM detalle_facturas DF2 
JOIN facturas F2 ON F2.nro_factura = DF2.nro_factura
WHERE F2.cod_cliente = C.cod_cliente)

--Problema 2.1: Subconsultas en el Where
--1. Se solicita un listado de artículos cuyo precio es inferior al promedio de
--precios de todos los artículos. (está resuelto en el material teórico)
SELECT A.descripcion, A.pre_unitario
FROM articulos A
WHERE A.pre_unitario < 
(SELECT AVG(pre_unitario)
FROM articulos
)
--2. Emitir un listado de los artículos que no fueron vendidos este año. En
--ese listado solo incluir aquellos cuyo precio unitario del artículo oscile
--entre 50 y 100.
SELECT A.descripcion, A.pre_unitario
FROM articulos A
WHERE A.cod_articulo NOT IN
(SELECT A2.cod_articulo
FROM articulos A2
JOIN detalle_facturas DF2 ON DF2.cod_articulo = A2.cod_articulo
JOIN facturas F2 ON F2.nro_factura = DF2.nro_factura
WHERE DATEDIFF(YEAR, F2.fecha, GETDATE()) = 0
)
AND A.pre_unitario BETWEEN 50 AND 100
--3. Genere un reporte con los clientes que vinieron más de 2 veces el año
--pasado.
SELECT C.cod_cliente, C.ape_cliente
FROM clientes C
WHERE 2 <
(SELECT COUNT(*)
FROM facturas F2
WHERE C.cod_cliente = F2.cod_cliente
)
--4. Se quiere saber qué clientes no vinieron entre el 12/12/2015 y el 13/7/2020

SELECT C.cod_cliente, C.ape_cliente, C.nom_cliente
FROM clientes C
WHERE C.cod_cliente NOT IN
(SELECT F2.cod_cliente
FROM facturas F2
WHERE F2.fecha BETWEEN '12/12/2015' AND '13/07/2020'
)

--5. Listar los datos de las facturas de los clientes que solo vienen a comprar
--en febrero es decir que todas las veces que vienen a comprar haya sido en el mes de febrero (y no otro mes).
SELECT F.nro_factura, F.fecha, F.cod_cliente, F.cod_vendedor
FROM facturas F
WHERE 2 = ALL
(SELECT MONTH(F2.fecha)
FROM facturas F2
WHERE F2.cod_cliente = F.cod_cliente)

--6. Mostrar los datos de las facturas para los casos en que por año se hayan hecho menos de 9 facturas. 
SELECT F.nro_factura, F.fecha, C.nom_cliente + ' ' + C.ape_cliente Cliente,
V.nom_vendedor + ' ' + V.ape_vendedor Vendedor
FROM facturas F
JOIN clientes C ON C.cod_cliente = F.cod_cliente
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
WHERE 9 > 
(SELECT COUNT(*)
FROM facturas F2
WHERE YEAR(F2.fecha) = YEAR(F.fecha)
)

--7. Emitir un reporte con las facturas cuyo importe total haya sido superior a
--1.500 (incluir en el reporte los datos de los artículos vendidos y los importes).
SELECT F.nro_factura, A.descripcion, DF.cantidad * DF.pre_unitario Importe
FROM facturas F
JOIN clientes C ON C.cod_cliente = F.cod_cliente
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE 1500 <
(SELECT SUM(DF2.cantidad * DF2.pre_unitario)
FROM detalle_facturas DF2
WHERE DF2.nro_factura = F.nro_factura)
--8. Se quiere saber qué vendedores nunca atendieron a estos clientes: 1 y 6. Muestre solamente el nombre del vendedor.
SELECT V.nom_vendedor, V.ape_vendedor
FROM vendedores V
WHERE V.cod_vendedor NOT IN
(SELECT V2.cod_vendedor
FROM vendedores V2
JOIN facturas F2 ON F2.cod_vendedor = V2.cod_vendedor
JOIN clientes C2 ON C2.cod_cliente = F2.cod_cliente
WHERE C2.cod_cliente IN (1,6))

--9. Listar los datos de los artículos que superaron el promedio del Importe de ventas de $ 1.000.
SELECT A.cod_articulo, A.descripcion, A.pre_unitario
FROM articulos A
WHERE 1000 < 
(SELECT SUM(DF2.cantidad * DF2.pre_unitario) / COUNT(DISTINCT F2.nro_factura)
FROM facturas F2
JOIN detalle_facturas DF2 ON DF2.nro_factura = F2.nro_factura
WHERE DF2.cod_articulo = A.cod_articulo)
--10. ¿Qué artículos nunca se vendieron? Tenga además en cuenta que su
--nombre comience con letras que van de la “d” a la “p”. Muestre solamente la descripción del artículo.
SELECT A.descripcion
FROM articulos A
WHERE A.descripcion LIKE '[D-P]%'
AND A.cod_articulo NOT IN 
(SELECT A2.cod_articulo
FROM detalle_facturas DF2
JOIN articulos A2 ON A2.cod_articulo = DF2.cod_articulo
)
--11. Listar número de factura, fecha y cliente para los casos en que ese
--cliente haya sido atendido alguna vez por el vendedor de código 3.
SELECT F.nro_factura NroFactura, F.fecha Fecha, C.ape_cliente + ' ' + C.nom_cliente Cliente, V.cod_vendedor CodVendedor
FROM facturas F
JOIN clientes C ON C.cod_cliente = F.cod_cliente
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
WHERE 3 = ANY
(SELECT F2.cod_vendedor
FROM facturas F2
WHERE F.cod_cliente = F2.cod_cliente
)

--12. Listar número de factura, fecha, artículo, cantidad e importe para los
--casos en que todas las cantidades (de unidades vendidas de cada artículo) de esa factura sean superiores a 40.
SELECT F.nro_factura NroFactura, F.fecha Fecha, A.descripcion Articulo, DF.cantidad Cantidad, DF.cantidad * DF.pre_unitario Importe
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE 40 < ALL 
(SELECT DF2.cantidad
FROM facturas F2
JOIN detalle_facturas DF2 ON F2.nro_factura = DF2.nro_factura
WHERE F.nro_factura = F2.nro_factura
)

--13. Emitir un listado que muestre número de factura, fecha, artículo,
--cantidad e importe; para los casos en que la cantidad total de unidades vendidas sean superior a 80.
SELECT F.nro_factura NroFactura, F.fecha Fecha, A.descripcion Articulo, DF.cantidad Cantidad, DF.cantidad * DF.pre_unitario Importe
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE 80 <
(SELECT SUM(DF2.cantidad)
FROM detalle_facturas DF2
WHERE F.nro_factura = DF2.nro_factura
)

--14. Realizar un listado de número de factura, fecha, cliente, artículo e
--importe para los casos en que al menos uno de los importes de esa factura sea menor a 3.000.
SELECT F.nro_factura NroFactura, F.fecha Fecha, A.descripcion Articulo, DF.cantidad * DF.pre_unitario Importe
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE 3000 > ANY
(SELECT DF2.cantidad * DF2.pre_unitario
FROM facturas F2
JOIN detalle_facturas DF2 ON DF2.nro_factura = F2.nro_factura
WHERE F.nro_factura = F2.nro_factura
)
--Subconsultas en el Having
--Listar los vendedores cuyo promedio de ventas del año sea menor al mismo dato del año pasado
SELECT V.cod_vendedor, V.ape_vendedor, SUM(DF.cantidad * DF.pre_unitario) / COUNT (DISTINCT F.nro_factura) PromedioVentas
FROM vendedores V
JOIN facturas F ON F.cod_vendedor = V.cod_vendedor
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
WHERE DATEDIFF(YEAR, F.fecha, GETDATE()) = 0
GROUP BY V.cod_vendedor, V.ape_vendedor
HAVING SUM(DF.cantidad * DF.pre_unitario) / COUNT (DISTINCT F.nro_factura) <
(SELECT SUM(DF2.cantidad * DF2.pre_unitario) / COUNT (DISTINCT F2.nro_factura)
FROM vendedores V2
JOIN facturas F2 ON F2.cod_vendedor = V2.cod_vendedor
JOIN detalle_facturas DF2 ON DF2.nro_factura = F2.nro_factura
WHERE DATEDIFF(YEAR, F2.fecha, GETDATE()) = 1
AND V.cod_vendedor = V2.cod_vendedor
)


--Problema 2.2: Subconsultas en el Having
--1. Se quiere saber ¿cuándo realizó su primer venta cada vendedor? y ¿cuánto fue el importe total de las ventas que ha realizado? Mostrar estos 
--datos en un listado solo para los casos en que su importe promedio de vendido sea superior al importe promedio general (importe promedio de
--todas las facturas).
SELECT V.ape_vendedor + ' ' + V.nom_vendedor Vendedor, MIN(F.fecha) PrimerVenta, SUM(DF.cantidad * DF.pre_unitario) ImporteTotal
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN vendedores V ON V.cod_vendedor = F.cod_vendedor
GROUP BY F.cod_vendedor, V.ape_vendedor + ' ' + V.nom_vendedor
HAVING SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) >
(SELECT SUM(DF2.cantidad * DF2.pre_unitario) / COUNT(DISTINCT F2.nro_factura)
FROM facturas F2
JOIN detalle_facturas DF2 ON DF2.nro_factura = F2.nro_factura
)
--2. Liste los montos totales mensuales facturados por cliente y además del promedio de ese monto y el promedio de precio de artículos Todos esto
--datos correspondientes a período que va desde el 1° de febrero al 30 de agosto del 2014. Sólo muestre los datos si esos montos totales son
--superiores o iguales al promedio global.

--??????????????????????????????
SELECT YEAR(F.fecha) 'Año', MONTH(F.fecha) 'Mes', C.ape_cliente + ' ' + C.nom_cliente Cliente, SUM(DF.cantidad * DF.pre_unitario) MontoTotal,
SUM(DF.cantidad * DF.pre_unitario) / COUNT (DISTINCT F.nro_factura) PromedioMontos, AVG(DF.pre_unitario) PromedioPrecioArticulo
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN clientes C ON C.cod_cliente = F.cod_cliente
WHERE F.fecha BETWEEN '01/02/2014' AND '30/07/2014'
GROUP BY MONTH(F.fecha),YEAR(F.fecha), C.cod_cliente, C.ape_cliente + ' ' + C.nom_cliente
HAVING SUM(DF.cantidad * DF.pre_unitario) >=
(SELECT SUM(DF2.cantidad * DF2.pre_unitario) / COUNT(DISTINCT F2.nro_factura)
FROM facturas F2
JOIN detalle_facturas DF2 ON DF2.nro_factura = F2.nro_factura
)
ORDER BY 1, 2
--3. Por cada artículo que se tiene a la venta, se quiere saber el importe promedio vendido, la cantidad total vendida por artículo, para los casos
--en que los números de factura no sean uno de los siguientes: 2, 10, 7, 13, 22 y que ese importe promedio sea inferior al importe promedio de ese
--artículo.
SELECT A.cod_articulo, A.descripcion, 
SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) ImportePromedioVendido,
SUM(DF.cantidad) CantidadTotal
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE F.nro_factura NOT IN (2,10,7,13,22)
GROUP BY A.cod_articulo, A.descripcion
HAVING SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT DF.nro_factura) < 
(SELECT SUM(DF2.cantidad * DF2.pre_unitario) / COUNT(DISTINCT DF2.nro_factura)
FROM facturas F2
JOIN detalle_facturas DF2 ON DF2.nro_factura = F2.nro_factura
WHERE DF2.cod_articulo = A.cod_articulo
)
ORDER BY 1
--------------------------------?????????????????????????
SELECT A.cod_articulo, A.descripcion, 
SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) ImportePromedioVendido,
SUM(DF.cantidad) CantidadTotal
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
JOIN articulos A ON A.cod_articulo = DF.cod_articulo
WHERE F.nro_factura NOT IN (2,10,7,13,22)
GROUP BY A.cod_articulo, A.descripcion
HAVING SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT DF.nro_factura) < 
(SELECT SUM(DF2.cantidad * DF2.pre_unitario) / COUNT(DISTINCT DF2.nro_factura)
FROM detalle_facturas DF2
WHERE DF2.cod_articulo = A.cod_articulo
)
ORDER BY 1
--------------------------------------------------------Guia
select a.cod_articulo,sum(cantidad*d.pre_unitario)/count(distinct d.nro_factura)
promedio,
sum(cantidad) 'cant. total'
from facturas f join detalle_facturas d on f.nro_factura=d.nro_factura
join articulos a on a.cod_articulo=d.cod_articulo
where f.nro_factura not In (2, 10, 7, 13,22)
group by a.cod_articulo
having sum(cantidad*d.pre_unitario)/count(distinct d.nro_factura)<
(select sum(cantidad*pre_unitario)/count(distinct d.nro_factura)
from detalle_facturas d1
where d1.cod_articulo=a.cod_articulo)ORDER BY 1

--4. Listar la cantidad total vendida, el importe y promedio vendido por fecha,
--siempre que esa cantidad sea superior al promedio de la cantidad global. Rotule y ordene.
SELECT F.fecha Fecha,
SUM(DF.cantidad) CantidadTotalVendida,
SUM(DF.cantidad * DF.pre_unitario) Importe,
SUM(DF.cantidad * DF.pre_unitario) / COUNT(DISTINCT F.nro_factura) Promedio
FROM facturas F
JOIN detalle_facturas DF ON DF.nro_factura = F.nro_factura
GROUP BY F.fecha
HAVING SUM(DF.cantidad) >
(SELECT AVG(DF2.cantidad) 
FROM detalle_facturas DF2
)
ORDER BY 1

--5. Se quiere saber el promedio del importe vendido y la fecha de la primer
--venta por fecha y artículo para los casos en que las cantidades vendidas
--oscilen entre 5 y 20 y que ese importe sea superior al importe promedio
--de ese artículo.
--6. Emita un listado con los montos diarios facturados que sean inferior al
--importe promedio general.
--7. Se quiere saber la fecha de la primera y última venta, el importe total
--facturado por cliente para los años que oscilen entre el 2010 y 2015 y que
--el importe promedio facturado sea menor que el importe promedio total
--para ese cliente.
--8. Realice un informe que muestre cuánto fue el total anual facturado por
--cada vendedor, para los casos en que el nombre de vendedor no comience
--con ‘B’ ni con ‘M’, que los números de facturas oscilen entre 5 y 25 y que
--el promedio del monto facturado sea inferior al promedio de ese año. 