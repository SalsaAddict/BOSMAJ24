SET NOCOUNT ON
GO
DROP PROCEDURE IF EXISTS [ExportTeachers]
DROP PROCEDURE IF EXISTS [ExportTimetable]
DROP VIEW IF EXISTS [WorkshopsPerTeacher]
DROP TABLE IF EXISTS [Workshop]
DROP TABLE IF EXISTS [Genre]
DROP TABLE IF EXISTS [Level]
DROP TABLE IF EXISTS [Slot]
DROP TABLE IF EXISTS [Area]
GO
CREATE TABLE [Area] (
	[Id] NCHAR(1) NOT NULL,
	[Description] NVARCHAR(255) NOT NULL,
	[Sort] TINYINT NOT NULL,
	CONSTRAINT [PK_Area] PRIMARY KEY ([Id]),
	CONSTRAINT [UQ_Area_Description] UNIQUE ([Description])
)
GO
INSERT INTO [Area] ([Id], [Description], [Sort])
VALUES
	(N'M', N'Main Room', 1),
	(N'R', N'Reception', 2),
	(N'L', N'Lake Terrace', 3),
	(N'S', N'Outdoor Stage', 4)
GO
CREATE TABLE [Slot] (
	[Date] DATE NOT NULL,
	[Hour] TINYINT NOT NULL,
	[AreaId] NCHAR(1) NOT NULL,
	CONSTRAINT [PK_Slot] PRIMARY KEY CLUSTERED ([Date], [Hour], [AreaId]),
	CONSTRAINT [FK_Slot_Area] FOREIGN KEY ([AreaId]) REFERENCES [Area] ([Id])
)
GO
INSERT INTO [Slot] ([Date], [Hour], [AreaId])
SELECT
	[Date] = DATEADD(day, o.[Offset], N'2024-10-31'),
	[Hour] = h.[Hour],
	[AreaId] = a.[Id]
FROM [Area] a
	CROSS APPLY (VALUES (0), (1), (2), (3)) o ([Offset])
	CROSS APPLY (VALUES (11), (12), (15), (16), (17)) h ([Hour])
WHERE NOT (o.[Offset] = 0 AND a.[Id] = N'R')
	AND NOT (o.[Offset] = 0 AND h.[Hour] < 15)
ORDER BY o.[Offset], h.[Hour], a.[Sort]
GO
CREATE TABLE [Level] (
	[Id] TINYINT NOT NULL,
	[Description] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_Level] PRIMARY KEY ([Id]),
	CONSTRAINT [UQ_Level_Description] UNIQUE ([Description])
)
GO
INSERT INTO [Level] ([Id], [Description])
VALUES
	(0, N'All Levels'),
	(1, N'Beginner'),
	(2, N'Improver'),
	(3, N'Intermediate'),
	(4, N'Int/Adv')
GO
CREATE TABLE [Genre] (
	[Id] NCHAR(1) NOT NULL,
	[Description] NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_Genre] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_Genre_Description] UNIQUE ([Description])
)
GO
INSERT INTO [Genre] ([Id], [Description])
VALUES
	(N'B', N'Bachata'),
	(N'S', N'Salsa'),
	(N'O', N'Other')
GO
CREATE TABLE [Workshop] (
	[Date] DATE NOT NULL,
	[Hour] TINYINT NOT NULL,
	[AreaId] NCHAR(1) NOT NULL,
	[Act] NVARCHAR(255) NOT NULL,
	[Title] NVARCHAR(255) NOT NULL,
	[LevelId] TINYINT NOT NULL,
	[GenreId] NCHAR(1) NOT NULL,
	CONSTRAINT [PK_Workshop] PRIMARY KEY ([Date], [Hour], [Act]),
	CONSTRAINT [FK_Workshop_Act] FOREIGN KEY ([Act]) REFERENCES [Act] ([Name]),
	CONSTRAINT [FK_Workshop_Level] FOREIGN KEY ([LevelId]) REFERENCES [Level] ([Id]),
	CONSTRAINT [FK_Workshop_Genre] FOREIGN KEY ([GenreId]) REFERENCES [Genre] ([Id]),
	CONSTRAINT [FK_Workshop_Slot] FOREIGN KEY ([Date], [Hour], [AreaId])
		REFERENCES [Slot] ([Date], [Hour], [AreaId])
)
GO
CREATE VIEW [WorkshopsPerTeacher]
WITH SCHEMABINDING
AS
SELECT
	[Teacher] = g.[FullName],
	[Workshops] = COUNT_BIG(*)
FROM [dbo].[Guest] g
	JOIN [dbo].[Act] act ON g.[FullName] IN (act.[Artist1], act.[Artist2])
	JOIN [dbo].[Workshop] w ON act.[Name] = w.[Act]
GROUP BY g.[FullName]
GO
CREATE UNIQUE CLUSTERED INDEX [PK_WorkshopsPerTeacher] ON [WorkshopsPerTeacher] ([Teacher])
GO
CREATE PROCEDURE [ExportTimetable]
AS
BEGIN
	SET NOCOUNT ON
	SELECT (
		SELECT
			[Days] = (
					SELECT
						[Date],
						[Day] = LEFT(DATENAME(weekday, [Date]), 3)
					FROM (VALUES (0), (1), (2), (3)) o ([Offset])
						CROSS APPLY (VALUES (DATEADD(day, [Offset], CONVERT(DATE, N'2024-10-31')))) dte ([Date])
					ORDER BY [Date]
					FOR JSON PATH
				),
			[Areas] = (
					SELECT [Id], [Description]
					FROM [Area]
					ORDER BY [Sort]
					FOR JSON PATH
				),
			[Workshops] = (
					SELECT
						[Day] = LEFT(DATENAME(weekday, [Date]), 3),
						[Hour],
						[AreaId],
						[Act],
						[Title],
						[LevelId],
						[Level] = l.[Description],
						[GenreId]
					FROM [Workshop] w
						JOIN [Level] l ON w.[LevelId] = l.[Id]
					ORDER BY [Date], [Hour]
					FOR JSON PATH
				)
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)
	RETURN
END
GO
CREATE PROCEDURE [ExportTeachers]
AS
BEGIN
	SET NOCOUNT ON
	SELECT (
			SELECT
				[Teacher] = tch.[FullName],
				[TeacherRow] = ROW_NUMBER() OVER (PARTITION BY tch.[FullName] ORDER BY act.[Name], w.[Date], w.[Hour], a.[Sort]),
				[TeacherRowSpan] = COUNT(*) OVER (PARTITION BY tch.[FullName]),
				[TeacherCount] = COUNT(w.[Act]) OVER (PARTITION BY tch.[FullName]),
				[Act] = act.[Name],
				[ActRow] = ROW_NUMBER() OVER (PARTITION BY tch.[FullName], act.[Name] ORDER BY w.[Date], w.[Hour], a.[Sort]),
				[ActRowSpan] = COUNT(*) OVER (PARTITION BY tch.[FullName], act.[Name]),
				[ActCount] = COUNT(w.[Act]) OVER (PARTITION BY tch.[FullName], act.[Name]),
				[Partner] = ISNULL(NULLIF(act.[Artist1], tch.[FullName]), act.[Artist2]),
				[Day] = LEFT(DATENAME(weekday, w.[Date]), 3),
				[Time] = CONVERT(NVARCHAR(5), CONVERT(TIME, DATEADD(hour, w.[Hour], 0))),
				[Area] = a.[Description],
				[Title] = w.[Title],
				[Level] = l.[Description],
				[Genre] = g.[Description],
				[Ok] = CONVERT(BIT, CASE
						WHEN dte.[When] NOT BETWEEN tch.[ArriveWhen] AND tch.[DepartWhen] THEN 0
						WHEN COUNT(w.[Act]) OVER (PARTITION BY tch.[FullName], w.[Date], w.[Hour]) > 1 THEN NULL
						ELSE 1
					END)
			FROM [Guest] tch
				JOIN [Act] act ON tch.[FullName] IN (act.[Artist1], act.[Artist2])
				LEFT JOIN [Workshop] w
						JOIN [Area] a ON w.[AreaId] = a.[Id]
						JOIN [Level] l ON w.[LevelId] = l.[Id]
						JOIN [Genre] g ON w.[GenreId] = g.[Id]
						CROSS APPLY (VALUES (DATEADD(hour, w.[Hour], CONVERT(SMALLDATETIME, w.[Date])))) dte ([When])
					ON act.[Name] = w.[Act]
			ORDER BY tch.[FullName], act.[Name], w.[Date], w.[Hour], a.[Sort]
			FOR JSON PATH
		)
	RETURN
END
GO