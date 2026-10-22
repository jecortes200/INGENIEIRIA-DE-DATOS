drop database if exists dronandres;
create database dronandres;
use dronandres;

create table bases (
    id_base int auto_increment primary key,
    nombre varchar(60) not null unique,
    municipio varchar(60) not null,
    departamento varchar(40) not null,
    capacidad_drones int not null check (capacidad_drones > 0),
    fecha_apertura date not null
);

create table tipos_carga (
    id_tipo int auto_increment primary key,
    nombre varchar(40) not null unique,
    tarifa_kg decimal(10,2) not null check (tarifa_kg > 0),
    requiere_frio boolean not null default false
);

create table drones (
    id_dron int auto_increment primary key,
    codigo_serie varchar(12) not null unique,
    modelo varchar(40) not null,
    carga_max_kg decimal(5,2) not null,
    autonomia_km decimal(5,1) not null check (autonomia_km > 0),
    estado varchar(15) not null default 'activo' check (estado in ('activo', 'mantenimiento', 'retirado')),
    horas_vuelo decimal(7,1) not null default 0 check (horas_vuelo >= 0),
    fecha_adquisicion date not null,
    id_base int not null,
    constraint fk_drones_base foreign key (id_base) references bases(id_base)
);

create table pilotos (
    id_piloto int auto_increment primary key,
    documento varchar(15) not null unique,
    nombres varchar(50) not null,
    apellidos varchar(50) not null,
    email varchar(80) not null unique,
    licencia char(1) not null check (licencia in ('a', 'b', 'c')),
    fecha_ingreso date not null,
    id_supervisor int null,
    id_base int not null,
    constraint fk_pilotos_base foreign key (id_base) references bases(id_base)
);

create table clientes (
    id_cliente int auto_increment primary key,
    tipo varchar(12) not null check (tipo in ('hospital', 'farmacia', 'comercio', 'ong', 'persona')),
    nombre varchar(80) not null,
    nit_documento varchar(15) not null unique,
    email varchar(80) null unique,
    telefono varchar(15) null,
    municipio varchar(60) not null,
    fecha_registro date not null default (current_date)
);

create table entregas (
    id_entrega int auto_increment primary key,
    codigo varchar(10) not null unique,
    id_cliente int not null,
    id_dron int not null,
    id_piloto int not null,
    fecha_programada datetime not null,
    fecha_entrega datetime null,
    municipio_destino varchar(60) not null,
    distancia_km decimal(5,1) not null check (distancia_km > 0),
    prioridad varchar(8) not null default 'normal' check (prioridad in ('normal', 'urgente', 'vital')),
    estado varchar(12) not null default 'programada' check (estado in ('programada', 'en_vuelo', 'entregada', 'cancelada', 'fallida')),
    calificacion smallint null check (calificacion between 1 and 5),
    constraint fk_entregas_cliente foreign key (id_cliente) references clientes(id_cliente),
    constraint fk_entregas_dron foreign key (id_dron) references drones(id_dron),
    constraint fk_entregas_piloto foreign key (id_piloto) references pilotos(id_piloto)
);

create table carga_entrega (
    id_entrega int not null,
    id_tipo int not null,
    peso_kg decimal(6,2) not null check (peso_kg > 0),
    unidades int not null default 1 check (unidades > 0),
    primary key (id_entrega, id_tipo),
    constraint fk_carga_entrega foreign key (id_entrega) references entregas(id_entrega),
    constraint fk_carga_tipo foreign key (id_tipo) references tipos_carga(id_tipo)
);

create table mantenimientos (
    id_mantenimiento int auto_increment primary key,
    id_dron int not null,
    fecha date not null,
    tipo varchar(12) not null check (tipo in ('preventivo', 'correctivo')),
    descripcion varchar(200) null,
    costo decimal(10,2) not null check (costo >= 0),
    constraint fk_mantenimientos_dron foreign key (id_dron) references drones(id_dron)
);

create table historial_entregas (
    id_historial int auto_increment primary key,
    id_entrega int not null,
    estado_anterior varchar(12) not null,
    estado_nuevo varchar(12) not null,
    fecha_cambio datetime not null default current_timestamp,
    constraint fk_historial_entrega foreign key (id_entrega) references entregas(id_entrega)
);


insert into bases (id_base, nombre, municipio, departamento, capacidad_drones, fecha_apertura) values
(1, 'Base Cóndor', 'Rionegro', 'Antioquia', 6, '2024-02-15'),
(2, 'Base Colibrí', 'Guatapé', 'Antioquia', 4, '2024-08-01'),
(3, 'Base Frailejón', 'Tunja', 'Boyacá', 5, '2025-01-20'),
(4, 'Base Guadua', 'Salento', 'Quindío', 3, '2026-07-01');

insert into tipos_carga (id_tipo, nombre, tarifa_kg, requiere_frio) values
(1, 'Vacunas', 12000, true),
(2, 'Muestras de laboratorio', 10000, true),
(3, 'Medicamentos', 8000, false),
(4, 'Documentos', 5000, false),
(5, 'Repuestos', 4500, false),
(6, 'Alimentos', 3500, false);

insert into drones (id_dron, codigo_serie, modelo, carga_max_kg, autonomia_km, estado, horas_vuelo, fecha_adquisicion, id_base) values
(1, 'DA-CX4-01', 'Cóndor X4', 8.00, 45.0, 'activo', 312.5, '2024-02-20', 1),
(2, 'DA-CX4-02', 'Cóndor X4', 8.00, 45.0, 'activo', 468.0, '2024-03-10', 1),
(3, 'DA-CX6-01', 'Cóndor X6', 15.00, 60.0, 'activo', 205.0, '2025-01-15', 1),
(4, 'DA-COL-01', 'Colibrí Mini', 2.50, 25.0, 'activo', 520.5, '2024-08-05', 2),
(5, 'DA-COL-02', 'Colibrí Mini', 2.50, 25.0, 'mantenimiento', 610.0, '2024-08-05', 2),
(6, 'DA-ALB-01', 'Albatros H8', 25.00, 90.0, 'activo', 98.0, '2025-02-01', 3),
(7, 'DA-CX6-02', 'Cóndor X6', 15.00, 60.0, 'activo', 150.5, '2025-03-12', 3),
(8, 'DA-ALB-02', 'Albatros H8', 25.00, 90.0, 'retirado', 890.0, '2024-05-01', 3);

insert into pilotos (id_piloto, documento, nombres, apellidos, email, licencia, fecha_ingreso, id_supervisor, id_base) values
(1, '1036600111', 'Laura', 'Restrepo Gil', 'laura.restrepo@dronandes.co', 'c', '2024-02-01', null, 1),
(2, '1049600222', 'Camilo', 'Duarte Rojas', 'camilo.duarte@dronandes.co', 'c', '2025-01-10', null, 3),
(3, '1036600333', 'Mateo', 'Zapata Vélez', 'mateo.zapata@dronandes.co', 'b', '2024-04-15', 1, 1),
(4, '1036600444', 'Sara', 'Montoya Ruiz', 'sara.montoya@dronandes.co', 'b', '2024-08-10', 1, 2),
(5, '1036600555', 'Julián', 'Patiño Cruz', 'julian.patino@dronandes.co', 'a', '2025-06-01', 1, 2),
(6, '1049600666', 'Daniela', 'Suárez León', 'daniela.suarez@dronandes.co', 'b', '2025-02-01', 2, 3),
(7, '1049600777', 'Tomás', 'Becerra Niño', 'tomas.becerra@dronandes.co', 'a', '2026-06-15', 2, 3);

insert into clientes (id_cliente, tipo, nombre, nit_documento, email, telefono, municipio, fecha_registro) values
(1, 'hospital', 'Hospital San Juan de Dios de Rionegro', '890980000-1', 'compras@hsjdrionegro.org', '6045310000', 'Rionegro', '2024-03-01'),
(2, 'farmacia', 'Droguería La Esperanza', '71234567', 'esperanza.drogueria@gmail.com', '3104567890', 'Guatapé', '2024-09-12'),
(3, 'hospital', 'E.S.E. Hospital San Rafael de Tunja', '891800231-6', 'Logistica@HSRTunja.gov.co', '6087405050', 'Tunja', '2025-01-25'),
(4, 'ong', 'Fundación Alas para el Campo', '900456789-2', 'contacto@alasparaelcampo.org', null, 'Marinilla', '2024-11-03'),
(5, 'comercio', 'Repuestos Agrícolas El Arriero', '900123456-7', null, '31245678', 'El Peñol', '2025-04-18'),
(6, 'persona', 'Mariana Gómez Arango', '1040123456', 'mariana.gomez@hotmail.com', '3157778899', 'Guarne', '2025-07-07'),
(7, 'farmacia', 'Farmacia Botica del Páramo', '900777888-1', 'boticaparamo@gmail.com', '3209998877', 'Ventaquemada', '2025-02-14'),
(8, 'comercio', 'Café de Altura Las Nubes', '901222333-4', 'ventas@cafelasnubes.co', '3001112233', 'Salento', '2026-07-20'),
(9, 'persona', 'Jorge Iván Ríos', '79888777', null, null, 'Rionegro', '2026-08-30'),
(10, 'ong', 'Corporación Montaña Viva', '900999111-0', 'info@montanaviva.org', '310555444', 'Sáchica', '2025-09-01');

insert into entregas (id_entrega, codigo, id_cliente, id_dron, id_piloto, fecha_programada, fecha_entrega, municipio_destino, distancia_km, prioridad, estado, calificacion) values
(1, 'ENT-0001', 1, 1, 3, '2026-08-03 08:00:00', '2026-08-03 08:42:00', 'San Vicente', 18.5, 'vital', 'entregada', 5),
(2, 'ENT-0002', 1, 3, 1, '2026-08-05 09:30:00', '2026-08-05 10:20:00', 'Concepción', 32.0, 'vital', 'entregada', 4),
(3, 'ENT-0003', 2, 4, 4, '2026-08-07 14:00:00', '2026-08-07 14:25:00', 'San Rafael', 12.0, 'normal', 'entregada', 5),
(4, 'ENT-0004', 4, 2, 3, '2026-08-10 07:45:00', '2026-08-10 08:30:00', 'El Carmen de Viboral', 22.4, 'urgente', 'entregada', 3),
(5, 'ENT-0005', 5, 3, 1, '2026-08-12 11:00:00', null, 'El Peñol', 15.0, 'normal', 'cancelada', null),
(6, 'ENT-0006', 3, 6, 2, '2026-08-14 06:30:00', '2026-08-14 07:40:00', 'Ramiriquí', 48.0, 'vital', 'entregada', 5),
(7, 'ENT-0007', 10, 7, 6, '2026-08-18 10:00:00', '2026-08-18 10:35:00', 'Samacá', 20.5, 'normal', 'entregada', 4),
(8, 'ENT-0008', 3, 8, 6, '2026-08-20 08:15:00', null, 'Chíquiza', 35.0, 'urgente', 'fallida', null),
(9, 'ENT-0009', 6, 4, 5, '2026-08-22 16:00:00', '2026-08-22 16:20:00', 'Guarne', 9.5, 'normal', 'entregada', 2),
(10, 'ENT-0010', 1, 1, 1, '2026-08-25 07:00:00', '2026-08-25 07:50:00', 'Sonsón', 41.0, 'vital', 'entregada', 5),
(11, 'ENT-0011', 10, 6, 2, '2026-08-27 09:00:00', '2026-08-27 10:05:00', 'Sáchica', 52.5, 'urgente', 'entregada', null),
(12, 'ENT-0012', 2, 5, 4, '2026-08-29 13:00:00', null, 'Alejandría', 14.0, 'normal', 'cancelada', null),
(13, 'ENT-0013', 4, 2, 1, '2026-09-01 08:00:00', '2026-09-01 08:55:00', 'Granada', 38.0, 'urgente', 'entregada', 4),
(14, 'ENT-0014', 1, 3, 1, '2026-09-03 10:30:00', '2026-09-03 11:15:00', 'Abejorral', 44.0, 'vital', 'entregada', 5),
(15, 'ENT-0015', 7, 7, 6, '2026-09-08 15:00:00', '2026-09-08 15:30:00', 'Turmequé', 17.0, 'normal', 'entregada', 3),
(16, 'ENT-0016', 3, 6, 2, '2026-09-15 06:00:00', '2026-09-15 07:10:00', 'Miraflores', 58.0, 'vital', 'entregada', 4),
(17, 'ENT-0017', 6, 2, 3, '2026-09-21 17:00:00', null, 'Guarne', 10.0, 'normal', 'cancelada', null),
(18, 'ENT-0018', 10, 7, 6, '2026-09-30 17:40:00', null, 'Villa de Leyva', 26.0, 'normal', 'en_vuelo', null),
(19, 'ENT-0019', 1, 1, 1, '2026-10-01 07:30:00', null, 'Nariño', 47.0, 'vital', 'programada', null),
(20, 'ENT-0020', 3, 6, 6, '2026-10-02 06:00:00', null, 'Pesca', 39.0, 'vital', 'programada', null);

insert into carga_entrega (id_entrega, id_tipo, peso_kg, unidades) values
(1, 1, 3.00, 60), (1, 3, 2.00, 15),
(2, 2, 1.50, 30), (2, 3, 4.00, 40),
(3, 3, 1.80, 12),
(4, 3, 3.50, 25), (4, 4, 0.50, 3),
(5, 5, 6.00, 4),
(6, 1, 5.00, 100), (6, 2, 2.00, 40),
(7, 3, 6.00, 50),
(8, 1, 8.00, 160), (8, 3, 4.00, 30),
(9, 4, 0.80, 5),
(10, 1, 4.00, 80), (10, 2, 1.00, 20), (10, 3, 2.50, 20),
(11, 3, 7.00, 60), (11, 4, 1.00, 6),
(13, 3, 5.00, 40), (13, 5, 2.00, 2),
(14, 1, 6.00, 120), (14, 2, 3.00, 60),
(15, 3, 3.00, 25), (15, 4, 0.30, 2),
(16, 1, 10.00, 200), (16, 3, 8.00, 70),
(18, 3, 4.00, 35),
(19, 1, 3.50, 70),
(20, 2, 2.50, 50), (20, 1, 6.00, 120);

insert into mantenimientos (id_mantenimiento, id_dron, fecha, tipo, descripcion, costo) values
(1, 2, '2026-03-15', 'preventivo', 'Cambio de hélices', 350000),
(2, 4, '2026-04-02', 'preventivo', 'Calibración de GPS', 180000),
(3, 5, '2026-09-25', 'correctivo', 'Falla en motor 3', 1250000),
(4, 8, '2026-08-21', 'correctivo', 'Impacto en aterrizaje, evaluación de daños', 2800000),
(5, 1, '2026-06-10', 'preventivo', 'Revisión general de 300 horas', 420000),
(6, 6, '2026-07-05', 'preventivo', null, 260000),
(7, 5, '2026-05-14', 'preventivo', 'Cambio de baterías', 950000),
(8, 2, '2026-09-12', 'correctivo', 'Sensor de altitud defectuoso', 610000);

-- R3 Ajustes estructurales solicitados por Calidad

alter table clientes 
modify column nombre varchar(120) not null;

alter table drones
add constraint chk_drones_carga check (carga_max_kg between 0.5 and 25.0);

alter table pilotos
add constraint fk_pilotos_supervisor foreign key(id_supervisor) references pilotos (id_piloto);

-- R4. Operaciones de datos (DML)


insert into clientes(tipo,nombre,nit_documento,email,telefono,municipio,fecha_registro) values 
('FARMACIA', 'Droguería Santa Ana', '900314159-2', 'santaana@gmail.com', '3112223344', 'Marinilla', '2026-09-28'),
('PERSONA', 'Esteban Mejía Toro', '1036987654', null, '3015556677', 'Rionegro', '2026-09-29'),
('COMERCIO', 'Tienda Naturista Frailejón', '901555666-3', 'tienda.frailejon@outlook.com', '3209871234', 'Tunja', '2026-09-30');

update drones
set estado = 'mantenimiento'
where estado = 'activo' and  horas_vuelo >500;

-- actualizar tabla drones cuando estado sea = a mantenimiento cuando esatdo = activo y las horas de vuelo sea mayor que 500
 select* from entregas where estado= 'cancelada';
-- eliminar filas que digan estado = cancelado 
delete from entregas
where estado= 'cancelada'
and id_entrega not in (select id_entrega from carga_entrega);

-- r4.d consulta de resumen en una sola salida 
select 
  (select count(*) from clientes) as total_clientes,
  (select count(*) from entregas) as total_entregas,
  (select count(*) from drones where estado = 'mantenimiento') as drones_mantenimiento;

describe entregas;
select * from entregas;

/*Ra 5) Coordinación de Vuelos quiere revisar las entregas de media distancia con prioridad
alta: entregas ENTREGADA, con distancia entre 20 y 45 km (inclusive) y prioridad VITAL
o URGENTE. Use BETWEEN e IN. Columnas: codigo, municipio_destino, distancia_km,
prioridad. Orden: distancia de mayor a menor.*/

select codigo, municipio_destino, distancia_km, prioridad
from entregas
where estado = 'entregada'
  and distancia_km between 20 and 45
  and prioridad in ('vital', 'urgente')
order by distancia_km desc;

/*b 5) Auditoría pide dos listados. b.1) Entregas cerradas sin entrega efectiva: su estado no es
PROGRAMADA, EN_VUELO ni ENTREGADA (use NOT IN) y no tienen fecha de entrega (IS
NULL). Columnas: codigo, estado, fecha_programada; orden por código. b.2) Entregas
que sí tienen fecha de entrega (IS NOT NULL) pero no tienen calificación*/

select  codigo, estado, fecha_programada
from entregas
where estado not in('programada','en_vuelo','entregada')
and fecha_entrega is null
order by codigo;

select codigo, fecha_entrega
from entregas 
where fecha_entrega is not null 
and calificacion is null;

/*c 5) Mantenimiento prepara una campaña de carga pesada y busca drones cuyo estado sea
distinto de RETIRADO (¡use! =) y que cumplan al menos una de estas condiciones: (i)
carga máxima de 8 kg o más y menos de 400 horas de vuelo; (ii) autonomía mayor a 80
km. Columnas: codigo_serie, modelo, carga_max_kg, horas_vuelo, autonomia_km,
estado. Orden: codigo_serie ascendente*/

select * from drones;
select codigo_serie, modelo, carga_max_kg, horas_vuelo, autonomia_km,estado
from drones 
where estado != 'RETIRADO'
and carga_max_kg >= 8 
and horas_vuelo< 400
or autonomia_km>80
order by codigo_serie  asc;

/*d 5) Talento Humano necesita los pilotos cuya licencia no sea A (use el operador NOT) y que
ingresaron hasta el 1 de febrero de 2025, inclusive (use <=). Columnas: nombres,
apellidos, licencia, fecha_ingreso. Orden: fecha de ingreso ascendente*/

select* from pilotos;
select  nombres,apellidos, licencia, fecha_ingreso
from pilotos
where licencia not in ('A')
and fecha_ingreso <= '2025-02-01'
order by fecha_ingreso  asc;

/* R6a) Según RN-13, liste los clientes con teléfono inválido: sin teléfono o con una longitud
distinta de 10 (use <> y LENGTH). Columnas: nombre en mayúsculas (alias cliente),
municipio, teléfono mostrando 'SIN TELÉFONO' cuando sea nulo (use COALESCE, alias
telefono) y número de caracteres del teléfono (alias digitos). Orden: nombre
ascendente*/

select 
upper(nombre) as cliente,municipio,
coalesce(telefono, 'SIN TELÉFONO') as telefono,
length(telefono) as digitos 
from clientes
where telefono is null or length(telefono) <> 10
order by nombre asc;

/*UPPER(nombre): Convierte el texto de la columna a MAYÚSCULAS SOSTENIDAS (ejemplo: de "Juan" a "JUAN").

COALESCE(telefono, 'SIN TELÉFONO'): Si la columna telefono tiene un dato nulo (NULL), lo reemplaza por el texto 'SIN TELÉFONO' para que no quede la celda vacía.

LENGTH(telefono): Cuenta y devuelve la cantidad de caracteres (números o letras) que tiene ese campo.*/

select * from clientes;

/*R6b) Comercial quiere contactar a los clientes con correo corporativo: tienen correo y este
no termina en ninguno de los dominios gratuitos de RN-13 (use NOT LIKE con %).
Columnas: nombre, correo en minúsculas (alias correo) y una columna contacto con el
formato Nombre <correo> construida con CONCAT, con el correo en minúsculas.
Orden: nombre.*/

select  nombre, 
lower(email) as correo, -- Traiga el correo, pero póngalo todo en minúsculas (con LOWER) y cámbiele el alias de la columna a 'correo'.
 concat(nombre, ' <', lower(email), '>') as contacto -- Pegue el nombre, ábrale un espacio con '<', péguele el correo en minúsculas y ciérrele el '>' para que quede un formato de contacto chimba.
from clientes
where email is not null 
  and email not like '%@gmail.com' -- Y que el correo NO termine en @gmail.com
  and email not like '%@hotmail.com' -- Ni termine en @hotmail.com
  and email not like '%@outlook.com' -- Ni termine en @outlook.com 
order by nombre asc; 


/*c) ¿Los drones de la familia Cóndor tienen series de la forma DA-CX? -NN: exactamente
un carácter después de CX y exactamente dos caracteres al final (use LIKE con _).
Columnas: codigo_serie, modelo en mayúsculas (alias modelo), horas_vuelo y el
porcentaje de vida útil consumido según RN-12, redondeado a 1 decimal (alias
pct_vida_util). Orden: horas de vuelo descendente.*/

select codigo_serie,upper(modelo) as modelo,horas_vuelo,
round((horas_vuelo / 1000.0) * 100, 1) as pct_vida_util -- el (..,1) es para decir con cuantos decimales termina op quiero que salga ese porcentaje 
from drones
where codigo_serie like 'DA-CX_-__'
-- LIKE 'DA-CX_-__': El guion bajo (_) exige un caracter exacto por cada uno (1 variable despues de CX y 2 al final)
order by horas_vuelo desc;

select* from drones;

select* from carga_entrega; 
select* from tipos_carga; 
select* from entregas; 


/*R7 a) Para el informe a la Secretaría de Salud, calcule por tipo de carga, considerando solo
entregas en estado ENTREGADA: número de entregas en que aparece (num_entregas),
kilogramos totales (kg_totales), promedio de kilogramos redondeado a 2 decimales
(kg_promedio), mínimo (kg_minimo) y máximo (kg_maximo). Columna de identificación:
tipo_carga (nombre). Orden: kilogramos totales descendente*/

select 
    t.nombre as tipo_carga,
    count(e.id_entrega) as num_entregas, -- Cuenta el total de entregas por tipo de carga
    sum(ce.peso_kg) as kg_totales, 
    round(avg(ce.peso_kg), 2) as kg_promedio, 
    min(ce.peso_kg) as kg_minimo, 
    max(ce.peso_kg) as kg_maximo 
from tipos_carga t
-- Primer JOIN: Conecta el tipo de carga con la tabla intermedia para ver los pesos
join carga_entrega ce on t.id_tipo = ce.id_tipo
-- Segundo JOIN: Conecta la carga con la tabla entregas para poder filtrar por su estado real
join entregas e on ce.id_entrega = e.id_entrega
where e.estado = 'ENTREGADA' -- Filtra únicamente las entregas que terminaron exitosamente
group by t.id_tipo, t.nombre -- Agrupa los cálculos por cada tipo de carga
order by kg_totales desc; 

/*R7 b) Comercial quiere premiar a los clientes estrella: clientes con al menos 2 entregas en
estado ENTREGADA y calificación promedio de 4 o más. Las entregas sin calificación sí
cuentan como entregas realizadas, pero no participan en el promedio. Columnas: cliente,
entregas_realizadas, calificacion_promedio (2 decimales). Orden: promedio descendente
y, en empate, cliente ascendente.*/

select* from clientes; 


select 
    c.nombre as cliente, 
    count(e.id_entrega) as entregas_realizadas, -- Cuenta cuántas entregas exitosas hizo cada uno
    round(avg(e.calificacion), 2) as calificacion_promedio -- Saca el promedio de sus calificaciones y lo redondea a 2 decimales
from clientes c
-- JOIN: Conecta la tabla de clientes con la de entregas usando el ID en común
join entregas e on c.id_cliente = e.id_cliente
where e.estado = 'ENTREGADA' -- Filtra estrictamente las entregas que terminaron de forma exitosa
group by c.id_cliente, c.nombre -- Agrupa los datos y cálculos por cada cliente individual
having count(e.id_entrega) >= 2 -- Filtra los grupos: solo deja clientes con 2 o más entregas hechas
   and avg(e.calificacion) >= 4.0 -- Filtra los grupos: solo deja los que tengan un promedio de calificación de 4.0 o más
order by calificacion_promedio desc, cliente asc; 

/*¿Qué es el HAVING?
Es básicamente el hermano mayor del WHERE, pero diseñado exclusivamente para trabajar después de un GROUP BY.
Como el WHERE normal no entiende de funciones calculadas o agrupadas (como un COUNT o un AVG),
 el HAVING llega  para filtrar esos totales y promedios 
 En resumen: el WHERE filtra filas individuales antes de agrupar, y el HAVING filtra los grupos ya formados.*/

/*R8 a) Hoja de vuelo de entregas vitales. Para cada entrega VITAL en estado ENTREGADA muestre:
codigo, nombre del cliente (alias cliente), nombre completo del piloto (nombres + espacio
+ apellidos, alias piloto), serie del dron (alias dron), nombre de la base del dron (alias base)
y los minutos transcurridos entre la fecha programada y la fecha de entrega (alias
minutos_vuelo, entero). Use solo INNER JOIN. Orden: fecha programada ascendente.*/

select * from entregas;

select 
    e.codigo,
    c.nombre as cliente,
    concat(p.nombres, ' ', p.apellidos) as piloto, -- El CONCAT sirve para pegar textos o columnas de texto en una sola celda.
    d.codigo_serie as dron,
    b.nombre as base,
    timestampdiff(minute, e.fecha_programada, e.fecha_entrega) as minutos_vuelo
    from entregas e
inner join clientes c on e.id_cliente = c.id_cliente 
inner join pilotos p on e.id_piloto = p.id_piloto
inner join drones d on e.id_dron = d.id_dron
inner join bases b on p.id_base = b.id_base
where e.prioridad = 'vital'
and e.estado = 'entregada'
order by e.fecha_programada asc;

select * from pilotos;
select * from entregas;

/*b8) Productividad de pilotos. Liste todos los pilotos con su nombre completo (alias piloto),
licencia y el número de entregas en estado ENTREGADA que han realizado (alias
entregas_realizadas). Los pilotos sin entregas realizadas deben aparecer con 0. Orden:
entregas descendentes y, en empate, piloto ascendente.*/


     
select 
    concat(p.nombres, ' ', p.apellidos) as piloto,
    p.licencia,
    count(e.id_entrega) as entregas_realizadas
from pilotos p
left join entregas e on p.id_piloto = e.id_piloto and e.estado = 'ENTREGADA'
group by p.id_piloto, p.nombres, p.apellidos, p.licencia
order by entregas_realizadas desc, piloto asc;

/* C8 )Organigrama. Muestre cada piloto (nombre completo, alias piloto), su licencia y el nombre
completo de su supervisor (alias supervisor). Si el piloto no tiene supervisor, muestre
'DIRECCIÓN DE OPERACIONES'. Orden: supervisor y luego piloto.
*/

select 
    -- 1. Une el nombre y apellido del piloto en una sola celda
    concat(p.nombres, ' ', p.apellidos) as piloto,
    p.licencia,
    -- 2. Une el nombre del supervisor, o pone 'DIRECCIÓN DE OPERACIONES' si no tiene (es nulo)
    coalesce(concat(s.nombres, ' ', s.apellidos), ' SUPERVISORES ') as supervisor
from pilotos p
-- 3. Cruza la tabla pilotos consigo misma (Self-Join) para buscar al supervisor
left join pilotos s on p.id_supervisor = s.id_piloto
-- 4. Ordena primero por supervisor y luego por piloto alfabéticamente
order by supervisor asc, piloto asc;


/*d8) Auditoría de RN-05. Detecte las entregas en estado PROGRAMADA cuya distancia supera la
autonomía del dron asignado. Columnas: codigo, nombre del cliente (alias cliente), serie
del dron (alias dron), distancia_km, autonomia_km y la diferencia (alias exceso_km).
*/
select * from entregas;

select 
    e.codigo,
    c.nombre as cliente,
    d.codigo_serie as dron,
    d.autonomia_km,
    e.distancia_km,
   (e.distancia_km - d.autonomia_km) as exceso_km
 from entregas e
join clientes c on e.id_cliente = c.id_cliente 	
join drones d on e.id_dron = d.id_dron
where e.estado = 'programada'
and e.distancia_km > d.autonomia_km;


/* R9. Subconsultas
 * 
a) Liste las entregas en estado ENTREGADA cuya distancia es mayor que el promedio de
distancia de las entregas en estado ENTREGADA. Columnas: código, municipio_destino,
distancia_km. Orden: distancia descendente.*/

select 
    e.codigo,
    e.municipio_destino,
    e.distancia_km
from entregas e
where e.estado = 'ENTREGADA'
  and e.distancia_km > (select avg(distancia_km) -- se pone otro select porq si no se pone com oel primer select va leyendo fila
                                                 --  por fila entonces no calcula el primedio primero  
      from entregas 
      where estado = 'ENTREGADA'
  )
order by e.distancia_km desc;
    
/*b9) Comercial quiere llamar a los clientes que nunca han tenido una entrega. Use NOT IN.
Columnas: nombre, tipo, municipio, fecha_registro. Orden: fecha de registro y luego
nombre.*/

select *from clientes;
select *from entregas;

select 
    c.nombre,
    c.id_cliente,
    c.tipo,
    c.municipio,
    c.fecha_registro
   from clientes c
 join entregas e on c.id_cliente =e.id_cliente
 where e.fecha_entrega is null 
 order by c.fecha_registro asc, c.nombre;
-- ------
select 
    c.nombre,
    c.tipo,
    c.municipio,
    c.fecha_registro
from clientes c
-- Filtramos para que solo pasen los clientes cuyo ID NO esté en la lista de entregas
where c.id_cliente not in (
    -- Subconsulta: Extrae una lista con los IDs de todos los clientes que SÍ tienen al menos una entrega
    select e.id_cliente 
    from entregas e
)
-- Ordenamos cronológicamente por la fecha de registro y alfabéticamente por nombre
order by c.fecha_registro asc, c.nombre asc;

/*c9) Mantenimiento sospecha de sobreuso: liste los drones cuyas horas de vuelo superan el
promedio de horas de los drones de su misma base (se consideran todos los drones de la
base, sin importar su estado). Use una subconsulta correlacionada. Columnas:
codigo_serie, nombre de la base (alias base), horas_vuelo. Orden: base.*/

select 
    d.codigo_serie,
    b.nombre as base,
    d.horas_vuelo
from drones d
-- Unimos con la tabla bases para poder mostrar el nombre de la base
inner join bases b on d.id_base = b.id_base
-- Filtramos los drones cuyas horas de vuelo superan el promedio de su misma base
where d.horas_vuelo > (
    -- Subconsulta correlacionada: calcula el promedio de horas de los drones 
    -- que pertenecen exactamente a la misma base del dron que se está evaluando (d.id_base)
    select avg(d2.horas_vuelo)
    from drones d2
    where d2.id_base = d.id_base
)
-- Ordenamos por el nombre de la base como lo pide el enunciado
order by base asc;

/* R10. Vista e índices
 * 
a) Cree la vista vw_tablero_entregas para el área administrativa, con una fila por entrega y
estas columnas: codigo, fecha_programada, cliente (nombre), tipo_cliente,
municipio_destino, dron (serie), piloto (nombre completo), prioridad, estado, tipos_carga
(cantidad de tipos de carga registrados) y peso_total_kg (suma del peso; 0 si la entrega no
tiene carga). La vista debe incluir también las entregas que aún no tienen carga registrada.
Pruébela consultando las entregas PROGRAMADA o EN_VUELO ordenadas por fecha
programada*/


create or replace view vw_tablero_entregas as
select 
   e.codigo,
   e.fecha_programada,
   c.nombre as cliente,
   c.tipo as tipo_cliente,
   e.municipio_destino,
   d.codigo_serie,
   concat(p.nombres,' ',p.apellidos) as piloto,
   e.prioridad,
   e.estado,
   coalesce(count(tc.id_tipo),0) as cantidad_tipo_carga, -- -- Contamos cuántos tipos de carga tiene asociados. 
    -- Usamos COALESCE para que, si no tiene carga, devuelva 0 en lugar de un valor nulo.
   coalesce(sum(ce.peso_kg),0)as peso_total -- Sumamos el peso total de la carga de esa entrega.
    -- COALESCE asegura que si la entrega no tiene carga registrada, devuelva 0.
  from entregas e
join clientes c on e.id_cliente = c.id_cliente
join drones d on e.id_dron = d.id_dron
join pilotos p on e.id_piloto = p.id_piloto
left join carga_entrega ce on e.id_entrega =ce.id_entrega -- Usamos LEFT JOIN con la tabla intermedia para incluir las entregas que AÚN NO tienen carga registrada
left join tipos_carga tc on ce.id_tipo = tc.id_tipo
group by e.id_entrega, e.codigo, e.fecha_programada, c.nombre, c.tipo, 
         e.municipio_destino, d.codigo_serie, p.nombres, p.apellidos, 
         e.prioridad, e.estado;


select * 
from vw_tablero_entregas
where estado in ('PROGRAMADA', 'EN_VUELO')
order by fecha_programada asc;

/* 10,b) Las dos búsquedas más frecuentes del sistema son: (1) entregas filtradas por estado
dentro de un rango de fechas programadas; (2) clientes filtrados por tipo y municipio. Cree
dos índices con prefijo idx_ que las optimicen (no sobre claves primarias ni columnas
UNIQUE). Justifique cada uno en un comentario de 2 o 3 líneas y demuestre que existen
(SHOW INDEX en MySQL, vista pg_indexes en PostgreSQL).*/

-- ==========================================================
-- 1. Índice para optimizar la búsqueda de entregas por estado y rango de fechas
-- ==========================================================
create index idx_entregas_estado_fecha 
on entregas (estado, fecha_programada);

/* Justificación: Este índice compuesto acelera las consultas frecuentes que filtran 
   el estado de los envíos y barren un rango temporal, permitiendo al motor ubicar 
   directamente los registros sin hacer un recorrido completo de toda la tabla. */


-- ==========================================================
-- 2. Índice para optimizar la búsqueda de clientes por tipo y municipio
-- ==========================================================
create index idx_clientes_tipo_municipio 
on clientes (tipo, municipio);

/* Justificación: Al agrupar las columnas 'tipo' y 'municipio', este índice evita 
   exploraciones secuenciales pesadas y permite a la base de datos filtrar de forma 
   instantánea los perfiles comerciales según la ubicación y la categoría del cliente. */


-- ==========================================================
-- 3. Demostración de existencia (SHOW INDEX en MySQL / MariaDB)
-- ==========================================================
show index from entregas;
show index from clientes;

/*• R11. Función almacenada
 * 
a) Cree la función fn_valor_entrega(p_id_entrega) que calcule el valor de una entrega según
RN-10 y lo devuelva con 2 decimales. Si la entrega no tiene carga, el valor corresponde solo
a la distancia (con el recargo si aplica). Si la entrega no existe, debe devolver NULL.

b) Pruébela así: (1) liste las entregas ENTREGADA con prioridad URGENTE con codigo,
prioridad y el valor (alias valor_cop), orden descendente por valor; (2) ejecute la función
con el identificador 999.*/


select * from tipos_carga;


delimiter //

create function fn_valor_entrega(p_id_entrega int) 
returns decimal(10,2)
deterministic
begin
    -- 1. Declaración de variables internas ("borradores" de cálculo)
    declare v_existe int default 0;
    declare v_distancia decimal(5,1) default 0;
    declare v_prioridad varchar(8);
    declare v_tarifa_km decimal(10,2) default 2000.00; -- Tarifa base por kilómetro
    declare v_recargo_prioridad decimal(5,2) default 1.00;
    declare v_valor_distancia decimal(10,2) default 0;
    declare v_costo_carga decimal(10,2) default 0;
    declare v_total_final decimal(10,2) default 0;

    select count(*), coalesce(e.distancia_km, 0), e.prioridad    -- 2. Validamos si la entrega existe y obtenemos su distancia y prioridad
    into v_existe, v_distancia, v_prioridad
    from entregas e
    where e.id_entrega = p_id_entrega;

    if v_existe = 0 then  -- 3. Si la entrega no existe (el conteo es 0), devolvemos NULL como exige el enunciado
        return null;
    end if;

    -- 4. Aplicamos recargo según la prioridad de la entrega (RN-10)
    -- Vital: 30% recargo (1.30), Urgente: 15% recargo (1.15), Normal: sin recargo (1.00)
    if v_prioridad = 'vital' then
        set v_recargo_prioridad = 1.30;
    elseif v_prioridad = 'urgente' then
        set v_recargo_prioridad = 1.15;
    else
        set v_recargo_prioridad = 1.00;
    end if;

    -- Calculamos el valor base de la distancia aplicando el recargo por prioridad
    set v_valor_distancia = (v_distancia * v_tarifa_km) * v_recargo_prioridad;

    -- 5. Calculamos el costo de la carga asociada
    select coalesce(sum(ce.peso_kg * tc.tarifa_kg), 0)
    into v_costo_carga
    from carga_entrega ce
    inner join tipos_carga tc on ce.id_tipo = tc.id_tipo
    where ce.id_entrega = p_id_entrega;

    set v_total_final = v_valor_distancia + v_costo_carga;     -- 6. Sumamos el valor de la distancia (con recargo) + el costo total de la carga

    return round(v_total_final, 2);

end //

delimiter ;

select 
    e.id_entrega,
    e.codigo,
    e.municipio_destino,
    e.prioridad,
    e.distancia_km,
    fn_valor_entrega(e.id_entrega) as valor_total_calculado
from entregas e
limit 10;

-- Calcular el valor de una entrega existente
select fn_valor_entrega(1) as valor_entrega_1;

--  Evaluar qué pasa si le pasas un ID que no existe (debe retornar NULL)
select fn_valor_entrega(9999) as entrega_inexistente;

/*• R12. Trigger de auditoría
Auditoría exige trazabilidad automática de los estados (RN-09 y RN-11). Cree el trigger
trg_entregas_estado con estas características:
Elemento Especificación
Tabla entregas
Operación UPDATE
Momento BEFORE, porque debe modificar la fila antes de
guardarla

Lógica Solo si el estado cambia: (1) si el nuevo estado
es ENTREGADA y fecha_entrega es nula,
asignarle la fecha y hora actual; 
(2) insertar en historial_entregas el id de la entrega, el estado
anterior y el nuevo. Si el estado no cambia, no
registra nada.
Resultado esperado Un registro en el historial por cada cambio real
de estado
*/
select * from historial_entregas;

delimiter //

create trigger trg_entregas_estado
before update on entregas
for each row
begin 
    if old.estado <> new.estado then  -- 1. Validamos si el estado cambió realmente 

        -- 2. Si el nuevo estado es 'entregada' y la fecha está vacía, le asignamos la actual
        if new.estado = 'entregada' and new.fecha_entrega is null then
            set new.fecha_entrega = current_timestamp(); -- fecha y hora actual
        end if;
        
        -- 3. Insertamos el registro en el historial con sus respectivos valores (VALUES)
        insert into historial_entregas (id_entrega, estado_anterior, estado_nuevo, fecha_cambio)
        values (old.id_entrega, old.estado, new.estado, current_timestamp());
        
    end if;
end //

delimiter ;


-- ==========================================================
-- Pruebas de demostración obligatorias para R12
-- ==========================================================

-- 1. Actualiza estado a 'entregada' y calificación a 5 para ENT-0018
update entregas set estado = 'entregada', calificacion = 5 where codigo = 'ENT-0018';

-- 2. Actualiza estado a 'cancelada' para ENT-0019
update entregas set estado = 'entregada' where codigo = 'ENT-0019';

-- 3. Actualiza únicamente la calificación a 4 para ENT-0011 (El estado NO cambia)
update entregas set calificacion = 4 where codigo = 'ENT-0011';


-- ==========================================================
-- Consultas de verificación
-- ==========================================================

-- A. Revisar cómo quedó el historial de cambios
select * from historial_entregas;
select * from entregas;
-- B. Revisar las tres entregas involucradas
select id_entrega, codigo, estado, fecha_entrega, calificacion 
from entregas 
where codigo in ('ENT-0018', 'ENT-0019', 'ENT-0011'); 


/* R13. Procedimiento almacenado
Operaciones necesita programar entregas sin violar las reglas. Cree el procedimiento
sp_programar_entrega con 8 parámetros de entrada, en este orden: código, id del cliente, id del
dron, id del piloto, fecha programada, municipio de destino, distancia en km y prioridad. Debe
validar, en este orden:
1. Que el dron y el piloto existan.
2. Que el dron esté ACTIVO (RN-06).
3. Que la distancia no supere la autonomía del dron (RN-05).
4. Que la licencia del piloto permita la distancia (RN-03).

Si una validación falla, el procedimiento debe detenerse con un error cuyo mensaje explique el
motivo (MySQL: SIGNAL SQLSTATE '45000'; PostgreSQL: RAISE EXCEPTION). Si todo es válido,
inserta la entrega (el estado debe quedar PROGRAMADA por el valor por defecto) y muestra un
mensaje con el identificador generado (MySQL: SELECT; PostgreSQL: RAISE NOTICE).
Pruébelo con exactamente estas tres llamadas y luego consulte la vista de R10 para la entrega
ENT-0021:
CALL sp_programar_entrega('ENT-0021', 11, 3, 3, '2026-10-03 10:00:00', 'Marinilla', 16.0,
'URGENTE');
CALL sp_programar_entrega('ENT-0022', 6, 4, 4, '2026-10-03 11:00:00', 'Guarne', 9.0, 'NORMAL');
CALL sp_programar_entrega('ENT-0023', 2, 7, 7, '2026-10-04 08:00:00', 'Arcabuco', 28.0, 'NORMAL');
*/
select *from drones;

delimiter //

create procedure sp_programar_entrega(
    in p_codigo varchar(10),
    in p_id_cliente int,
    in p_id_dron int,
    in p_id_piloto int,
    in p_fecha_programada datetime,
    in p_municipio_destino varchar(60),
    in p_distancia_km decimal(5,1),
    in p_prioridad varchar(8)
) 
begin 
    -- Declaración de variables 
    declare v_exista_pilot int default 0;
    declare v_exista_dron int default 0;
    declare v_dron_activo varchar(15);
    declare v_autonomia decimal(5,1);
    declare v_licencia char(1);

    -- 1. Validar existencia del dron y piloto (usando los nombres exactos)
    select count(*) into v_exista_dron from drones where id_dron = p_id_dron;
    select count(*) into v_exista_pilot from pilotos where id_piloto = p_id_piloto;

    if v_exista_dron = 0 or v_exista_pilot = 0 then
        signal sqlstate '45000' set message_text = 'El dron o el piloto no existen.';
    end if;

    -- 2. Validar que el dron esté activo
    select estado into v_dron_activo from drones where id_dron = p_id_dron;

    if v_dron_activo <> 'activo' then
        signal sqlstate '45000' set message_text = 'El dron no está activo.';
    end if;

    -- 3. Validar autonomía (comparando la distancia del parámetro con la autonomía del dron)
    select autonomia_km into v_autonomia from drones where id_dron = p_id_dron;

    if p_distancia_km > v_autonomia then
        signal sqlstate '45000' set message_text = 'La distancia supera la autonomía del dron.';
    end if;
 end//
 delimiter ;

CALL sp_programar_entrega('ENT-0021', 11, 3, 3, '2026-10-03 10:00:00', 'Marinilla', 16.0, 'URGENTE');

CALL sp_programar_entrega('ENT-0099', 11, 3, 3, '2026-10-03 12:00:00', 'Bogotá', 75.0, 'NORMAL');





