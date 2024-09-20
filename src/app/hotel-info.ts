export interface HotelInfo {
  Summary: {
    RoomType: string;
    Period: string;
    Rooms: number;
    Guests: number;
  }[];
  Dietary: {
    Dietary: string;
    Guests: number;
  }[];
  RoomTypes: RoomType[];
}
export interface RoomType {
  Description: string;
  Rooms: Room[];
}
export interface Room {
  Guests: Guest[];
  Notes?: string;
}
export interface Guest {
  Forename: string;
  Surname: string;
  CheckInDay: string;
  CheckOutDay: string;
  Dietary?: string;
  Reference: string;
}
