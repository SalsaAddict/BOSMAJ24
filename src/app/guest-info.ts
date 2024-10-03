export interface IGuestInfo {
  GuestId: number;
  Staff: boolean;
  FullName: string;
  TicketId?: string;
  TicketType?: string;
  RoomType: string;
  RoomTypeOk?: boolean;
  RoomConfig: string;
  RoomConfigOk?: boolean;
  Booking: string;
  Reservation: string;
  ReservationOk?: boolean;
  SharingWith?: string;
  SharingWithId?: number;
  SharingWithOk?: boolean;
  DietaryInfo?: string;
  DietaryInfoOk?: boolean;
  HasQuestion: boolean;
  HasProblem: boolean;
}
