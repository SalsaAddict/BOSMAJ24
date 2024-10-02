USE [Advent_TMP]
GO
DROP PROCEDURE IF EXISTS [ImportWebSales]
DROP VIEW IF EXISTS [WebSalesNames]
DROP TABLE IF EXISTS [WebSales]
DROP TABLE IF EXISTS [Occupant]
DROP TABLE IF EXISTS [Room]
DROP TABLE IF EXISTS [RoomType]
DROP TABLE IF EXISTS [Attendee]
DROP TABLE IF EXISTS [TicketType]
DROP TABLE IF EXISTS [CheckInDay]
GO
CREATE TABLE [TicketType] (
	[Description] NVARCHAR(25) NOT NULL,
	CONSTRAINT [PK_TicketType] PRIMARY KEY CLUSTERED ([Description])
)
GO
INSERT INTO [TicketType] ([Description])
VALUES (N'Single'), (N'Standard'), (N'Premium')
GO
CREATE TABLE [CheckInDay] (
	[Day] NCHAR(3) NOT NULL,
	CONSTRAINT [PK_CheckInDay] PRIMARY KEY CLUSTERED ([Day])
)
GO
INSERT INTO [CheckInDay] ([Day])
VALUES (N'Thu'), (N'Fri')
GO
CREATE TABLE [Attendee] (
	[OrderId] NVARCHAR(100) NOT NULL,
	[TicketId] NVARCHAR(100) NOT NULL,
	[TicketType] NVARCHAR(25) NOT NULL,
	[Forename] NVARCHAR(127) NOT NULL,
	[Surname] NVARCHAR(127) NOT NULL,
	[FullName] AS [Forename] + N' ' + [Surname] PERSISTED,
	[Email] NVARCHAR(255) NOT NULL,
	[CheckInDay] NCHAR(3) NOT NULL,
	[CheckOutDay] AS CONVERT(NCHAR(3), N'Mon') PERSISTED,
	[Dietary] NVARCHAR(255) NULL,
	[IsOrganiser] BIT NOT NULL CONSTRAINT [CK_Attendee_IsOrganiser] DEFAULT (0),
	[IsTeacher] BIT NOT NULL CONSTRAINT [CK_Attendee_IsTeacher] DEFAULT (0),
	[IsDJ] BIT NOT NULL CONSTRAINT [CK_Attendee_IsDJ] DEFAULT (0),
	[IsVolunteer] BIT NOT NULL CONSTRAINT [CK_Attendee_IsVolunteer] DEFAULT (0),
	[IsStaff] AS [IsOrganiser] | [IsTeacher] | [IsDJ] | [IsVolunteer] PERSISTED,
	CONSTRAINT [PK_Attendee] PRIMARY KEY CLUSTERED ([OrderId], [TicketId]),
	CONSTRAINT [UQ_Attendee_TicketId] UNIQUE ([TicketId]),
	CONSTRAINT [FK_Attendee_TicketType] FOREIGN KEY ([TicketType]) REFERENCES [TicketType] ([Description]),
	CONSTRAINT [FK_Attendee_CheckInDay] FOREIGN KEY ([CheckInDay]) REFERENCES [CheckInDay] ([Day]),
	CONSTRAINT [CK_Attendee_Dietary] CHECK ([Dietary] IN (N'-', N'Vegan', N'Vegetarian', N'Gluten Free', N'Gluten & Dairy Free'))
)
GO
CREATE TABLE [RoomType] (
	[Id] INT NOT NULL IDENTITY (1, 1),
	[Description] NVARCHAR(255) NOT NULL,
	[MaxOccupants] TINYINT NOT NULL,
	[SortOrder] INT NOT NULL,
	CONSTRAINT [PK_RoomType] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_RoomType_MaxOccupants] UNIQUE ([Id], [MaxOccupants]),
	CONSTRAINT [UQ_RoomType_SortOrder] UNIQUE ([SortOrder])
)
GO
INSERT INTO [RoomType] ([Description], [MaxOccupants], [SortOrder])
VALUES
	(N'Double Room - Single Occupant', 1, 1),
	(N'Double Room', 2, 2),
	(N'Twin Room', 2, 3),
	(N'Jacuzzi Suite', 2, 4)
GO
CREATE TABLE [Room] (
	[Id] INT NOT NULL IDENTITY (1, 1),
	[RoomTypeId] INT NOT NULL,
	[MaxOccupants] TINYINT NOT NULL,
	[Notes] NVARCHAR(max) NULL,
	CONSTRAINT [PK_Room] PRIMARY KEY CLUSTERED ([Id]),
	CONSTRAINT [UQ_Room_MaxOccupants] UNIQUE ([Id], [MaxOccupants]),
	CONSTRAINT [FK_Room_RoomType] FOREIGN KEY ([RoomTypeId], [MaxOccupants]) REFERENCES [RoomType] ([Id], [MaxOccupants])
)
GO
CREATE TABLE [Occupant] (
	[RoomId] INT NOT NULL,
	[OccupantId] TINYINT NOT NULL,
	[MaxOccupants] TINYINT NOT NULL,
	[OrderId] NVARCHAR(100) NOT NULL,
	[TicketId] NVARCHAR(100) NOT NULL,
	CONSTRAINT [PK_Occupant] PRIMARY KEY CLUSTERED ([RoomId], [OccupantId]),
	CONSTRAINT [UQ_Occupant_TicketId] UNIQUE ([TicketId]),
	CONSTRAINT [FK_Occupant_Room] FOREIGN KEY ([RoomId], [MaxOccupants]) REFERENCES [Room] ([Id], [MaxOccupants]),
	CONSTRAINT [FK_Occupant_Attendee] FOREIGN KEY ([OrderId], [TicketId]) REFERENCES [Attendee] ([OrderId], [TicketId])
)
GO
CREATE TABLE [WebSales] (
	[Order_number] NVARCHAR(50) NOT NULL,
	[Order_date] SMALLDATETIME NOT NULL,
	[Guest_name] NVARCHAR(50) NOT NULL,
	[Email] NVARCHAR(50) NOT NULL,
	[Ticket_type] NVARCHAR(50) NOT NULL,
	[Ticket_number] NVARCHAR(50) NOT NULL,
	[Ticket_price] MONEY NOT NULL,
	[Benefit] NVARCHAR(1) NULL,
	[Coupon] NVARCHAR(50) NULL,
	[Tax] MONEY NOT NULL,
	[Total_ticket_price] MONEY NOT NULL,
	[Wix_service_fee] MONEY NOT NULL,
	[Ticket_revenue] MONEY NOT NULL,
	[Payment_status] NVARCHAR(50) NOT NULL,
	[Checked_in] NVARCHAR(50) NOT NULL,
	[Seat_Information] NVARCHAR(1) NULL,
	[Someone_to_share_with] NVARCHAR(25) NULL,
	[Sharing_info_1] NVARCHAR(200) NULL,
	[Sharing_info_2] NVARCHAR(200) NULL,
	[Dietary_info] NVARCHAR(50) NULL,
	CONSTRAINT [PK_WebSales] PRIMARY KEY CLUSTERED ([Ticket_number]),
	CONSTRAINT [CK_WebSales_Someone_to_share_with] CHECK ([Someone_to_share_with] IN (N'yes', N'no'))
)
GO
CREATE VIEW [WebSalesNames]
WITH SCHEMABINDING
AS
SELECT
	[Ticket_number],
	[Guest_name],
	[Guest_forename] = TRIM(LEFT([Guest_name], CHARINDEX(N' ', [Guest_name]) - 1)),
	[Guest_surname] = TRIM(RIGHT([Guest_name], LEN([Guest_name]) - CHARINDEX(N' ', [Guest_name])))
FROM [dbo].[WebSales]
GO
CREATE UNIQUE CLUSTERED INDEX [PK_WebSalesNames] ON [WebSalesNames] ([Ticket_number])
GO
CREATE PROCEDURE [ImportWebSales]
AS
BEGIN
	SET NOCOUNT ON
	DELETE [WebSales]
	BULK INSERT [dbo].[WebSales]
	FROM 'D:\tmp\websales.csv'
	WITH (
			DATAFILETYPE = 'widechar',
			FORMAT = 'CSV',
			FIRSTROW = 2
		)
	UPDATE s
	SET [Guest_name] = n.[Guest_forename] + N' ' + n.[Guest_surname]
	FROM [WebSales] s
		JOIN [WebSalesNames] n ON s.[Ticket_number] = n.[Ticket_number]
	RETURN
END
GO
