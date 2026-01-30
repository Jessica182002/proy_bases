-- Citas
CREATE INDEX IX_Citas_fecha          ON dbo.Citas (fecha_cita);
CREATE INDEX IX_Citas_doctor_fecha   ON dbo.Citas (id_medico, fecha_cita) INCLUDE (duracion, motivo, id_paciente, id_estado, id_consultorio);
CREATE INDEX IX_Citas_paciente_fecha ON dbo.Citas (id_paciente, fecha_cita);
CREATE INDEX IX_Citas_estado         ON dbo.Citas (id_estado);

-- Historial
CREATE INDEX IX_Historial_paciente   ON dbo.HistorialMedico (id_paciente, id_cita);

-- Facturación
CREATE INDEX IX_Facturas_fecha       ON dbo.Facturas (fecha);
CREATE INDEX IX_Detalle_factura      ON dbo.DetalleFactura (id_factura);

-- Personas
CREATE UNIQUE INDEX UQ_Personas_cedula   ON dbo.Personas (cedula);
CREATE UNIQUE INDEX UQ_Personas_email    ON dbo.Personas (email);
CREATE INDEX IX_Personas_apellido_nombre ON dbo.Personas (apellido, nombre);

-- Médicos
CREATE INDEX IX_Medicos_especialidad ON dbo.Medicos (id_especialidad);


/* Tabla de Auditoría  */
IF OBJECT_ID('dbo.AuditoriaSimple') IS NULL
BEGIN
  CREATE TABLE dbo.AuditoriaSimple (
    id_audit BIGINT IDENTITY(1,1) PRIMARY KEY,
    tabla    SYSNAME      NOT NULL,
    accion   VARCHAR(10)  NOT NULL,   -- INSERT | UPDATE | DELETE
    pk_valor VARCHAR(50)  NOT NULL,   -- valor de la PK afectada
    fecha    DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
  );

  -- Índices simples para consultar
  CREATE INDEX IX_AuditoriaSimple_tabla_fecha ON dbo.AuditoriaSimple (tabla, fecha DESC);
  CREATE INDEX IX_AuditoriaSimple_accion      ON dbo.AuditoriaSimple (accion);
END;
GO

/*  Citas*/

-- INSERT
IF OBJECT_ID('dbo.trg_Citas_INS') IS NOT NULL DROP TRIGGER dbo.trg_Citas_INS;
GO
CREATE TRIGGER dbo.trg_Citas_INS
ON dbo.Citas
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'Citas', 'INSERT', CAST(i.id_cita AS VARCHAR(50))
  FROM inserted AS i;
END;
GO

-- UPDATE
IF OBJECT_ID('dbo.trg_Citas_UPD') IS NOT NULL DROP TRIGGER dbo.trg_Citas_UPD;
GO
CREATE TRIGGER dbo.trg_Citas_UPD
ON dbo.Citas
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'Citas', 'UPDATE', CAST(i.id_cita AS VARCHAR(50))
  FROM inserted AS i;
END;
GO

-- DELETE
IF OBJECT_ID('dbo.trg_Citas_DEL') IS NOT NULL DROP TRIGGER dbo.trg_Citas_DEL;
GO
CREATE TRIGGER dbo.trg_Citas_DEL
ON dbo.Citas
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'Citas', 'DELETE', CAST(d.id_cita AS VARCHAR(50))
  FROM deleted AS d;
END;
GO

/* HistorialMedico */

-- INSERT
IF OBJECT_ID('dbo.trg_HistorialMedico_INS') IS NOT NULL DROP TRIGGER dbo.trg_HistorialMedico_INS;
GO
CREATE TRIGGER dbo.trg_HistorialMedico_INS
ON dbo.HistorialMedico
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'HistorialMedico', 'INSERT', CAST(i.id_historial AS VARCHAR(50))
  FROM inserted AS i;
END;
GO

-- UPDATE
IF OBJECT_ID('dbo.trg_HistorialMedico_UPD') IS NOT NULL DROP TRIGGER dbo.trg_HistorialMedico_UPD;
GO
CREATE TRIGGER dbo.trg_HistorialMedico_UPD
ON dbo.HistorialMedico
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'HistorialMedico', 'UPDATE', CAST(i.id_historial AS VARCHAR(50))
  FROM inserted AS i;
END;
GO

-- DELETE
IF OBJECT_ID('dbo.trg_HistorialMedico_DEL') IS NOT NULL DROP TRIGGER dbo.trg_HistorialMedico_DEL;
GO
CREATE TRIGGER dbo.trg_HistorialMedico_DEL
ON dbo.HistorialMedico
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'HistorialMedico', 'DELETE', CAST(d.id_historial AS VARCHAR(50))
  FROM deleted AS d;
END;
GO

/* Facturas */

-- INSERT
IF OBJECT_ID('dbo.trg_Facturas_INS') IS NOT NULL DROP TRIGGER dbo.trg_Facturas_INS;
GO
CREATE TRIGGER dbo.trg_Facturas_INS
ON dbo.Facturas
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'Facturas', 'INSERT', CAST(i.id_factura AS VARCHAR(50))
  FROM inserted AS i;
END;
GO

-- UPDATE
IF OBJECT_ID('dbo.trg_Facturas_UPD') IS NOT NULL DROP TRIGGER dbo.trg_Facturas_UPD;
GO
CREATE TRIGGER dbo.trg_Facturas_UPD
ON dbo.Facturas
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'Facturas', 'UPDATE', CAST(i.id_factura AS VARCHAR(50))
  FROM inserted AS i;
END;
GO

-- DELETE
IF OBJECT_ID('dbo.trg_Facturas_DEL') IS NOT NULL DROP TRIGGER dbo.trg_Facturas_DEL;
GO
CREATE TRIGGER dbo.trg_Facturas_DEL
ON dbo.Facturas
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.AuditoriaSimple (tabla, accion, pk_valor)
  SELECT 'Facturas', 'DELETE', CAST(d.id_factura AS VARCHAR(50))
  FROM deleted AS d;
END;
GO