CREATE DATABASE clinica_db_Proyecto;
GO
use clinica_db_Proyecto; 
go
 




/* Personas */
CREATE TABLE dbo.Personas (
    id_persona        INT IDENTITY(1,1) PRIMARY KEY,
    nombre            VARCHAR(100) NOT NULL,
    apellido          VARCHAR(100) NOT NULL,
    cedula            VARCHAR(20)  NULL UNIQUE,
    email             VARCHAR(150) NULL UNIQUE,
    telefono          VARCHAR(30)  NULL,
    fecha_nacimiento  DATE         NULL,
    -- Reglas básicas de forma (opcionales):
    CONSTRAINT CK_personas_nombre    CHECK (LEN(LTRIM(RTRIM(nombre)))  > 0),
    CONSTRAINT CK_personas_apellido  CHECK (LEN(LTRIM(RTRIM(apellido)))> 0),
    CONSTRAINT CK_personas_email_fmt CHECK (email IS NULL OR email LIKE '%@%.%')
);
GO

/* Pacientes  */
CREATE TABLE dbo.Pacientes (
    id_paciente  INT         PRIMARY KEY,
    tipo_sangre  VARCHAR(5)  NULL,
    alergias     VARCHAR(200) NULL,
    CONSTRAINT FK_paciente_persona
        FOREIGN KEY (id_paciente) REFERENCES dbo.Personas(id_persona)
            ON DELETE CASCADE
);
GO

/* Especialidades */
CREATE TABLE dbo.Especialidades (
    id_especialidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT CK_especialidad_nombre CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

/* Médicos (1:1 con Personas) */
CREATE TABLE dbo.Medicos (
    id_medico       INT         PRIMARY KEY,
    id_especialidad INT         NOT NULL,
    licencia        VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT FK_medico_persona
        FOREIGN KEY (id_medico) REFERENCES dbo.Personas(id_persona)
            ON DELETE CASCADE,
    CONSTRAINT FK_medico_especialidad
        FOREIGN KEY (id_especialidad) REFERENCES dbo.Especialidades(id_especialidad),
    CONSTRAINT CK_medico_licencia CHECK (LEN(LTRIM(RTRIM(licencia))) > 0)
);
GO

/* Consultorios */
CREATE TABLE dbo.Consultorios (
    id_consultorio INT IDENTITY(1,1) PRIMARY KEY,
    nombre         VARCHAR(50) NOT NULL,
    piso           INT         NULL,
    CONSTRAINT UQ_consultorio_nombre UNIQUE (nombre),
    CONSTRAINT CK_consultorio_piso CHECK (piso IS NULL OR piso >= 0),
    CONSTRAINT CK_consultorio_nombre CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

/* Estados de la cita */
CREATE TABLE dbo.EstadoCita (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre    VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT CK_estado_nombre CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

/* Citas */
CREATE TABLE dbo.Citas (
    id_cita        INT IDENTITY(1,1) PRIMARY KEY,
    id_paciente    INT        NOT NULL,
    id_medico      INT        NOT NULL,
    id_consultorio INT        NULL,
    id_estado      INT        NOT NULL,
    fecha_cita     DATETIME2  NOT NULL,
    duracion       INT        NOT NULL,
    motivo         VARCHAR(300) NULL,
    CONSTRAINT FK_cita_paciente
        FOREIGN KEY (id_paciente) REFERENCES dbo.Pacientes(id_paciente),
    CONSTRAINT FK_cita_medico
        FOREIGN KEY (id_medico) REFERENCES dbo.Medicos(id_medico),
    CONSTRAINT FK_cita_consultorio
        FOREIGN KEY (id_consultorio) REFERENCES dbo.Consultorios(id_consultorio),
    CONSTRAINT FK_cita_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.EstadoCita(id_estado),
    CONSTRAINT CK_cita_fecha    CHECK (fecha_cita >= '2000-01-01'),
    CONSTRAINT CK_cita_duracion CHECK (duracion BETWEEN 10 AND 240)
);
GO

/* Historia clínica */
CREATE TABLE dbo.HistorialMedico (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    id_cita      INT       NULL,
    id_paciente  INT       NOT NULL,
    id_medico    INT       NOT NULL,
    diagnostico  VARCHAR(300) NULL,
    tratamiento  VARCHAR(300) NULL,
    notas        VARCHAR(300) NULL,
    CONSTRAINT FK_hist_cita
        FOREIGN KEY (id_cita) REFERENCES dbo.Citas(id_cita),
    CONSTRAINT FK_hist_paciente
        FOREIGN KEY (id_paciente) REFERENCES dbo.Pacientes(id_paciente),
    CONSTRAINT FK_hist_medico
        FOREIGN KEY (id_medico) REFERENCES dbo.Medicos(id_medico)
);
GO

/* Facturación */
CREATE TABLE dbo.Facturas (
    id_factura  INT IDENTITY(1,1) PRIMARY KEY,
    id_paciente INT        NOT NULL,
    total       DECIMAL(12,2) NOT NULL CONSTRAINT DF_fact_total DEFAULT (0.00),
    estado      VARCHAR(10)   NOT NULL CONSTRAINT CK_fact_estado CHECK (estado IN ('pendiente','pagada','anulada')),
    fecha       DATETIME2     NOT NULL CONSTRAINT DF_fact_fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_fact_paciente
        FOREIGN KEY (id_paciente) REFERENCES dbo.Pacientes(id_paciente),
    CONSTRAINT CK_fact_total_nonneg CHECK (total >= 0)
);
GO

CREATE TABLE dbo.DetalleFactura (
    id_detalle  INT IDENTITY(1,1) PRIMARY KEY,
    id_factura  INT          NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    cantidad    INT          NOT NULL,
    precio      DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_det_fact
        FOREIGN KEY (id_factura) REFERENCES dbo.Facturas(id_factura) ON DELETE CASCADE,
    CONSTRAINT CK_det_cantidad_pos CHECK (cantidad > 0),
    CONSTRAINT CK_det_precio_nonneg CHECK (precio >= 0),
    CONSTRAINT CK_det_desc_nonempty CHECK (LEN(LTRIM(RTRIM(descripcion))) > 0)
);
GO


-- Datos de prueba
INSERT INTO Especialidades (nombre) VALUES
('Medicina General'),
('Pediatría'),
('Dermatología');

INSERT INTO Consultorios (nombre, piso) VALUES
('Consul 1', 1),
('Consul 2', 2);

INSERT INTO EstadoCita (nombre) VALUES
('programada'),
('atendida'),
('cancelada'),
('no_asistio');

INSERT INTO Personas (nombre, apellido, cedula, email, telefono, fecha_nacimiento) VALUES
('Ana', 'Paredes', '1712345678', 'ana@demo.com', '099111222', '1990-05-10'),
('Carlos', 'López', '1711112223', 'carlos@demo.com', '098333444', '1985-02-20'),
('María', 'Mora', '1719998887', 'maria@demo.com', '098000111', '1995-09-01'),
('Diego', 'Rojas', '1722223334', 'diego@demo.com', '097555666', '1980-12-12');

INSERT INTO Pacientes (id_paciente, tipo_sangre, alergias) VALUES
(1, 'O+', 'Ninguna'),
(3, 'A+', 'Polen');


INSERT INTO Medicos (id_medico, id_especialidad, licencia) VALUES
(4, 1, 'MED-EC-0001');

INSERT INTO Citas (id_paciente, id_medico, id_consultorio, id_estado, fecha_cita, duracion, motivo) VALUES
(1, 4, 1, 1, '2026-02-10 09:00:00', 30, 'Chequeo general'),
(3, 4, 2, 1, '2026-02-10 10:00:00', 30, 'Dolor de cabeza');


INSERT INTO HistorialMedico (id_cita, id_paciente, id_medico, diagnostico, tratamiento, notas) VALUES
(1, 1, 4, 'Resfriado', 'Paracetamol', 'Se recomienda reposo');

INSERT INTO Facturas (id_paciente, total, estado, fecha) VALUES
(1, 25.00, 'pagada', '2026-02-10'),
(3, 25.00, 'pendiente', '2026-02-10');


INSERT INTO DetalleFactura (id_factura, descripcion, cantidad, precio) VALUES
(1, 'Consulta Médica', 1, 25.00),
(2, 'Consulta Médica', 1, 25.00);
