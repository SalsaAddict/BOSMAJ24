export interface ITimetable {
  Days: IDay[];
  Areas: IArea[];
  Workshops: ISlot[];
}
export type Day = 'Thu' | 'Fri' | 'Sat' | 'Sun';
export interface IDay {
  Date: Date;
  Day: Day;
}
export interface IArea {
  Id: string;
  Description: String;
}
export interface ISlot {
  Day: Day;
  Hour: number;
  AreaId: string;
}
export type LevelId = 0 | 1 | 2 | 3 | 4;
export type GenreId = 'B' | 'S' | 'O';
export interface IWorkshop extends ISlot {
  Act: string;
  Title: string;
  LevelId: number;
  Level: string;
  GenreId: GenreId;
}
export function isWorkshop(slot: ISlot): slot is IWorkshop {
  return (slot as IWorkshop).Act !== undefined;
}
export interface IShow extends ISlot {
  Title: string;
  Subtitle?: string;
}
export function isShow(slot: ISlot): slot is IShow {
  return !isWorkshop(slot);
}
