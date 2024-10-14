export interface ITimetable {
  Days: IDay[];
  Areas: IArea[];
  Items: ITimetableItem[];
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
export interface ITimetableItem {
  Day: Day;
  Hour: number;
  AreaId: string;
}
export type LevelId = 0 | 1 | 2 | 3 | 4;
export type GenreId = 'B' | 'S' | 'O';
export interface IWorkshop extends ITimetableItem {
  Act: string;
  Title: string;
  LevelId: number;
  Level: string;
  GenreId: GenreId;
}
export function isWorkshop(item: ITimetableItem): item is IWorkshop {
  return (item as IWorkshop).Act !== undefined;
}
export interface IActivity extends ITimetableItem {
  Title: string;
  Subtitle?: string;
  Description?: string;
  Hours: number;
  Category: 'Performance' | 'Party';
}
export function isActivity(item: ITimetableItem): item is IActivity {
  return !isWorkshop(item);
}
export function toTime(hour: number) {
  let time = new Date(0);
  time.setHours(hour >= 8 ? hour : hour + 24);
  return time;
}
