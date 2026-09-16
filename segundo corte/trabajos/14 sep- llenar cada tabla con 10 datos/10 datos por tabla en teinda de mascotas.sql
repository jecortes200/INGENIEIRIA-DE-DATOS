use tienda_macosta;
   
   /* indice  es un aestructura de datos que utiliza las conusltas 
    * simple : crea una sola consulta 
    * compuesto: crear sobre multiples columnas  funciona de izq a derecha.
    * costos : ls acelera drasticament las consultas pero generan penalizacion 
    * (insert udapte delate)
    */



   create index idxclientenombre on cliente(apellidosCliente, nombresCliente);
-- Índice 2: Búsqueda de mascotas por tipo y raza (Compuesto)
   create index idxmascotatiporaza on mascota(tipoMascota, razaMascota);
-- Índice 3: Búsqueda de compras por fecha (Simple)
   create index idxcomprafechaon on compraproducto(fechaCompra);
   
  
   insert into cliente (cedulaCliente, nombresCliente, apellidosCliente, direccionCliente, telefonoCliente) values
(201, 'Mateo', 'Rojas', 'Calle 20 # 10-45', '3112345678'),
(202, 'Valentina', 'Vargas', 'Carrera 30 # 45-12', '3129876543'),
(203, 'Andrés', 'Castro', 'Av. El Libertador 45', '3134567890'),
(204, 'Camila', 'Morales', 'Calle 80 # 15-22', '3141112233'),
(205, 'Felipe', 'Jiménez', 'Carrera 9 # 50-60', '3159998877'),
(206, 'Lucía', 'Ortiz', 'Calle 53 # 70-12', '3163334455'),
(207, 'Gabriel', 'Silva', 'Diagonal 45 # 8-10', '3177776655'),
(208, 'Valeria', 'Ríos', 'Transversal 20 # 30-5', '3184443322'),
(209, 'David', 'Navarro', 'Calle 72 # 11-85', '3198889900'),
(210, 'Daniela', 'Medina', 'Carrera 14 # 90-40', '3205556677');

insert into mascota (codigoMascota, nombreMascota, tipoMascota, razaMascota, generoMascota, cedulaClienteFK) values
(11, 'Zeus', 'Perro', 'Dóberman', 'Macho', 201),
(12, 'Kira', 'Gato', 'Maine Coon', 'Hembra', 202),
(13, 'Bruno', 'Perro', 'Boxer', 'Macho', 203),
(14, 'Mila', 'Gato', 'Angora', 'Hembra', 204),
(15, 'Toby', 'Perro', 'Shih Tzu', 'Macho', 205),
(16, 'Lola', 'Perro', 'Cocker Spaniel', 'Hembra', 206),
(17, 'Copito', 'Conejo', 'Enana Holandesa', 'Macho', 207),
(18, 'Oreo', 'Gato', 'Criollo', 'Macho', 208),
(19, 'Princesa', 'Perro', 'Chihuahua', 'Hembra', 209),
(20, 'Zeus', 'Gato', 'Ragdoll', 'Macho', 210);

insert into vacunasdisponibles (codigoVacuna, nombreVacuna, dosisVacuna, enfermedadTrata) values
(601, 'Antirrábica Anual', '1 ml', 'Prevención de rabia'),
(602, 'Pentavalente Felina', '0.5 ml', 'Panleucopenia, Calicivirus y Rinotraqueitis'),
(603, 'Vacuna KC', '1 ml', 'Traqueobronquitis infecciosa canina'),
(604, 'Leptospirosis', '1 ml', 'Bacterias del género Leptospira'),
(605, 'Hexacima Canina', '1 ml', 'Moquillo, Hepatitis, Parvovirus, Parainfluenza'),
(606, 'Herpesvirus Canino', '1 ml', 'Infecciones por herpesvirus'),
(607, 'Vacuna Felv', '1 ml', 'Leucemia felina avanzada'),
(608, 'Antiparasitario Oral', '1 tableta', 'Control de nematodos y céstodos'),
(609, 'Vacuna Bordetella Intranasal', '0.4 ml', 'Tos de las perreras'),
(610, 'Refuerzo Anual Polivalente', '1 ml', 'Protección múltiple general');

insert into producto (codigoBarras, nombreProducto, marcaProducto, precioProducto) values
(8001, 'Alimento Cachorro 10kg', 'ProPlan', 145000.00),
(8002, 'Piedras Sanitarias Sílice 4kg', 'CatLitter', 42000.00),
(8003, 'Hueso de Cordero Recreativo', 'NaturalChew', 12000.00),
(8004, 'Gotas Oftálmicas Veterinarias', 'VetCare', 31000.00),
(8005, 'Rascador Torre de 3 Niveles', 'CatTower', 150000.00),
(8006, 'Arnés Antitirones Reflectivo', 'PetSafe', 45000.00),
(8007, 'Shampoo Seco en Espuma', 'DryClean', 24000.00),
(8008, 'Galletas de Arándano para Perro', 'HealthyDog', 15500.00),
(8009, 'Bebedero Automático de Fuente', 'WaterPet', 89000.00),
(8010, 'Capa Impermeable para Lluvia', 'RainDog', 36000.00);

insert into mascotavacuna (codigoMascotaFK, codigoVacunaFK, fechaAplicacion) values
(11, 601, '2026-01-15'),
(11, 605, '2026-02-10'),
(12, 602, '2026-01-18'),
(13, 603, '2026-02-05'),
(14, 607, '2026-02-20'),
(15, 609, '2026-01-22'),
(16, 601, '2026-03-01'),
(17, 608, '2026-02-14'),
(18, 604, '2026-01-30'),
(19, 602, '2026-02-25');

insert into compraproducto (cedulaClienteFK, codigoBarrasFK, fechaCompra, cantidad) values
(201, 8001, '2026-03-02', 1),
(202, 8002, '2026-03-03', 2),
(203, 8003, '2026-03-03', 4),
(204, 8005, '2026-03-04', 1),
(205, 8004, '2026-03-05', 1),
(206, 8006, '2026-03-06', 2),
(207, 8008, '2026-03-07', 3),
(208, 8010, '2026-03-08', 1),
(209, 8007, '2026-03-09', 2),
(210, 8009, '2026-03-10', 1);


