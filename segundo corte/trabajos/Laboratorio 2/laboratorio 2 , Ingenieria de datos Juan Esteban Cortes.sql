create database TrazaCafe;

use TrazaCafe;


create table Certificacion (
    IdCertificacion int primary key,
    NombreCertificacion varchar(50) not null
);

create table FincaCaficultor (
    IdFinca int primary key,
    NombreCaficultor varchar(100) not null,
    Departamento varchar(50) not null,
    Altitud int not null
);

create table Cliente (
    IdCliente int primary key,
    NombreCliente varchar(100) not null,
    Ciudad varchar(50) not null
);

create table LoteCafeCosecha (
    IdLote int primary key,
    IdFincaFK int not null,
    NombreLote varchar(100) not null,
    CodigoLote varchar(20) unique not null,
    TipoVariedad varchar(50) not null,
    Proceso varchar(20) not null,
    constraint loteFincaFK foreign key (idfincafk) 
        references fincacaficultor(idfinca)
);

create table Catacion (
    IdCatacion int primary key,
    IdLoteFK int not null,
    Puntaje decimal(4,2) not null, 
    FechaCatacion date not null,
    constraint catacionLoteFK foreign key (idlotefk) 
        references lotecafecosecha(idlote)
);

create table Tostion (
    IdTostion int primary key,
    IdLoteFK int not null,
    FechaTostion date not null,
    KiloEntrada decimal(10,2) not null,  
    KiloSalida decimal(10,2) not null,
    constraint tostionLoteFK foreign key (idlotefk) 
        references lotecafecosecha(idlote)
);

create table Pedido (
    IdPedido int primary key,
    IdClienteFK int not null,
    IdTostionFK int not null,
    FechaPedido date not null,
    CantidaKilo decimal(10,2) not null,
    Precio decimal(10,2) not null,
    constraint pedidoClienteFK foreign key (idclientefk) 
        references cliente(idcliente),
    constraint pedidoTostionFK foreign key (idtostionfk) 
        references tostion(idtostion)
);
/* Refelxion  2:Si intento crear LoteCafeCosecha antes que FincaCaficultor, el motor de base de datos me mandara
un error de clave foránea. Esto pasa porque la tabla hija necesita hacer referencia a una tabla padre (fincacaficultor) 
que todavía no existe en el esquema*/
        
/*RETO 3*/
        
/*Restricción de Altitud en Finca*/
alter table FincaCaficultor 
add constraint validaAltitud check (Altitud between 800 and 2500);

/*Restricción de Puntaje SCA en Catación*/
alter table Catacion 
add constraint validaPuntaje check (Puntaje >= 0 and Puntaje <= 100);

/*Restricción de Kilos en Tostión*/
alter table Tostion 
add constraint validaKilos check (KiloSalida <= KiloEntrada);

/*el estado del pedido*/
/* Columna de estado para el pedido */
alter table pedido 
add column estado varchar(20) not null default 'pendiente';


alter table fincacaficultor 
add column idcertificacionfk int not null;

alter table fincacaficultor 
add constraint fincacerificacionfk foreign key (idcertificacionfk) 
references certificacion(idcertificacion) on delete restrict;

alter table fincacaficultor 
add constraint fkfincacertificacion foreign key (idcertificacionfk) 
references certificacion(idcertificacion) on delete restrict;


alter table LoteCafeCosecha 
drop foreign key loteFincaFK; 

alter table LoteCafeCosecha 
add constraint loteFincaFK foreign key (IdFincaFK) 
references FincaCaficultor(IdFinca) on delete restrict;
/*  Si intentan borrar una finca con lotes, el sistema lo bloquea para no perder trazabilidad. */



alter table Catacion 
drop foreign key catacionLoteFK; 

alter table Catacion 
add constraint catacionLoteFK foreign key (IdLoteFK) 
references LoteCafeCosecha(IdLote) on delete restrict;
/* Protege el historial de catación del lote. */


alter table Tostion 
drop foreign key tostionLoteFK; 

alter table Tostion 
add constraint tostionLoteFK foreign key (IdLoteFK) 
references LoteCafeCosecha(IdLote) on delete restrict;
/* Impide borrar lotes que ya pasaron por proceso de tostión. */



alter table Pedido 
drop foreign key pedidoClienteFK; 

alter table Pedido 
add constraint pedidoClienteFK foreign key (IdClienteFK) 
references Cliente(IdCliente) on delete restrict;
/* Un cliente con pedidos históricos no se puede borrar de la base de datos. */



alter table Pedido 
drop foreign key pedidoTostionFK;

alter table Pedido 
add constraint pedidoTostionFK foreign key (IdTostionFK) 
references Tostion(IdTostion) on delete restrict;
/*  Mantiene la integridad de las bolsas tostadas vendidas en los pedidos. */

/* prueba de fuego */

insert into fincacaficultor (idfinca, nombrecaficultor, departamento, altitud) 
values (91, 'Finca Prueba', 'Antioquia', 500);

/* resultado : SQL Error [1364] [HY000]: Field 'idcertificacionfk' doesn't have a default value*/


insert into catacion (idcatacion, idlotefk, puntaje, fechacatacion) 
values (91, 1, 105.00, '2026-03-23');

/* Resultado : SQL Error [1264] [22001]: Data truncation: Out of range value for column 'Puntaje' at row 1*/


insert into tostion (idtostion, idlotefk, fechatostion, kiloentrada, kilosalida) 
values (91, 1, '2026-03-23', 50.00, 60.00);

/* resultado: SQL Error [4025] [23000]: CONSTRAINT `validaKilos` failed for `trazacafe`.`tostion`*/


/* Reto 4*/

/* Agrega la columna pais a clientes */
alter table cliente 
add column pais varchar(50) not null default 'Colombia';

alter table tostion 
add column huellacarbonokg decimal(10,2) null,
add constraint chkhuellacarbono check (huellacarbonokg >= 0);


/*  Amplía la precisión  */
alter table tostion 
modify column kiloentrada decimal(15,5) not null,
modify column kilosalida decimal(15,5) not null;

alter table pedido 
modify column cantidakilo decimal(10,2) not null;


/*  creamos una tabla intermedia sin guiones bajos */
create table fincacertificacion (
    idfincafk int not null,
    idcertificacionfk int not null,
    primary key (idfincafk, idcertificacionfk),
    constraint fkfincacertfin foreign key (idfincafk) references fincacaficultor(idfinca) on delete cascade,
    constraint fkfincacertcert foreign key (idcertificacionfk) references certificacion(idcertificacion) on delete cascade
);


/* Reflexion 4:  Porque borrar y recrear una tabla destruye por completo los datos históricos y las relaciones existentes como las fk 
 que ya operaban en el sistema, rompiendo la trazabilidad y provocando pérdida crítica de información para el negocio. 
 El uso de ALTER TABLE permite evolucionar el esquema de forma segura conservando los datos operativos.*/

/*Reto 5*/


insert into certificacion (idcertificacion, nombrecertificacion) values 
(1, 'Orgánico'),
(2, 'Fair Trade');

insert into fincacaficultor (idfinca, nombrecaficultor, departamento, altitud, idcertificacionfk) values 
(1, 'Carlos Perez', 'Huila', 1750, 1),
(2, 'Maria Gomez', 'Quindio', 1600, 2),
(3, 'Juan Rodriguez', 'Narino', 1900, 1),
(4, 'Ana Torres', 'Antioquia', 1550, 2);

insert into lotecafecosecha (idlote, idfincafk, nombrelote, codigolote, tipovariedad, proceso) values 
(1, 1, 'Lote La Esperanza', 'HUI-2026-001', 'Caturra', 'Lavado'),
(2, 1, 'Lote El Diamante', 'HUI-2026-002', 'Geisha', 'Natural'),
(3, 2, 'Lote El Recuerdo', 'QUI-2026-001', 'Castillo', 'Lavado'),
(4, 2, 'Lote San Jose', 'QUI-2026-002', 'Bourbon', 'Honey'),
(5, 3, 'Lote La Florida', 'NAR-2026-001', 'Caturra', 'Lavado'),
(6, 3, 'Lote El Mirador', 'NAR-2026-002', 'Geisha', 'Natural'),
(7, 4, 'Lote La Linda', 'ANT-2026-001', 'Castillo', 'Lavado'),
(8, 4, 'Lote El Jardin', 'ANT-2026-002', 'Bourbon', 'Honey');

insert into catacion (idcatacion, idlotefk, puntaje, fechacatacion) values 
(1, 1, 86.50, '2026-01-10'),
(2, 1, 88.00, '2026-01-15'),
(3, 2, 91.50, '2026-01-12'),
(4, 3, 84.00, '2026-01-18'),
(5, 4, 82.50, '2026-01-20'),
(6, 5, 87.00, '2026-01-22'),
(7, 6, 92.00, '2026-01-25'),
(8, 6, 90.50, '2026-01-28'),
(9, 7, 79.00, '2026-02-01'),
(10, 8, 83.50, '2026-02-03');

insert into tostion (idtostion, idlotefk, fechatostion, kiloentrada, kilosalida, huellacarbonokg) values 
(1, 1, '2026-02-05', 50.00, 42.00, 5.50),
(2, 2, '2026-02-06', 30.00, 25.00, 3.20),
(3, 5, '2026-02-08', 45.00, 38.00, 4.80),
(4, 6, '2026-02-10', 25.00, 21.00, 2.90),
(5, 3, '2026-02-12', 60.00, 50.00, 7.00);

insert into cliente (idcliente, nombrecliente, ciudad, pais) values 
(1, 'Berlin Coffee Roasters', 'Berlin', 'Alemania'),
(2, 'Café de Especialidad S.A.S.', 'Bogota', 'Colombia'),
(3, 'Medellin Beans', 'Medellin', 'Colombia');


insert into pedido (idpedido, idclientefk, idtostionfk, fechapedido, cantidakilo, precio, estado) values 
(1, 1, 1, '2026-02-15', 20.00, 800.00, 'pendiente'),
(2, 1, 2, '2026-02-16', 15.00, 900.00, 'pendiente'),
(3, 2, 3, '2026-02-18', 25.00, 1000.00, 'pendiente'),
(4, 3, 4, '2026-02-20', 21.00, 850.00, 'pendiente');

create table lotesespecialidad (
    codigolote varchar(20) primary key,
    puntajepromedio decimal(4,2) not null
);

insert into lotesespecialidad (codigolote, puntajepromedio)
select l.codigolote, avg(c.puntaje)
from lotecafecosecha l
join catacion c on c.idlotefk = l.idlote
group by l.codigolote
having avg(c.puntaje) >= 85;

select * from pedido;
select * from cliente; 
select * from catacion; 
/*  Reflexión 5:  No se actualiza automáticamente porque es una tabla física que almacena datos estáticos calculados en el momento del inser 
   Para que se actualizara sola, se debería usar una Vista en la base de datos 
   que recalcule el promedio cada vez que se inserte una nueva catación.*/

/*Reto 6*/



/*   la tabla preciosreferencia  */
create table preciosreferencia (
    variedad varchar(40) primary key,
    preciokg decimal(15,5) not null,
    actualizadoen datetime not null default current_timestamp
);


/*  la semana 1 ) */
insert into preciosreferencia (variedad, preciokg) values 
('Castillo', 32000.00),
('Caturra', 35500.00),
('Geisha', 120000.00);


/*  la semana 2 con  */
insert into preciosreferencia (variedad, preciokg) values 
('Caturra', 36800.00),
('Geisha', 118000.00),
('Bourbon', 41000.00)
on duplicate key update 
    preciokg = values(preciokg), 
    actualizadoen = current_timestamp();

select * from preciosreferencia;

/*  Reflexión 6:  Si  no tuviera una restricción de clave primaria , el motor de base de datos 
   no podría detectar duplicados. En lugar de actualizar el registro existente , el sistema simplemente 
   insertaría una nueva fila repetida con la misma variedad pero con el nuevo precio*/

/*Reto 7*/



/*  Restar 1.5  */
select * from catacion where idcatacion between 1 and 5;

update catacion 
set puntaje = greatest(0, puntaje - 1.5)
where idcatacion between 1 and 5;

select p.* 
from pedido p
join cliente c on p.idclientefk = c.idcliente
where c.pais = 'Alemania';

update pedido p
join cliente c on p.idclientefk = c.idcliente
set p.precio = p.precio * 0.90
where c.pais = 'Alemania';



/* Reflexión 7:  Si se ejecuta el update dos veces , el descuento del 10% se aplicaría de forma acumulativa 
   un descuento sobre el precio ya rebajado, osea el 10% del nuevo valor*/

/* Reto 8:*/


delete from fincacaficultor where idfinca = 1;

/* Resultado :SQL Error [1451] [23000]: Cannot delete or update a parent row: a foreign key constraint fails 
(`trazacafe`.`lotecafecosecha`, CONSTRAINT `loteFincaFK` FOREIGN KEY (`IdFincaFK`) REFERENCES `fincacaficultor` (`IdFinca`)) */


alter table fincacaficultor 
add column activa boolean not null default true;

update fincacaficultor 
set activa = false 
where idfinca = 1;

delete c 
from catacion c
join lotecafecosecha l on c.idlotefk = l.idlote
where l.codigolote = 'HUI-2026-001';

truncate table lotesespecialidad;

drop table lotesespecialidad;



   /*Reflexión 8: El deleatw: borra filas específicas usando filtros  y permite usar transacciones para dar marcha atrás (ROLLBACK).
El truncate : vacía toda la tabla de golpe de forma rápida y reinicia los contadores de identidad sin disparar filtros de filas.
El drop también : elimina por completo la estructura física de la tabla y sus metadatos del servidor. */

/* RETO 9*/

/* Asegurar control de kilos disponibles */
alter table tostion 
add constraint chkkilosdisponibles check (kilosalida >= 0);


/* Transacción exitosa */
start transaction;

insert into pedido (idpedido, idclientefk, idtostionfk, fechapedido, cantidakilo, precio, estado) 
values (5, 2, 1, '2026-03-25', 10.00, 450.00, 'confirmado');

update tostion 
set kilosalida = kilosalida - 10.00 
where idtostion = 1;

/* Simulación de desastre  */
start transaction;

insert into pedido (idpedido, idclientefk, idtostionfk, fechapedido, cantidakilo, precio, estado) 
values (6, 2, 1, '2026-03-25', 9999.00, 50000.00, 'pendiente');

update tostion 
set kilosalida = kilosalida - 9999.00 
where idtostion = 1;

/*SQL Error [4025] [23000]: CONSTRAINT `chkkilosdisponibles` failed for `trazacafe`.`tostion`*/

select * from pedido where idpedido = 6;


/* Uso de SAVEPOINT  */
start transaction;

insert into pedido (idpedido, idclientefk, idtostionfk, fechapedido, cantidakilo, precio, estado) 
values (7, 3, 2, '2026-03-25', 5.00, 200.00, 'pendiente');

savepoint punto_respaldo;

insert into pedido (idpedido, idclientefk, idtostionfk, fechapedido, cantidakilo, precio, estado) 
values (8, 3, 2, '2026-03-25', 8.00, 350.00, 'pendiente');

rollback to punto_respaldo;

select * from pedido where idpedido in (7, 8);


/* Experimento comparativo*/
start transaction;

create table pruebaerror (
    id int primary key
);

rollback;

select * from pruebaerror;

/* Reflexión 9 : Descubrí que  las operaciones DDL ejecutan un commit implícito automático antes y después de correr,
 por lo que un roolback no puede deshacer la creación de una tabla. El gran riesgo para un script de migración es que si 
 ocurre un fallo a mitad de proceso y queremos limpiar la base de datos, las tablas creadas se quedan ahí permanentemente
  dejando el esquema a medias y corrompiendo el despliegue.*/

/* Reto 10*/

/*  Crear la vista vtrazabilidad */
/* Crear la vista vtrazabilidad */
create view vtrazabilidad as
select  p.idpedido,cl.nombrecliente,cl.pais,f.nombrecaficultor, f.departamento, f.altitud, l.nombrelote, l.tipovariedad, l.proceso,
    (select avg(c.puntaje) from catacion c where c.idlotefk = l.idlote) as puntajepromedio,
    t.fechatostion,
    concat(
        l.tipovariedad, ' ', l.proceso, ' de ', f.nombrecaficultor, 
        ' (', f.altitud, ' m). Puntaje ', 
        coalesce((select avg(c.puntaje) from catacion c where c.idlotefk = l.idlote), 0), 
        '. Tostado el ', t.fechatostion
    ) as textoqr
from pedido p
join cliente cl on p.idclientefk = cl.idcliente
join tostion t on p.idtostionfk = t.idtostion
join lotecafecosecha l on t.idlotefk = l.idlote
join fincacaficultor f on l.idfincafk = f.idfinca;


/*  Consulta de la vista para la App */
select textoqr 
from vtrazabilidad 
where idpedido = 1;

/* Reto creativo */

alter table fincacaficultor 
add column faunaprotegida varchar(150) not null default 'Aves migratorias de la región andina';


update fincacaficultor 
set faunaprotegida = 'Corredor biológico activo del Oso de Anteojos y la Palma de Cera' 
where idfinca = 1;

create or replace view vtrazabilidad as
select p.idpedido, cl.nombrecliente,cl.pais, f.nombrecaficultor, f.departamento,f.altitud, l.nombrelote, l.tipovariedad,l.proceso,
    (select avg(c.puntaje) from catacion c where c.idlotefk = l.idlote) as puntajepromedio,
    t.fechatostion,
    concat(
        l.tipovariedad, ' ', l.proceso, ' de ', f.nombrecaficultor, 
        ' (', f.altitud, ' m). Puntaje: ', 
        coalesce((select avg(c.puntaje) from catacion c where c.idlotefk = l.idlote), 0), 
        '. Conservación: ', f.faunaprotegida, 
        '. Tostado el: ', t.fechatostion
    ) as textoqr
from pedido p
join cliente cl on p.idclientefk = cl.idcliente
join tostion t on p.idtostionfk = t.idtostion
join lotecafecosecha l on t.idlotefk = l.idlote
join fincacaficultor f on l.idfincafk = f.idfinca;


select textoqr 
from vtrazabilidad 
where idpedido = 1;

/* reflexion 10: No, una vista no almacena datos físicos en disco, lo que guarda es la lógica de la consulta
y la ejecuta en tiempo real cada vez que se le hace un select. Su gran ventaja frente a duplicar los datos en una tabla física
 es que la vista siempre está sincronizada con los cambios recientes en las tablas base , evitando redundancias */


