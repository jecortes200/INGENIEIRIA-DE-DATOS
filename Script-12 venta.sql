create database ventas;

use ventas;

-- eliminacion de tablas antes de crearlas
-- drop table if exists detalle_ventas;

drop table if exists detalle_ventas;
drop table if exists productos;
drop table if exists categorias;
drop table if exists resumen_ventas_diarias;

create table categorias(
categoriaId int primary key,
nombreCategoria varchar(50) not null,
estadoCategoria varchar(20) default 'ACTIVO'
); 

create table productos(
ProductoId int primary key,
nombreproducto varchar(100) not null,
precioProducto decimal(10,2) not null,
stock int default 0,
categoriaIdFK int,
fechaCreacion Date,
constraint fkprodcat foreign key (categoriaIdFK) references categorias(categoriaId)
);

create table detalle_ventas(
ventaId int primary key auto_increment,
ProductoIdFK int,
cantidad int not null,
precioUnitario decimal(10,2) not null,
total decimal (10,2) generated always as (cantidad*precioUnitario) stored,
fechaVenta datetime default CURRENT_TIMESTAMP(),
constraint fkdetprod foreign key (ProductoIdFK) references productos(ProductoId)
);

create table resumen_ventas_diarias (
fechaResumen date primary key,
totalRecaudado decimal(10,2),
itemsVendidos int
);

-- indices es una estructura de datos que agiliza las consultas
-- simpl: crea una sola columna
-- Compuesto: crea sobre multiples columnas funciona de izq a derecha.
-- costo: los que aceleran drásticamente las consultas pero generan penalización de escritura 
-- (insert update delete)

-- crear indices

create index idxProductoCategoria on productos(categoriaIdFK);
create index idxProductoPrecio on productos(precioProducto);
create index idxProductoCategoriaPrecio on productos(categoriaIdFK,precioProducto);

-- Sentencia Insert (registro o inserción de datos)

-- Inserción unitaria
-- Sintaxis insert into nombreTabla(campo1,campo2,campo3,...,Campon) values (val1,val2,val3,...,valn);

insert into categorias (categoriaId,nombreCategoria,estadoCategoria) values
(1,'Electronica','ACTIVO');

-- CONSULTA GENERAL 
-- SINTAXIS SELECT * FROM NOMBRETABLA

select * from categorias;

-- inserciones múltiples
-- Sintaxis insert into nombreTabla(campo1,campo2,campo3,...,Campon) values (val1,val2,val3,...,valn),
-- (val1,val2,val3,...,valn), (val1,val2,val3,...,valn);
insert into categorias (categoriaId,nombreCategoria,estadoCategoria) values
(2,'Laptops','ACTIVO'),(3,'Peroféricos','INACTIVO'),(4,'Accesorios','ACTIVO');

-- 1.3 Inserción con valores por defecto y omitiendo columnas con autoincremento/default
INSERT INTO productos (productoId, nombreproducto, precioProducto, stock, categoriaIdFK, fechaCreacion) VALUES
(107, 'Teclado Mecánico RGB', 85.50, 50, 3, '2025-01-10'),
(108, 'Mouse Inalámbrico Pro', 25.00, 100, 3, '2025-01-15'),
(109, 'Monitor Gamer 4K 27"', 350.00, 15, 1, '2025-02-01'),
(110, 'Laptop Pro 15"', 1200.00, 5, 2, '2025-02-10'),
(111, 'Teclado Membrana USB', 15.00, 200, 3, '2025-02-12'),
(112, 'Hub USB-C 8 en 1', 45.00, 0, 4, '2025-02-15');

INSERT INTO detalle_ventas (ProductoIdFK, cantidad, precioUnitario, fechaVenta) VALUES
(107, 2, 85.50, '2025-02-20 10:30:00'),
(109, 1, 350.00, '2025-02-20 11:15:00'),
(108, 4, 25.00, '2025-02-21 09:00:00'),
(107, 1, 85.50, '2025-02-21 14:20:00');

-- 1.4 INSERT INTO ... SELECT (Copia de datos entre tablas)
INSERT INTO resumen_ventas_diarias (fechaResumen, totalRecaudado, itemsVendidos)
SELECT 
    DATE(fechaVenta) AS fecha,
    SUM(total) AS total_recaudado,
    SUM(cantidad) AS items_vendidos
FROM detalle_ventas
GROUP BY DATE(fechaVenta);

-- sentencia select
-- gral select camposaconsultar from nombreTabla

select * from detalle_ventas;
select ventaId, ProductoIdFK from detalle_ventas;

-- consulta con alias select camposaconsultar as 'nombre alias' from nombreTabla

select ventaId as codigoVenta, ProductoIdFK as codigoProducto from detalle_ventas;

-- consultas con ordenamientos select camposa consultar from nombreTabla order by campoaOrdenar ASC DESC

select * from categorias order by nombreCategoria asc;
select * from categorias order by nombreCategoria desc;

-- consultas con clausula whee con condiciones select campoaconsultar from nombreTabla where condicion < > = <= <= <>

select * from categorias where estadoCategoria='INACTIVO';
select * from categorias where estadoCategoria<>'INACTIVO';
select * from categorias where categoriaId<=3;
select * from categorias where categoriaId>=3;
select * from categorias where categoriaId<3;
select * from categorias where categoriaId>3;

-- comparadores lógicos and (y) or (ó) negacion not

select * from categorias where estadoCategoria='INACTIVO' and categoriaId<=3;

select * from categorias where estadoCategoria='INACTIVO' or categoriaId<=3;

select * from categorias where not estadoCategoria='INACTIVO';


select * from categorias ca where ca.nombreCategoria='Electrónica' or nombreCategoria='Laptops';

-- consulta de indice
show index from categorias
describe productos

select distinct precioProducto from information_schema.STATISTICS s where s.TABLE_SCHEMA= 'ventas' and s.TABLE_NAME= 'productos' ;

select * from productos force index idxProductoCategoriaPrecio where categoriaId=3;

-- select between in is null is not null
select * from productos;
select productoId as codigo, nombreProducto, precioProducto, stock from productos
where precioProducto between  20 and 100
and categoriaIdFK in (1,3)
and stock is not null;


-- expresiones condicionales case when coalesce
select nombreProducto, precioProducto,
coalesce (fechaCreacion, '2000-01-01') as fechaRegistrada,
case
		when precioProducto < 50 then 'Económico'
		when precioProducto between 50 and 300 then 'Gama Media'
		else 'Gama Alta'
end as segmento_Precio
from productos;

-- consultaas de coincidencia patron like
-- LIKE % cero o n caracteres '_' exactamente 1 caracter xxxx% inicia %xxxx final %xxx% contenga

select * from productos where nombreProducto like 't%';
select * from productos where nombreProducto like '%1';
select * from productos where nombreProducto like '%p%';

-- expresiones regulares
select * from productos where nombreProducto regexp '^(Teclado|Mouse)';
select * from productos where nombreProducto regexp '[0,9]+"';

-- limit offset

select * from categorias order by nombreCategoria asc
limit 3 offset 0;

-- funciones calculadas

select ventaId, cantidad, precioUnitario, (precioUnitario*cantidad) as total from detalle_ventas dv;

select ProductoId, nombreproducto, max(precioProducto) from productos
select ProductoId, nombreproducto, min(precioProducto) from productos group by ProductoId

select COUNT(nombreproducto) as cantidadProducto from productos

select ProductoId, nombreproducto, avg(precioProducto) as precioPromedio from productos
select sum(stock) as totalStock from productos

select categoriaIdFK, count(*) as totalproductos from productos p 
group by categoriaIdFK


select categoriaIdFK, 
round(AVG(precioProducto)) as preciopromedio, 
min(precioProducto) as masbarato, 
MAX(precioProducto) as mascaro 
from productos p 
group by categoriaIdFK;

select categoriaIdFK, count(*) as totalproductos 
from productos p 
group by categoriaIdFK
having COUNT(*)>3;


/** actualizacion o modificacion
update nombre tabla  set nombre coluna  = valor, nombrecolumna2=valor,.... where condicion alter **//

select * from productos;

update productos set stock=stock+10 where ProductoId=10;
/*upsert*/


/*deleate --> elimina todos los registros que tenga la tabla 
 * deleate from .. nombre de la tabla  .. where ... condicoin*/

select* from detalle_ventas;

delete from detalle_ventas where cantidad=0;