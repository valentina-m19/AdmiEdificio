


------------------
------------------
----- TABLAS -----
--- PRINCIPALES ---
------------------


CREATE TABLE USUARIO (
	id_usuario INT PRIMARY KEY IDENTITY(1,1),
	nombre_usuario VARCHAR(100) NOT NULL, 
	rut VARCHAR(12) NOT NULL,
	rol VARCHAR(50) NOT NULL CHECK (rol IN ('PROPIERTARIO', 'RESIDENTE', 'Propietario', 'Residente', 'propietario', 'residente', 'conserje')),
	email VARCHAR(50),
    contrasena VARCHAR(200) NULL,
	fecha_creacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE ADMIN (
	id_admin INT PRIMARY KEY IDENTITY(1,1),
	nombre_admin VARCHAR(50) NOT NULL,
	rut VARCHAR(12) NOT NULL UNIQUE,
	email VARCHAR(50) NOT NULL UNIQUE,
	contrasena VARCHAR(200) NOT NULL,
	fecha_creacion DATETIME DEFAULT GETDATE()
)

CREATE TABLE EDIFICIO (
	id_edificio INT PRIMARY KEY IDENTITY(1,1),
	nombre_edificio VARCHAR(100) NOT NULL, 
	direccion_edificio VARCHAR(100),
	num_pisos INT NOT NULL
);


CREATE TABLE DEPARTAMENTO (
	id_departamento INT PRIMARY KEY IDENTITY(1,1),
    id_edificio INT NOT NULL REFERENCES	EDIFICIO(id_edificio),
    id_usuario INT NULL REFERENCES USUARIO(id_usuario),                     
    num_departamento VARCHAR(10) NOT NULL,             
    estado VARCHAR(20) NOT NULL DEFAULT 'Desocupado' CHECK (estado IN ('Habitado', 'Desocupado')),
	tipo_ocupante VARCHAR(20) NULL CHECK (tipo_ocupante IN ('Propietario', 'Arrendatario')),
);


------------------
------------------
---- FINANZAS ----
------------------
------------------


CREATE TABLE EMISION_GASTO_COMUN (
	id_emision_gasto_comun INT PRIMARY KEY IDENTITY(1,1),
	id_departamento INT NOT NULL REFERENCES DEPARTAMENTO(id_departamento),
	periodo VARCHAR(10) NOT NULL,
	monto_base NUMERIC(10,2) NOT NULL,
	monto_estacionamiento NUMERIC(10,2) DEFAULT 0,
	monto_bodega NUMERIC(10,2) DEFAULT 0,
	monto_adicional NUMERIC(10,2) DEFAULT 0,
	monto_total NUMERIC(10,2) NOT NULL,
	fecha_emision DATETIME DEFAULT GETDATE(),
	fecha_vencimiento DATE NOT NULL,
	estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Pagado', 'Aprobación Pendiente'))
);

CREATE TABLE GASTO_ADICIONAL (
	id_gasto_adicional INT PRIMARY KEY IDENTITY(1,1),
	id_emision_gasto_comun INT NOT NULL REFERENCES EMISION_GASTO_COMUN(id_emision_gasto_comun),
	concepto VARCHAR(100) NOT NULL,
	monto NUMERIC(10,2) NOT NULL
);


CREATE TABLE PAGO (
	id_pago INT PRIMARY KEY IDENTITY(1,1),
	id_emision_gasto_comun INT NOT NULL REFERENCES EMISION_GASTO_COMUN(id_emision_gasto_comun),
	monto_pagado NUMERIC(10,2) NOT NULL,
	comprobante VARCHAR(255) NULL,
	fecha_pago DATETIME DEFAULT GETDATE(),
	estado_aprobacion VARCHAR(30) NOT NULL DEFAULT 'Pendiente' CHECK (estado_aprobacion IN ('Pendiente', 'Aprobado', 'Rechazado'))
);



------------------
------------------
-- MANTENIMIENTO --
------------------
------------------


CREATE TABLE PROVEEDOR (
	id_proveedor INT PRIMARY KEY IDENTITY(1,1),
	rut_proveedor VARCHAR(12) NOT NULL,
	razon_social VARCHAR(50) NOT NULL,
	nombre_contacto VARCHAR(50),
	telefono VARCHAR(15) NOT NULL,
	email VARCHAR(50) NOT NULL,
	servicio_rubro VARCHAR(150) NOT NULL
);


CREATE TABLE MANTENIMIENTO (
	id_mantenimiento INT PRIMARY KEY IDENTITY(1,1),
	id_edificio INT NOT NULL REFERENCES EDIFICIO(id_edificio),
	id_proveedor INT NOT NULL REFERENCES PROVEEDOR(id_proveedor),
	titulo_tarea VARCHAR(200) NOT NULL,
	descripcion VARCHAR(200) NOT NULL,
	tipo_mantenimiento VARCHAR(20) NOT NULL CHECK (tipo_mantenimiento IN ('Preventivo', 'Correctivo', 'Emergencia')),
	fecha_programada DATE NULL,
	fecha_ejecucion DATE NULL,
	costo_asociado INT NOT NULL,
	estado VARCHAR(20) NOT NULL CHECK (estado IN ('Pendiente', 'En proceso', 'Realizado', 'Cancelado'))
);

CREATE TABLE ALERTA_MANTENIMIENTO (
	id_alerta INT PRIMARY KEY IDENTITY(1,1),
	id_mantenimiento INT NOT NULL REFERENCES MANTENIMIENTO(id_mantenimiento),
	fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
	mensaje_alerta VARCHAR(100) NOT NULL,
	estado_alerta VARCHAR(20) NOT NULL DEFAULT 'Activa' CHECK (estado_alerta IN ('Activa', 'Vista', 'Resuelta'))
);

CREATE TABLE NOTIFICACION_USUARIO (
	id_notificacion_usuario INT PRIMARY KEY IDENTITY(1,1),
	id_alerta INT NOT NULL REFERENCES ALERTA_MANTENIMIENTO(id_alerta) ON DELETE CASCADE,
	id_usuario INT NOT NULL REFERENCES USUARIO(id_usuario),
	leido BIT NOT NULL DEFAULT 0,
	fecha_lectura DATETIME NULL
);


CREATE TABLE PARAMETRO_CONFIG (
	id_parametro INT PRIMARY KEY IDENTITY(1,1),
	modulo VARCHAR(50) NOT NULL CHECK(modulo IN ('DEPARTAMENTO', 'PERSONAL', 'FINANZAS')),
	nombre_variable VARCHAR(100) NOT NULL,
	valor_variable VARCHAR(200) NOT NULL,
	fecha_actualizacion DATETIME DEFAULT GETDATE()
);



------------------
------------------
---- PERSONAL ----
------------------
------------------


CREATE TABLE PERSONAL (
	id_personal INT PRIMARY KEY IDENTITY(1,1),
	id_edificio INT NOT NULL REFERENCES EDIFICIO(id_edificio),
	nombre_personal VARCHAR(200) NOT NULL,
	rut_personal VARCHAR(12) NOT NULL,
	telefono_personal VARCHAR(15) NOT NULL,
	email VARCHAR(50),
	cargo VARCHAR(50) NOT NULL,
	fecha_contratacion DATE NOT NULL,
	sueldo_base NUMERIC(9,2) NOT NULL,
	valor_hora_extra NUMERIC(10,2) NOT NULL,
	estado VARCHAR(20) NOT NULL DEFAULT 'Activo' CHECK (estado IN ('Activo', 'Licencia', 'Inactivo'))
);

CREATE TABLE CONTROL_ASISTENCIA (
	id_control_asistencia INT PRIMARY KEY IDENTITY(1,1),
	id_personal INT NOT NULL REFERENCES PERSONAL(id_personal),
	fecha DATE NOT NULL,
	hora_entrada TIME NOT NULL,
	hora_salida TIME NOT NULL,
	horas_extra NUMERIC(4,2) DEFAULT 0.00,
	observaciones VARCHAR(200)
);







------------------
------------------
--- GOBERNANZA ---
------------------
------------------


CREATE TABLE SOLICITUD (
	id_solicitud INT PRIMARY KEY IDENTITY(1,1),
	id_edificio INT NOT NULL REFERENCES EDIFICIO(id_edificio),
	id_usuario INT NOT NULL REFERENCES USUARIO(id_usuario),
	tipo VARCHAR(200) NOT NULL CHECK (tipo IN ('Sugerencia', 'Reclamo', 'Consultas')),
	asunto VARCHAR(200) NOT NULL,
	descripcion VARCHAR(200) NOT NULL,
	fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
	estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'En proceso', 'Resuelto', 'Rechazado')), 
	respuesta_admin VARCHAR(200) NOT NULL,
	fecha_respuesta DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ANUNCIO (
	id_anuncio INT PRIMARY KEY IDENTITY(1,1),
	id_edificio INT NOT NULL REFERENCES EDIFICIO(id_edificio),
	id_usuario INT NOT NULL REFERENCES USUARIO(id_usuario),
	titulo VARCHAR(50) NOT NULL,
	contenido VARCHAR(200) NOT NULL,
	prioridad VARCHAR(50) NOT NULL DEFAULT 'Normal' CHECK (prioridad IN ('Baja', 'Normal', 'Urgente')), 
	fecha_publicacion DATETIME NOT NULL DEFAULT GETDATE()
);








------------------
------------------
---- CONSERJE ----
------------------
------------------




CREATE TABLE ESPACIO_COMUN (
	id_espacio INT PRIMARY KEY IDENTITY(1,1),
	id_edificio INT NOT NULL REFERENCES EDIFICIO(id_edificio),
	nombre_espacio VARCHAR(150) NOT NULL,
	costo_reserva NUMERIC(10,2) DEFAULT 0,
	garantia NUMERIC(10,2) DEFAULT 0,
	capacidad_maxima INT NOT NULL,
	estado VARCHAR(20) DEFAULT 'Disponible'
);


CREATE TABLE RESERVA_ESPACIO (
	id_reserva INT IDENTITY(1,1) PRIMARY KEY,
	id_espacio INT NOT NULL REFERENCES ESPACIO_COMUN(id_espacio),
	id_departamento INT NOT NULL REFERENCES DEPARTAMENTO(id_departamento),
	id_usuario INT NOT NULL REFERENCES USUARIO(id_usuario),
	fecha_reserva DATE NOT NULL,
	hora_inicio TIME NOT NULL,
	hora_fin TIME NOT NULL,
	monto_total NUMERIC(10,2) NOT NULL,
	monto_abono NUMERIC(10,2) NOT NULL,
	monto_saldo NUMERIC(10,2) NOT NULL,
	monto_penalizacion NUMERIC(10,2) DEFAULT 0,
	detalle_penalizacion VARCHAR(255) NULL,
	estado_reserva VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado_reserva IN ('Pendiente', 'Confirmada', 'Finalizada', 'Cancelada')),
	fecha_registro DATETIME DEFAULT GETDATE()
);


CREATE TABLE REGISTRO_VISITAS (
	id_visita INT IDENTITY(1,1) PRIMARY KEY,
	id_departamento INT NOT NULL REFERENCES DEPARTAMENTO(id_departamento),
	id_personal INT NOT NULL REFERENCES PERSONAL(id_personal),
	nombre_visita VARCHAR(150) NOT NULL,
	rut_visita VARCHAR(12) NOT NULL,
	fecha_ingreso DATETIME DEFAULT GETDATE(),
	fecha_salida DATETIME NULL,
	estacionamiento VARCHAR(20) NULL,
	patente_vehicular VARCHAR(10)
);


CREATE TABLE REGISTRO_ENCOMIENDA (
	id_encomienda INT IDENTITY(1,1) PRIMARY KEY,
	id_departamento INT NOT NULL REFERENCES DEPARTAMENTO(id_departamento),
	id_personal_recepciona INT NOT NULL REFERENCES PERSONAL(id_personal),
	id_personal_entrega INT NOT NULL REFERENCES PERSONAL(id_personal),
	empresa_envio VARCHAR(50) NOT NULL,
	descripcion_paquete VARCHAR(200) NOT NULL,
	comentario VARCHAR(255) NULL,
	estado VARCHAR(20) DEFAULT 'Pendiente',
	notificacion_enviada BIT DEFAULT 0,
	fecha_recepcion DATETIME DEFAULT GETDATE(),
	fecha_entrega DATETIME NULL
);


CREATE TABLE MULTA (
	id_multa INT IDENTITY(1,1) PRIMARY KEY,
	id_departamento INT NOT NULL REFERENCES DEPARTAMENTO(id_departamento),
	id_usuario INT NOT NULL REFERENCES USUARIO(id_usuario),
	id_personal INT NOT NULL REFERENCES PERSONAL(id_personal),
	razon VARCHAR(100) NOT NULL,
	descripcion VARCHAR(255) NOT NULL,
	monto_multa NUMERIC(10,2) NOT NULL,
	fecha_multa DATE DEFAULT GETDATE(),
	estado VARCHAR(20) DEFAULT 'Pendiente'
);










------------------
------------------
---- INSERTAR ----
-- ADMINISTRADOR --
------------------


INSERT INTO ADMIN (nombre_admin, rut, email, contrasena)
VALUES ('Valentina Mora', '00.000.000-0', 'admi@gmail.com', 'admin123');
GO


INSERT INTO ESPACIO_COMUN (id_edificio, nombre_espacio, costo_reserva, garantia, capacidad_maxima, estado)
VALUES 
(1, 'Quincho Principal', 0, 0, 20, 'Disponible'),
(1, 'Piscina Exterior', 0, 0, 30, 'Disponible'),
(1, 'Salón de Eventos', 0, 0, 50, 'Disponible');




------------------
------------------
----- SELECT -----
------------------
------------------

SELECT id_usuario, rut, nombre_usuario, rol, contrasena FROM USUARIO;
SELECT id_departamento, num_departamento FROM DEPARTAMENTO;

SELECT id_emision_gasto_comun, monto_base, monto_total, monto_adicional FROM EMISION_GASTO_COMUN;

SELECT tipo, asunto, descripcion, fecha_creacion FROM SOLICITUD;
SELECT titulo, contenido FROM ANUNCIO;

SELECT id_personal, rut_personal FROM PERSONAL;

SELECT fecha_reserva, hora_inicio, hora_fin FROM RESERVA_ESPACIO;



ALTER TABLE MULTA ALTER COLUMN id_usuario INT NULL;
ALTER TABLE MULTA ALTER COLUMN id_personal INT NULL;
ALTER TABLE REGISTRO_ENCOMIENDA ALTER COLUMN id_personal_entrega INT NULL;


DROP TABLE RESERVA_ESPACIO;






























