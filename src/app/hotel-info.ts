export interface IHotelInfo {
  Summary: ISummary[];
  Allocations: IAllocation[];
}
export interface ISummary {
  RoomType: string;
  Configuration: string;
  StaffThuMon: number;
  GuestsThuMon: number;
  StaffFriMon: number;
  GuestsFriMon: number;
  Total: number;
}
export interface IAllocation {
  GuestType: string;
  Stays: IStay[];
}
export interface IStay {
  Stay: string;
  Nights: number;
  RoomTypes: IRoomType[];
}
export interface IRoomType {
  RoomType: string;
  Configurations: IConfiguration[];
}
export interface IConfiguration {
  Configuration: string;
  Rooms: IRoom[];
}
export interface IRoom {
  RoomId: number;
  Occupants: number;
  Guests: IGuest[];
}
export interface IGuest {
  Forename: string;
  Surname: string;
  DietaryInfo?: string;
  Reference?: string;
}
