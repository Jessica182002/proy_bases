USE clinica_db_Proyecto;
GO

-- Recepcionista: gestiona pacientes, citas y facturación; consulta catálogos y médicos

GRANT SELECT, INSERT, UPDATE ON dbo.Personas TO recepcionista;
GRANT SELECT, INSERT, UPDATE ON dbo.Pacientes TO recepcionista;
GRANT SELECT, INSERT, UPDATE ON dbo.Citas TO recepcionista;
GRANT SELECT, INSERT, UPDATE ON dbo.Facturas TO recepcionista;
GRANT SELECT, INSERT, UPDATE ON dbo.DetalleFactura TO recepcionista;

GRANT SELECT ON dbo.Medicos TO recepcionista;
GRANT SELECT ON dbo.Consultorios TO recepcionista;
GRANT SELECT ON dbo.EstadoCita TO recepcionista;
GRANT SELECT ON dbo.Especialidades TO recepcionista;
GRANT SELECT ON dbo.HistorialMedico TO recepcionista;


-- Médico: consulta pacientes/citas y escribe/actualiza historia clínica

GRANT SELECT ON dbo.Personas TO medico;
GRANT SELECT ON dbo.Pacientes TO medico;
GRANT SELECT ON dbo.Citas TO medico;
GRANT SELECT ON dbo.Consultorios TO medico;
GRANT SELECT ON dbo.EstadoCita TO medico;
GRANT SELECT ON dbo.Facturas TO medico;
GRANT SELECT ON dbo.DetalleFactura TO medico;

GRANT SELECT, INSERT, UPDATE ON dbo.HistorialMedico TO medico;


-- Auditor: solo lectura global

GRANT SELECT ON SCHEMA::dbo TO auditor;
go


/* PREVENCIÓN DE INYECCIÓN SQL */

-- Crear una cita (INSERT parametrizado)
CREATE OR ALTER PROCEDURE dbo.sp_CitaCrear
  @id_paciente    INT,
  @id_medico      INT,
  @id_consultorio INT = NULL,
  @id_estado      INT,
  @fecha_cita     DATETIME2,
  @duracion       INT,
  @motivo         VARCHAR(300) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dbo.Citas (id_paciente, id_medico, id_consultorio, id_estado, fecha_cita, duracion, motivo)
  VALUES (@id_paciente, @id_medico, @id_consultorio, @id_estado, @fecha_cita, @duracion, @motivo);
END
GO

-- Actualizar estado de una cita (UPDATE parametrizado)
CREATE OR ALTER PROCEDURE dbo.sp_CitaActualizarEstado
  @id_cita   INT,
  @id_estado INT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE dbo.Citas
  SET id_estado = @id_estado
  WHERE id_cita = @id_cita;
END
GO

-- Eliminar cita SOLO si está cancelada (DELETE parametrizado con condición)
CREATE OR ALTER PROCEDURE dbo.sp_CitaEliminarSiCancelada
  @id_cita INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id_cancelada INT = (SELECT id_estado FROM dbo.EstadoCita WHERE nombre = 'cancelada');

  DELETE FROM dbo.Citas
  WHERE id_cita = @id_cita
    AND id_estado = @id_cancelada;
END
GO

-- Ejemplo de SQL dinámico SEGURO (sp_executesql + parámetros)
CREATE OR ALTER PROCEDURE dbo.sp_PersonaBuscarPorCedula
  @cedula VARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @sql NVARCHAR(MAX) = N'SELECT id_persona, nombre, apellido, email
                                 FROM dbo.Personas
                                 WHERE cedula = @pCedula';
  EXEC sp_executesql @sql, N'@pCedula VARCHAR(20)', @pCedula = @cedula;
END
GO

