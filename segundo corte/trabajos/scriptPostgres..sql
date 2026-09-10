create database tienda_tecno
 with encoding= 'UTF8'
 template= template0;

/*crear tablas*/
create table clientes(
idCliente serial primary key,
nombreCliente varchar(50) not null,
correoCliente varchar(120) not null unique,
fecharRegisto date  not null default current_date
);


create table productos(
idProducto serial primary key,
nombrePedido varchar(50) not null,
precioProducto numeric(10,2) not null check (precioproducto  > 0 ),
stock integer not null default 0
);

create table pedido(
idPedido serial primary key, 
idClienteFK integer not null references clientes(idcliente) on delete cascade,
fechaPedido timestamp not null default now(),
estadoPedido varchar(20) not null default 'pendiente'
);

create table detalle_pedido(
idPedidosFK integer not null references  pedido(idPedido),
idProductoFk integer not null references  productos(idProducto),
cantidad integer not null check (cantidad >0),
primary key(idPedidosFK,idProductoFk)
);

/* alteral tabala cliente */
alter table clientes
add column telefono varchar (20);

/* alteral t.producto*/
alter table productos
modify column nombrePedido varchar(150);
/*table de pedido*/

alter table pedido
rename column estadoPedido to estado;
