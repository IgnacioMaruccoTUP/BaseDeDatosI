--TEMA 2
--1. Listar los productos que hayan tenido m�s de 10 �rdenes de fabricaci�n el mes pasado.
SELECT P.id_producto CodigoProducto, P.descripcion Producto  
FROM productos P 
WHERE 10 <
(SELECT COUNT(O.id_orden)
FROM Ordenes O
WHERE DATEDIFF(MONTH, O.fecha_fab, GETDATE()) = 1
AND O.id_producto = P.id_producto
)


--2. En una misma tabla de resultados se quiere mostrar la cantidad de �rdenes de producci�n
--que se ejecutaron, la mayor cantidad producida y el costo total de las �rdenes correspondiente
--al mes en curso en primer lugar y las del a�o en curso en 2do lugar 
SELECT COUNT(O.id_orden) CantidadOrdenes, MAX(O.cantidad) MayorCantidadProducida, SUM(O.costo_total) CostoTotal, 'Mes Actual' Periodo
FROM Ordenes O
WHERE DATEDIFF(MONTH, O.fecha_fab, GETDATE()) = 0
UNION
SELECT COUNT(O.id_orden) CantidadOrdenes, MAX(O.cantidad) MayorCantidadProducida, SUM(O.costo_total) CostoTotal, 'A�o Actual'
FROM Ordenes O
WHERE DATEDIFF(YEAR, O.fecha_fab, GETDATE()) = 0

--3. Emitir un listado que muestre, por mes y por producto, los costos totales, cantidad de �rdenes
--de producci�n, el promedio de las cantidades producidas, siempre que el tipo de producto
--comience con letras que van de a �P� a la �S� y que la m�xima cantidad producida (por mes
--y por producto) haya sido menor a 800
SELECT YEAR(O.fecha_fab) Anio, MONTH(O.fecha_fab) Mes, P.descripcion Producto, SUM(O.costo_total) CostoTotal, COUNT(O.id_orden) CantidadOrdenes,
AVG(O.cantidad) PromedioCantidad
FROM Ordenes O JOIN Productos P ON P.id_producto = O.id_producto JOIN Tipos T ON T.id_tipo = P.id_tipo
WHERE T.tipo LIKE '[P-S]%'
GROUP BY P.id_producto, P.descripcion, YEAR(O.fecha_fab), MONTH(O.fecha_fab)
HAVING 800 > MAX(O.cantidad)
--4. Se quiere saber cu�nto es el costo total y la cantidad total de unidades producidas por secci�n
--y por turno en el mes en curso siempre que el promedio de esas cantidades (por secci�n y
--por turno) sea menor al promedio de las cantidades de esa secci�n en todas las �rdenes de
--la base de datos.
SELECT S.id_seccion CodigoSeccion, S.seccion Seccion, T.id_turno CodigoTurno, T.turno Turno, SUM(O.costo_total) CostoTotal, SUM(O.cantidad) CantidadTotalUnidades 
FROM Ordenes O JOIN Secciones S ON S.id_seccion = O.id_seccion JOIN Turnos T ON T.id_turno = O.id_turno
WHERE DATEDIFF(MONTH, O.fecha_fab, GETDATE()) = 0
GROUP BY S.id_seccion, S.seccion, T.id_turno, T.turno
HAVING AVG(O.cantidad) < 
(SELECT AVG(O2.cantidad)
FROM Ordenes O2 
WHERE S.id_seccion = O2.id_seccion
)
--5. Crear una vista que muestre el costo mensual promedio (promedio ponderado) de cada
--unidad de producto en los �ltimos 12 meses sin contar el actual.
--Consulte la vista anterior y muestre el margen de ganancia de cada producto respecto a los
--costos unitarios del mes pasado y el precio de venta de cada producto
CREATE VIEW EJ_5
AS
SELECT YEAR(O.fecha_fab) Anio, MONTH(O.fecha_fab) Mes, P.id_producto CodigoProducto, P.descripcion Producto,SUM(O.costo_total) / SUM(O.cantidad) CostoMensualPromedio 
FROM Ordenes O JOIN Productos P ON O.id_producto = P.id_producto
WHERE DATEDIFF(MONTH,O.fecha_fab,GETDATE()) BETWEEN 1 AND 12
GROUP BY YEAR(O.fecha_fab), MONTH(O.fecha_fab), P.id_producto, P.descripcion

SELECT E5.CodigoProducto, E5.Producto, P.precio_venta - E5.CostoMensualPromedio MargenGanancia 
FROM EJ_5 E5 JOIN Productos P ON P.id_producto = E5.id_producto JOIN Ordenes O ON O.id_producto = P.id_producto
WHERE DATEDIFF(MONTH, O.fecha_fab, GETDATE()) = 1
