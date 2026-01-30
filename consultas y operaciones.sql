-- consultas y operaciones
use clinica_db_Proyecto;
go 
--1 listar pacientes 
SELECT p.id_paciente, pe.nombre, pe.apellido, pe.cedula, pe.email
FROM dbo.Pacientes AS p
JOIN dbo.Personas  AS pe ON pe.id_persona = p.id_paciente
ORDER BY pe.apellido, pe.nombre;


--2 citas proximas

SELECT id_cita, id_paciente, id_medico, fecha_cita, duracion, motivo
FROM dbo.Citas
WHERE fecha_cita >= SYSDATETIME()
ORDER BY fecha_cita;



--3 citas con nombres de pacientes
SELECT c.id_cita,
       CONCAT(pp.nombre,' ',pp.apellido) AS paciente,
       CONCAT(pm.nombre,' ',pm.apellido) AS medico,
       e.nombre AS estado,
       co.nombre AS consultorio,
       c.fecha_cita, c.duracion, c.motivo
FROM dbo.Citas AS c
JOIN dbo.Pacientes      AS pa ON pa.id_paciente     = c.id_paciente
JOIN dbo.Personas       AS pp ON pp.id_persona      = pa.id_paciente
JOIN dbo.Medicos        AS m  ON m.id_medico        = c.id_medico
JOIN dbo.Personas       AS pm ON pm.id_persona      = m.id_medico
JOIN dbo.EstadoCita     AS e  ON e.id_estado        = c.id_estado
LEFT JOIN dbo.Consultorios AS co ON co.id_consultorio = c.id_consultorio
ORDER BY c.fecha_cita;



--4 historial medico 

SELECT h.id_historial,
       CONCAT(pp.nombre,' ',pp.apellido)  AS paciente,
       CONCAT(pm.nombre,' ',pm.apellido)  AS medico,
       h.diagnostico, h.tratamiento, h.notas, c.fecha_cita
FROM dbo.HistorialMedico AS h
JOIN dbo.Citas        AS c  ON c.id_cita     = h.id_cita
JOIN dbo.Pacientes    AS pa ON pa.id_paciente = h.id_paciente
JOIN dbo.Personas     AS pp ON pp.id_persona  = pa.id_paciente
JOIN dbo.Medicos      AS m  ON m.id_medico    = h.id_medico
JOIN dbo.Personas     AS pm ON pm.id_persona  = m.id_medico
ORDER BY c.fecha_cita DESC;



--5 facturas con nombre del paciente 

SELECT f.id_factura,
       CONCAT(pe.nombre,' ',pe.apellido) AS paciente,
       f.total, f.estado, f.fecha
FROM dbo.Facturas AS f
JOIN dbo.Pacientes AS p ON p.id_paciente = f.id_paciente
JOIN dbo.Personas  AS pe ON pe.id_persona = p.id_paciente
ORDER BY f.fecha DESC, f.id_factura DESC;




--6 total de la factura 


SELECT f.id_factura,
       CONCAT(pe.nombre,' ',pe.apellido) AS paciente,
       SUM(d.cantidad * d.precio) AS total_calculado
FROM dbo.Facturas       AS f
JOIN dbo.Pacientes      AS p  ON p.id_paciente   = f.id_paciente
JOIN dbo.Personas       AS pe ON pe.id_persona   = p.id_paciente
JOIN dbo.DetalleFactura AS d  ON d.id_factura    = f.id_factura
GROUP BY f.id_factura, pe.nombre, pe.apellido
ORDER BY f.id_factura;



--7  citas por especialidad 

SELECT e.nombre AS especialidad, COUNT(*) AS numero_citas
FROM dbo.Citas AS c
JOIN dbo.Medicos       AS m ON m.id_medico = c.id_medico
JOIN dbo.Especialidades AS e ON e.id_especialidad = m.id_especialidad
GROUP BY e.nombre
ORDER BY numero_citas DESC;





--8 citas por paciente 

SELECT CONCAT(pe.nombre,' ',pe.apellido) AS paciente, COUNT(*) AS citas
FROM dbo.Citas AS c
JOIN dbo.Pacientes AS p ON p.id_paciente = c.id_paciente
JOIN dbo.Personas  AS pe ON pe.id_persona = p.id_paciente
GROUP BY pe.nombre, pe.apellido
--HAVING COUNT(*) >= 2
ORDER BY citas DESC, paciente;





--9 duracion de citas 

SELECT CONCAT(pm.nombre,' ',pm.apellido) AS medico,
       AVG(CAST(c.duracion AS DECIMAL(10,2))) AS duracion_promedio_min
FROM dbo.Citas AS c
JOIN dbo.Medicos  AS m  ON m.id_medico   = c.id_medico
JOIN dbo.Personas AS pm ON pm.id_persona = m.id_medico
GROUP BY pm.nombre, pm.apellido
ORDER BY duracion_promedio_min DESC;



--10 ultima cita del paciente 

SELECT p.id_paciente,
       CONCAT(pe.nombre,' ',pe.apellido) AS paciente,
       (SELECT MAX(c2.fecha_cita)
        FROM dbo.Citas AS c2
        WHERE c2.id_paciente = p.id_paciente) AS ultima_cita
FROM dbo.Pacientes AS p
JOIN dbo.Personas  AS pe ON pe.id_persona = p.id_paciente
ORDER BY ultima_cita DESC;
go

-- 11  detalle de citas (vista )

CREATE OR ALTER VIEW dbo.vw_CitasDetalle
AS
SELECT c.id_cita,
       CONCAT(pp.nombre,' ',pp.apellido) AS paciente,
       CONCAT(pm.nombre,' ',pm.apellido) AS medico,
       e.nombre AS estado,
       co.nombre AS consultorio,
       c.fecha_cita, c.duracion, c.motivo
FROM dbo.Citas AS c
JOIN dbo.Pacientes      AS pa ON pa.id_paciente     = c.id_paciente
JOIN dbo.Personas       AS pp ON pp.id_persona      = pa.id_paciente
JOIN dbo.Medicos        AS m  ON m.id_medico        = c.id_medico
JOIN dbo.Personas       AS pm ON pm.id_persona      = m.id_medico
JOIN dbo.EstadoCita     AS e  ON e.id_estado        = c.id_estado
LEFT JOIN dbo.Consultorios AS co ON co.id_consultorio = c.id_consultorio;
GO


SELECT TOP 10 * FROM dbo.vw_CitasDetalle ORDER BY fecha_cita DESC;

-- 12 insert 
DECLARE @id_estado_programada INT =
  (SELECT id_estado FROM dbo.EstadoCita WHERE nombre = 'programada');

INSERT INTO dbo.Citas (id_paciente, id_medico, id_consultorio, id_estado, fecha_cita, duracion, motivo)
VALUES (1, 4, 1, @id_estado_programada, '2026-02-20 09:30:00', 30, 'Control de rutina');
select * from Citas ;
go
-- 13 update 
DECLARE @id_estado_atendida INT =
  (SELECT id_estado FROM dbo.EstadoCita WHERE nombre = 'atendida');

UPDATE dbo.Citas
SET id_estado = @id_estado_atendida
WHERE id_cita = 1; 

select * from dbo.Citas;
go 

-- 14 delete 

DECLARE @id_estado_cancelada INT =
  (SELECT id_estado FROM dbo.EstadoCita WHERE nombre = 'cancelada');

DELETE FROM dbo.Citas
WHERE id_estado = @id_estado_cancelada
  AND fecha_cita < SYSDATETIME();


SELECT * FROM Citas;
go 