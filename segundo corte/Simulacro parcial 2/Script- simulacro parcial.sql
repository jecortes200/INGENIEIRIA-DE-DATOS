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