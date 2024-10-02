--DELETE [Guest]

INSERT INTO [Guest] ([TicketId], [Forename], [Surname], [CheckInDate], [CheckOutDate], [DietaryInfo])
OUTPUT [inserted].*
SELECT
	s.[Ticket_number],
	n.[Guest_forename],
	n.[Guest_surname],
	[CheckInDate] = CASE RIGHT(s.[Ticket_type], LEN(s.[Ticket_type]) - CHARINDEX(N': ', s.[Ticket_type]) - 1)
			WHEN N'Thurs to Mon' THEN N'2024-10-31'
			WHEN N'Fri to Mon' THEN N'2024-11-01'
		END,
	[CheckOutDate] = N'2024-11-04',
	[DietaryInfo] = CASE
			WHEN s.[Ticket_number] = N'2W99-P0Z1-JFL1P' THEN N'Gluten Free' -- See [Sharing_info_2]
			WHEN s.[Ticket_number] = N'2WD3-7JHN-86F1Q' THEN N'Gluten & Dairy Free' -- See [Sharing_info_2]
			ELSE ISNULL(d.[DietaryInfo], td.[DietaryInfo])
		END
FROM [WebSales] s
	JOIN [WebSalesNames] n ON s.[Ticket_number] = n.[Ticket_number]
	OUTER APPLY (VALUES (NULLIF(TRIM(s.[Dietary_info]), N'No'))) td ([DietaryInfo])
	LEFT JOIN [Diet] d ON td.[DietaryInfo] = d.[DietaryInfo]


