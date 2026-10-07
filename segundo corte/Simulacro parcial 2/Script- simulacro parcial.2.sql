create database DronAndres;

use DronAndres;

create table bases(
id_base int auto_increment primary key,
nombre varchar(60) not null unique,
municipio varchar(60) not null,
departamento varchar (40) not null ,
capacidad_drones int not null check(capacidad_drones>0), 
fecha_apertura date not null
);

create table tipos_carga(
id_tipo int auto_increment primary key,
nombre_TipoCarga varchar(40) not null unique,
tarifa_kg decimal(10,2) not null check(tarifa_kg >0),
requiere_frio boolean not null default false
);

create table drones(
id_dron int auto_increment primary key,
codigo_serie varchar(12) not null unique,
modelo varchar(40) not null,
carga_max_kg decimal(5,2) not null,
autonomia_km decimal(5,1) not null check(autonomia_km>0),
estado varchar(15) not null default 'ACTIVO', check (estado in('ACTIVO','MATENIMINETO','RETIRADO')),
horas_vuelo decimal(7,1) not null default 0, check (horas_vuelo>0),
fecha_adquisicion date not null ,
id_base int not null,
constraint fkdronesbase foreign key(id_base) references bases(id_base) 
);

create table pilotos(
id_piloto int auto_increment primary key, 
documento_cc varchar(15) not null unique,
nombres varchar(50) not null,
apellidos varchar(50) not null,
email varchar (80) not null unique ,
licencia char(1) not null check (licencia in ('A','B','C')),
fecha_ingreso DATE not null,
id_supervisor int not null,
id_base int not null,
constraint fkPilotosBase foreign key(id_base) references bases(id_base)
);

create table clientes(
id_cliente int auto_increment primary key,
tipo varchar(12) not null check (tipo in('HOSPITAL','FARMACIA','COMERCIO','ONG','PERSONA')),
nombre varchar(80) not null,
nit_documento varchar(15) not null unique,
email varchar(80) null unique,
telefono varchar(15) null,
municipio varchar(60) not null,
fecha_registro date not null default(current_date)
);

create table entregas(
id_entrega
codigo
id_cliente
id_dron
id_piloto
fecha_programada
fecha_entrega
municipio_destino
distancia_k m
prioridad
estado
calificacion
);






