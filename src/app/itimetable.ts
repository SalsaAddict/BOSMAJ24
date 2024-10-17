import { Activity, Category, Genre } from './color';

export interface ITimetable {
  Days: IDay[];
  Areas: IArea[];
  Items: ITimetableItem[];
  Categories: Category[];
}
export interface IDay {
  Date: Date;
  Day: string;
}
export interface IArea {
  Id: string;
  Description: String;
}
export interface ITimetableItem {
  Day: string;
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
  Genre: keyof typeof Genre;
}
export function isWorkshop(item: ITimetableItem): item is IWorkshop {
  return (item as IWorkshop).Act !== undefined;
}
export interface IActivity extends ITimetableItem {
  Title: string;
  Subtitle?: string;
  Description?: string;
  Hours: number;
  Category: keyof typeof Activity;
}
export function isActivity(item: ITimetableItem): item is IActivity {
  return !isWorkshop(item);
}
export function toTime(hour: number) {
  let time = new Date(0);
  time.setHours(hour >= 8 ? hour : hour + 24);
  return time;
}
