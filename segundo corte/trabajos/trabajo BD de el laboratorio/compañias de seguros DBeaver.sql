create database Compania_Seguros;
use Compania_Seguros;

create table Compania (
       iDCompania int primary key,
       nit varchar(15) not null,
       nombre varchar(50) not null,
       fechaFundacion date,
       representanteLegal varchar(50)
   );
   
   
   create table Accidentes (
       iDAccidente int primary key,
       fechaAccidente date not null,
       lugar varchar(15),
       heridos int default 0,
       fatalidades varchar(15),
       automotores varchar(15)
   );
   
    create table Automovil (
       iDAutomovil int primary key,
       marca varchar(10) not null,
       modelo varchar(15),
       placa varchar(10) unique not null,
       tipo varchar(15),
       anioFabricacion date,
       serieChasis int,
       pasajeros int,
       cilindraje varchar(10),
       iDCompania int,
       fechaInicio date,
       estado varchar(10),
       valorAsegurado int,
       costo decimal (10,2) not null,
       constraint FKautocompania 
           foreign key (iDCompania) 
           references Compania(iDCompania) on delete cascade
           );
    
   create table Involucra (
       dInvolucra int primary key,
       iDAutomovil int,
       iDAccidente int,
       constraint FKinvolucraauto 
           foreign key (iDAutomovil) 
           references Automovil(iDAutomovil) on delete cascade,
       constraint FKinvolucraaccidente 
           foreign key (iDAccidente) 
           references Accidentes(iDAccidente) on delete cascade
   );
   
    