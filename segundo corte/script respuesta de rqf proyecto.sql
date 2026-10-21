8 . controlar accseo por rol 

delimiter //
create procedure Controlar_Acceso(
   in p_idusaurio in,
   in p_rol varchar (20))
 begin 
 	declare v_rol varchar(20)
 	declare v_activo boolean
 	
select rol, activo into v_rol,v_activo from usuario 
where 

if 
 end//
 delimiter ;

10 . seleccionar jornada 

select * from